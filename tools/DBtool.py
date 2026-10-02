#!/usr/bin/env python3
"""DSP Database Management Tool.

Imports the sql/*.sql files, backs up and restores the database.
Self-locating: run it from anywhere (double-click, DBtool.bat, or `python DBtool.py`).

  * Credentials come from  <root>/conf/map_darkstar.conf  (or map.conf)
  * mysql / mysqldump are found from config.yaml, PATH, then common install dirs
  * Only the standard library is required (yaml/colorama are used if installed)

CLI:
  DBtool.py                     interactive menu
  DBtool.py update              import all non-player SQL files (auto backup first)
  DBtool.py backup [lite]       full backup (or player-data-only 'lite')
  DBtool.py restore <file>      import a file from sql/backups (or any path)
  DBtool.py setup <dbname>      create the DB and import everything
  DBtool.py reset <dbname>      re-import everything (backs up first)
  DBtool.py check               show config, paths and connection test
"""
import glob
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time

try:
    import colorama
    from colorama import Fore, Style
    colorama.init(autoreset=True)
except ImportError:
    class _Nil:
        def __getattr__(self, _):
            return ''
    Fore = Style = _Nil()
    colorama = None

try:
    import yaml
except ImportError:
    yaml = None

TOOLS_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(TOOLS_DIR)
CONF_DIR = os.path.join(ROOT, 'conf')
SQL_DIR = os.path.join(ROOT, 'sql')
BACKUP_DIR = os.path.join(SQL_DIR, 'backups')
CONFIG_YAML = os.path.join(TOOLS_DIR, 'config.yaml')
ERROR_LOG = os.path.join(TOOLS_DIR, 'error.log')
CONF_CANDIDATES = ['map_darkstar.conf', 'map.conf']

# Default 'protected' player-data tables (never imported by update; dumped by 'lite')
DEFAULT_PLAYER_DATA = [
    'accounts.sql', 'accounts_banned.sql', 'auction_house.sql', 'char_blacklist.sql',
    'char_effects.sql', 'char_equip.sql', 'char_exp.sql', 'char_inventory.sql',
    'char_jobs.sql', 'char_look.sql', 'char_merit.sql', 'char_pet.sql',
    'char_points.sql', 'char_profile.sql', 'char_skills.sql', 'char_spells.sql',
    'char_stats.sql', 'char_storage.sql', 'char_style.sql', 'char_unlocks.sql',
    'char_vars.sql', 'chars.sql', 'conquest_system.sql', 'delivery_box.sql',
    'linkshells.sql', 'server_variables.sql', 'unity_system.sql',
]

player_data = list(DEFAULT_PLAYER_DATA)
auto_backup = True
mysql_bin = ''          # directory containing mysql / mysqldump (with trailing slash) or ''
creds = {}              # host, port, login, password, database
import_files = []
backups = []


# ----------------------------------------------------------------------------
# helpers
# ----------------------------------------------------------------------------
def info(msg):  print(Fore.CYAN + msg)
def ok(msg):    print(Fore.GREEN + msg)
def warn(msg):  print(Fore.YELLOW + msg)
def err(msg):   print(Fore.RED + msg)


def ask(prompt):
    try:
        return input(prompt)
    except EOFError:
        return ''


def yes(prompt):
    return ask(prompt + ' [y/N] ').strip().lower() == 'y'


def exe_name(base):
    return base + ('.exe' if os.name == 'nt' else '')


# ----------------------------------------------------------------------------
# configuration
# ----------------------------------------------------------------------------
def fetch_credentials():
    """Read mysql_* settings from the server conf. Returns True on success."""
    conf_path = None
    for name in CONF_CANDIDATES:
        p = os.path.join(CONF_DIR, name)
        if os.path.isfile(p):
            conf_path = p
            break
    if not conf_path:
        err('Could not find a map config. Looked for:')
        for name in CONF_CANDIDATES:
            err('  ' + os.path.join(CONF_DIR, name))
        return False

    found = {}
    with open(conf_path, encoding='utf-8', errors='replace') as f:
        for line in f:
            if line.lstrip().startswith(('#', '//')):
                continue
            m = re.match(r'\s*(mysql_\w+)\s*:\s*(.*?)\s*$', line)
            if m:
                found[m.group(1)] = m.group(2)

    if not found.get('mysql_database') or not found.get('mysql_login'):
        err('mysql_database / mysql_login missing from ' + conf_path)
        return False

    creds.update(
        host=found.get('mysql_host') or '127.0.0.1',
        port=int(found.get('mysql_port') or 3306),
        login=found['mysql_login'],
        password=found.get('mysql_password', ''),
        database=found['mysql_database'],
        conf=conf_path,
    )
    return True


def fetch_configs():
    """Load optional tools/config.yaml (mysql_bin, auto_backup, player_data)."""
    global mysql_bin, auto_backup, player_data
    if not yaml or not os.path.isfile(CONFIG_YAML):
        return
    try:
        with open(CONFIG_YAML, encoding='utf-8') as f:
            data = yaml.safe_load(f) or []
        if isinstance(data, dict):
            data = [data]
        for entry in data:
            for key, value in (entry or {}).items():
                if key == 'mysql_bin' and value:
                    mysql_bin = str(value)
                elif key == 'auto_backup':
                    auto_backup = bool(value)
                elif key == 'player_data' and isinstance(value, list):
                    player_data = value
    except Exception as e:
        warn('Could not read config.yaml (%s); using defaults.' % e)


def write_configs():
    if not yaml:
        return
    try:
        with open(CONFIG_YAML, 'w', encoding='utf-8') as f:
            yaml.safe_dump([{'mysql_bin': mysql_bin}, {'auto_backup': auto_backup},
                            {'player_data': player_data}], f, default_flow_style=False)
    except Exception as e:
        err('Error writing config.yaml: %s' % e)


# ----------------------------------------------------------------------------
# locating mysql / mysqldump
# ----------------------------------------------------------------------------
def _tool(name):
    """Full path of a client tool (mysql, mysqldump, mysqladmin) or None.
    Falls back to the mariadb-* names shipped with newer MariaDB."""
    alts = [name]
    if name.startswith('mysql'):
        alts.append('mariadb' + name[5:] if name != 'mysql' else 'mariadb')
        if name == 'mysqldump':
            alts.append('mariadb-dump')
        if name == 'mysqladmin':
            alts.append('mariadb-admin')
    for alt in alts:
        if mysql_bin:
            p = os.path.join(mysql_bin, exe_name(alt))
            if os.path.isfile(p):
                return p
        p = shutil.which(alt)
        if p:
            return p
    return None


def _search_dirs():
    dirs = [os.path.join(ROOT, 'MySQL', 'bin'), os.path.join(os.path.dirname(ROOT), 'MySQL', 'bin')]
    if os.name == 'nt':
        for base in filter(None, [os.environ.get('ProgramFiles'), os.environ.get('ProgramFiles(x86)'),
                                  os.environ.get('SystemDrive', 'C:') + '\\']):
            for pat in ('MariaDB*', 'MySQL*', 'MySQL\\MySQL Server*', 'xampp\\mysql', 'wamp*\\bin\\mysql\\mysql*',
                        'laragon\\bin\\mysql\\*'):
                dirs += sorted(glob.glob(os.path.join(base, pat, 'bin')), reverse=True)
                dirs += sorted(glob.glob(os.path.join(base, pat)), reverse=True)
        dirs += sorted(glob.glob('C:\\topaz\\**\\bin', recursive=False))
    else:
        dirs += ['/usr/bin', '/usr/local/bin', '/usr/local/mysql/bin', '/opt/homebrew/bin']
    return [d for d in dirs if os.path.isdir(d)]


def find_mysql_bin():
    """Set global mysql_bin so mysql + mysqldump are both usable. Returns True if found."""
    global mysql_bin
    if _tool('mysql') and _tool('mysqldump'):
        return True
    for d in _search_dirs():
        saved, mysql_bin = mysql_bin, d
        if _tool('mysql') and _tool('mysqldump'):
            return True
        mysql_bin = saved
    return False


def adjust_mysql_bin():
    global mysql_bin
    while True:
        choice = ask('Enter the path to your MySQL/MariaDB bin directory (blank to cancel).\n'
                     'e.g. C:\\Program Files\\MariaDB 12.3\\bin\n> ').strip().strip('"')
        if not choice:
            return False
        saved, mysql_bin = mysql_bin, choice
        if _tool('mysql') and _tool('mysqldump'):
            return True
        mysql_bin = saved
        err('mysql / mysqldump not found in that folder.')


# ----------------------------------------------------------------------------
# running client tools (no shell, no password on the command line)
# ----------------------------------------------------------------------------
def _defaults_file():
    fd, path = tempfile.mkstemp(prefix='dbtool_', suffix='.cnf')
    with os.fdopen(fd, 'w') as f:
        pw = creds['password'].replace('\\', '\\\\').replace('"', '\\"')
        f.write('[client]\nhost=%s\nport=%d\nuser=%s\npassword="%s"\n'
                % (creds['host'], creds['port'], creds['login'], pw))
    return path


def run_tool(name, args, stdin_path=None, stdout_path=None):
    """Run a client tool. Returns (returncode, stderr_text)."""
    exe = _tool(name)
    if not exe:
        return 127, 'Could not find %s. Set the bin folder in Settings.' % name
    cnf = _defaults_file()
    fin = fout = None
    try:
        fin = open(stdin_path, 'rb') if stdin_path else None
        fout = open(stdout_path, 'wb') if stdout_path else subprocess.DEVNULL
        proc = subprocess.run([exe, '--defaults-extra-file=' + cnf] + args,
                              stdin=fin, stdout=fout, stderr=subprocess.PIPE)
        return proc.returncode, proc.stderr.decode('utf-8', 'replace').strip()
    finally:
        for h in (fin, fout):
            if h not in (None, subprocess.DEVNULL):
                h.close()
        try:
            os.remove(cnf)
        except OSError:
            pass


def log_error(text):
    if text:
        with open(ERROR_LOG, 'a', encoding='utf-8') as f:
            f.write('[%s] %s\n' % (time.strftime('%Y-%m-%d %H:%M:%S'), text))


def sql_query(query):
    """Run one statement via the mysql client. Returns (ok, output/err)."""
    exe = _tool('mysql')
    if not exe:
        return False, 'mysql client not found'
    cnf = _defaults_file()
    try:
        needs_db = not query.startswith(('CREATE DATABASE', 'SHOW DATABASES', 'SELECT VERSION'))
        p = subprocess.run([exe, '--defaults-extra-file=' + cnf, '-N', '-B']
                           + (['-D', creds['database']] if needs_db else []) + ['-e', query],
                           capture_output=True)
        return p.returncode == 0, (p.stdout if p.returncode == 0 else p.stderr).decode('utf-8', 'replace').strip()
    finally:
        os.remove(cnf)


def db_exists():
    good, out = sql_query("SHOW DATABASES LIKE '%s'" % creds['database'].replace("'", ''))
    return good and out.strip() == creds['database']


def create_db():
    good, out = sql_query('CREATE DATABASE IF NOT EXISTS `%s` DEFAULT CHARACTER SET utf8mb4' % creds['database'])
    if not good:
        err('Could not create database: ' + out)
    return good


def test_connection():
    good, out = sql_query('SELECT VERSION()')
    if good:
        ok('Connected to %s@%s:%d (server %s)' % (creds['database'], creds['host'], creds['port'], out))
    else:
        err('Connection failed: ' + out)
        if 'Access denied' in out:
            err('Check mysql_login / mysql_password in ' + creds['conf'])
    return good


# ----------------------------------------------------------------------------
# file lists
# ----------------------------------------------------------------------------
def fetch_files():
    import_files.clear()
    backups.clear()
    if os.path.isdir(SQL_DIR):
        names = [f for f in os.listdir(SQL_DIR)
                 if f.lower().endswith('.sql') and os.path.isfile(os.path.join(SQL_DIR, f))]
        names.sort(key=str.lower)
        if 'triggers.sql' in names:            # triggers must go after their tables
            names.append(names.pop(names.index('triggers.sql')))
        import_files.extend(names)
    if os.path.isdir(BACKUP_DIR):
        backups.extend(sorted(f for f in os.listdir(BACKUP_DIR) if f.lower().endswith('.sql')))


def sql_path(name):
    return name if os.path.isabs(name) else os.path.join(SQL_DIR, name)


# ----------------------------------------------------------------------------
# core operations
# ----------------------------------------------------------------------------
def import_file(path):
    """Import one .sql file. Returns True on success."""
    full = sql_path(path)
    print('Importing %s...' % os.path.basename(full))
    rc, stderr = run_tool('mysql', [creds['database']], stdin_path=full)
    if rc != 0:
        err('  FAILED: ' + (stderr or 'exit code %d' % rc))
        log_error('%s: %s' % (full, stderr))
        return False
    return True


def backup_db(silent=False, lite=False):
    """Dump the database into sql/backups. Returns the file path or None."""
    if not (silent or yes('Would you like to backup your database?')):
        return None
    if not _tool('mysqldump'):
        err('mysqldump not found. Set the MySQL bin folder in Settings.')
        return None
    os.makedirs(BACKUP_DIR, exist_ok=True)
    stamp = time.strftime('%Y%m%d-%H%M%S')
    out = os.path.join(BACKUP_DIR, '%s-%s%s.sql' % (creds['database'], stamp, '-lite' if lite else ''))
    args = ['--hex-blob', '--add-drop-trigger', '--routines', creds['database']]
    if lite:
        good, listing = sql_query('SHOW TABLES')
        have = set(listing.split()) if good else set()
        tables = [t[:-4] for t in player_data if t[:-4] in have]   # skip tables this schema lacks
        if not tables:
            err('No player-data tables found in the database.')
            return None
        args += tables
    rc, stderr = run_tool('mysqldump', args, stdout_path=out)
    if rc != 0:
        err('Backup FAILED: ' + (stderr or 'exit code %d' % rc))
        log_error('backup: ' + stderr)
        if os.path.isfile(out):
            os.remove(out)
        return None
    if stderr:
        log_error('backup: ' + stderr)
    ok('Database saved: %s (%.1f MB)' % (out, os.path.getsize(out) / 1048576))
    return out


def _import_list(files):
    failed = [f for f in files if not import_file(f)]
    if failed:
        err('\n%d file(s) failed: %s' % (len(failed), ', '.join(failed)))
        err('Details in ' + ERROR_LOG)
    else:
        ok('Finished importing!')
    return not failed


def update_db(silent=False):
    """Import every non-player SQL file (backs up first)."""
    if not silent or auto_backup:
        if not backup_db(silent) and not silent and not yes('Backup skipped/failed. Continue anyway?'):
            return
    fetch_files()
    todo = [f for f in import_files if f not in player_data]
    if not silent:
        ok('The following %d files will be imported:' % len(todo))
        print(', '.join(todo))
        if not yes('Proceed with update?'):
            return
    _import_list(todo)


def setup_db(silent=False):
    """Create the DB if needed, import every SQL file (including player tables)."""
    if not create_db():
        return False
    fetch_files()
    return _import_list(list(import_files))


def resolve_backup(name):
    for cand in (name, name + '.sql', os.path.join(BACKUP_DIR, name), os.path.join(BACKUP_DIR, name + '.sql')):
        if os.path.isfile(cand):
            return os.path.abspath(cand)
    return None


def restore_backup(path=None, silent=False):
    """Import a backup (or any .sql) file. Interactive picker when path is None."""
    fetch_files()
    if path is None:
        if not backups:
            warn('No backups found in ' + BACKUP_DIR)
            path = ask('Path of a .sql file to import (blank to cancel): ').strip().strip('"')
            if not path:
                return
        else:
            while True:
                for i, b in enumerate(backups):
                    print(Fore.GREEN + str(i + 1) + Style.RESET_ALL + '. ' + b)
                choice = ask('Number to import, "delete #" to delete, or a file path (blank to cancel).\n> ').strip().strip('"')
                if not choice:
                    return
                m = re.match(r'^delete (\d+)$', choice)
                if m and 0 < int(m.group(1)) <= len(backups):
                    target = backups[int(m.group(1)) - 1]
                    if yes('Delete %s?' % target):
                        os.remove(os.path.join(BACKUP_DIR, target))
                        fetch_files()
                    continue
                if choice.isdigit() and 0 < int(choice) <= len(backups):
                    path = backups[int(choice) - 1]
                    break
                if resolve_backup(choice):
                    path = choice
                    break
                bad_selection()
    full = resolve_backup(path)
    if not full:
        err('File not found: ' + path)
        return
    if not silent:
        if not yes('Import %s into %s?' % (os.path.basename(full), creds['database'])):
            return
        backup_db(False)
    if not db_exists() and not create_db():
        return
    if import_file(full):
        ok('Finished importing!')


def reset_db(silent=False):
    if not silent:
        backup_db()
        err('Are you sure you want to reset your database to default?')
        if ask('Type "reset %s" to confirm.\n> ' % creds['database']).strip() != 'reset ' + creds['database']:
            return
    setup_db(True)


def show_check():
    print('Root        :', ROOT)
    print('Config      :', creds.get('conf'))
    print('Database    : %(database)s @ %(host)s:%(port)s as %(login)s' % creds)
    print('mysql       :', _tool('mysql') or 'NOT FOUND')
    print('mysqldump   :', _tool('mysqldump') or 'NOT FOUND')
    fetch_files()
    print('SQL files   : %d (%d protected)' % (len(import_files), len([f for f in import_files if f in player_data])))
    print('Backups     : %d in %s' % (len(backups), BACKUP_DIR))
    if _tool('mysql'):
        test_connection()


# ----------------------------------------------------------------------------
# menu
# ----------------------------------------------------------------------------
def bad_selection():
    err('Invalid selection.')
    time.sleep(0.5)


def adjust_imports():
    while True:
        ok('Protected files (never imported by Update):')
        for i, f in enumerate(player_data):
            print(Fore.GREEN + str(i + 1) + Style.RESET_ALL + '. ' + f)
        choice = ask('Number to remove from this list, or a file name to add (blank to finish).\n> ').strip()
        if not choice:
            return
        if choice.isdigit() and 0 < int(choice) <= len(player_data):
            player_data.pop(int(choice) - 1)
        elif choice not in player_data:
            player_data.append(choice)


def settings():
    global auto_backup
    print(Fore.GREEN + 'MySQL bin location: ' + Style.RESET_ALL + (mysql_bin or '(PATH)'))
    if yes('Change this location?'):
        adjust_mysql_bin()
    print(Fore.GREEN + 'Automatic backup for command line updates: ' + Style.RESET_ALL + str(auto_backup))
    if yes('Toggle this?'):
        auto_backup = not auto_backup
    adjust_imports()
    write_configs()


def import_any_file():
    p = ask('Path of the .sql file to import (blank to cancel): ').strip().strip('"')
    if p:
        restore_backup(p)


def menu():
    w = 30
    line = Fore.GREEN + 'o' + Fore.RED + '-' * w + Fore.GREEN + 'o'
    print(line)
    print(Fore.RED + '|' + Style.RESET_ALL + 'DSP Database Management Tool'.center(w) + Fore.RED + '|')
    print(Fore.RED + '|' + Style.RESET_ALL + ('Connected to ' + creds['database']).center(w) + Fore.RED + '|')
    print(line)
    for key, label in [('1', 'Update DB (import SQL)'), ('2', 'Backup (full)'), ('3', 'Backup (lite/player)'),
                       ('4', 'Restore from backup'), ('5', 'Import a .sql file'), ('r', 'Reset DB'),
                       ('c', 'Check config'), ('s', 'Settings'), ('q', 'Quit')]:
        print(Fore.RED + '|' + Fore.GREEN + key + Style.RESET_ALL + '. ' + label.ljust(w - 3) + Fore.RED + '|')
    print(line)


def main():
    argv = [a for a in sys.argv[1:]]
    if not fetch_credentials():
        return 1
    fetch_configs()
    if not find_mysql_bin():
        warn('MySQL/MariaDB client tools not found automatically.')
        if sys.stdin.isatty() and adjust_mysql_bin():
            write_configs()
        else:
            err('Set mysql_bin in ' + CONFIG_YAML + ' or add the MySQL bin folder to PATH.')
            return 1
    else:
        # remember what we found so it's stable next run
        if mysql_bin and yaml and not os.path.isfile(CONFIG_YAML):
            write_configs()

    if argv:
        cmd = argv[0].lower()
        arg = argv[1] if len(argv) > 1 else ''
        if cmd == 'backup':
            return 0 if backup_db(True, arg == 'lite') else 1
        if cmd == 'update':
            if not db_exists():
                err('Database %s does not exist. Run: DBtool.py setup %s' % (creds['database'], creds['database']))
                return 1
            update_db(True)
            return 0
        if cmd in ('restore', 'import'):
            if not arg:
                err('Usage: DBtool.py restore <file>')
                return 1
            restore_backup(arg, silent=True)
            return 0
        if cmd in ('setup', 'reset'):
            if arg != creds['database']:
                err('Confirm by passing the database name: DBtool.py %s %s' % (cmd, creds['database']))
                return 1
            if cmd == 'reset' and db_exists():
                backup_db(True)
            return 0 if setup_db(True) else 1
        if cmd == 'check':
            show_check()
            return 0
        print(__doc__)
        return 1

    # interactive
    if colorama:
        print(colorama.ansi.clear_screen())
    if not db_exists():
        err('Database %s does not exist.' % creds['database'])
        if yes('Create it and import all SQL files now?'):
            setup_db()
        else:
            test_connection()
    actions = {'1': update_db, '2': backup_db, '3': lambda: backup_db(False, True),
               '4': restore_backup, '5': import_any_file, 'r': reset_db, 'c': show_check, 's': settings}
    while True:
        menu()
        sel = ask('> ').strip().lower()
        if colorama:
            print(colorama.ansi.clear_screen())
        if sel == 'q' or (sel == '' and not sys.stdin.isatty()):
            return 0
        actions.get(sel, bad_selection)()
        if sel in actions:
            ask('\nPress Enter to continue...')
            if colorama:
                print(colorama.ansi.clear_screen())


if __name__ == '__main__':
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print()
