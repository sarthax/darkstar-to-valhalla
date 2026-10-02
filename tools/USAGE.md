# DSP Database Management Tool - Usage Guide

## Overview

This tool has been copied and modified from Topaz to work with your DarkStar Project (DSP) server at `D:\Claude\old-dsp-reference`. It provides safe database backup, update, and restore functionality.

## Files Created

| File | Purpose |
|------|---------|
| `DBtool.py` | Main Python tool for database management |
| `DBtool.bat` | Launcher batch file with Python path handling |
| `backup.bat` | Quick backup script (optional) |
| `restore.bat` | Restore/Import script (optional) |
| `requirements.txt` | Python dependencies |
| `config.yaml` | Tool configuration |
| `README.md` | Full documentation |

## Setup Instructions

### 1. Install Python Dependencies

```cmd
cd D:\Claude\old-dsp-reference\tools
pip install -r requirements.txt
```

### 2. Verify MySQL Installation

The tool will either find MySQL in your PATH or prompt you for the path.

Common locations:
- `C:\Program Files\MySQL\bin\`
- `C:\Program Files\MariaDB XX\bin\`

If needed, add the MySQL bin directory to your PATH or configure it in the tool.

### 3. Ensure Config File Exists

The tool reads from `..\conf\map_darkstar.conf`. If this doesn't exist, you can use `..\conf\map.conf` instead - the tool will fall back to that path.

Make sure your config includes:
```ini
mysql_database = your_database_name
mysql_host = localhost
mysql_port = 3306
mysql_login = root
mysql_password = your_password
```

## Usage

### Interactive Mode (Recommended)

```cmd
cd D:\Claude\old-dsp-reference\tools
DBtool.bat
```

This launches the interactive menu where you can:
- Update database with automatic backup
- Check for migrations
- Create backups
- Restore from backups
- Configure settings
- Quit

### Quick Commands

```cmd
REM Backup database (no confirmation needed)
cd D:\Claude\old-dsp-reference\tools
DBtool.bat backup

REM Check for pending migrations  
DBtool.bat migrate

REM Full update with backup
DBtool.bat update
```

### Using Helper Scripts

**Quick Backup:**
```cmd
backup.bat              REM Full backup (prompts)
backup.bat lite        REM Lite backup (character data only)
```

**Restore from Backup:**
```cmd
restore.bat            REM Shows available backups, lets you choose
restore.bat filename.sql  REM Restore specific file directly
```

## Safety Features

### Automatic Backups
- Database is backed up automatically before any update operation
- Lite backup option for faster backups (character tables only)
- Full backup includes all database objects

### Protected Data
- Character data tables are preserved during updates
- Accounts and critical system tables are protected
- User credentials never stored in command history

### Version Tracking
- Current database version is tracked in `..\conf\version.conf`
- Prevents applying old migrations to newer databases
- Warns if trying to restore a backup from an incompatible version

### Confirmation Required
- All destructive operations require explicit confirmation
- Reset option warns about data loss before proceeding

## Backup Types

### Full Backup (Default)
- Includes all tables, triggers, stored procedures
- Structure and data
- Named with timestamp and version hash
- Example: `database-20260916-143022-hash.sql`

### Lite Backup
- Only character-related tables
- Faster for large databases
- Useful for testing/verification
- Named: `database-timestamp-lite.sql`

## Restoration Process

1. **Create a fresh backup** (always recommended first)
   ```cmd
   DBtool.bat backup
   ```

2. **(Optional) Update version tracking** if restoring from old backups:
   - Edit `..\conf\version.conf` and set `DB_VER:` to match backup filename hash

3. **Import the backup**
   ```cmd
   DBtool.bat restore
   # Or specify file directly
   DBtool.bat restore 2024-12-31.sql
   ```

## Customization

### Adding Custom Migrations

Edit `DBtool.py` and add new migration functions:

```python
from migrations import your_custom_migration

migrations = [
    # ... existing migrations
    your_custom_migration,
]
```

### Changing Backup Location

Edit `DBtool.py`:
```python
# Change backup directory path
backup_dir = '../sql/backups'  # Modify as needed
```

### Modifying Protected Tables

Edit the `player_data` list in `DBtool.py` to add/remove protected tables.

## Troubleshooting

### Python Not Found
```cmd
REM Check if Python is installed
where python

REM If not, install Python from https://python.org
```

### MySQL Connection Failed
- Verify credentials in `..\conf\map_darkstar.conf`
- Ensure MySQL server is running
- Check firewall allows connection to MySQL port (default 3306)

### Permission Errors
```cmd
REM Grant execute permissions
icacls "D:\Claude\old-dsp-reference\tools" /grant YourUser:F
```

### Import Failed
Check `error.log` in the tools directory for MySQL error messages. Common issues:
- Foreign key constraint violations
- Missing required tables
- Version incompatibility (check DB_VER in config)

## Important Notes

1. **Always backup before major operations** - Even with automatic backups, manual backup recommended for critical updates

2. **Don't modify running database files directly** - Use the tool to apply changes

3. **Character data is protected** - Tables in `player_data` list will never be overwritten during updates

4. **Version tracking matters** - Always check DB_VER before restoring old backups

5. **Lite vs Full backups** - Use lite backups for quick checks, full backups for disaster recovery

## File Locations

```
D:\Claude\old-dsp-reference\
├── conf/
│   ├── map_darkstar.conf    # Database credentials (modified from git)
│   └── version.conf         # Version tracking
├── sql/
│   ├── backups/             # Backup storage location
│   └── *.sql                # SQL files to import
└── tools/                   # This directory
    ├── DBtool.py           # Main tool
    ├── DBtool.bat          # Launcher
    ├── backup.bat          # Quick backup
    ├── restore.bat         # Quick restore
    ├── requirements.txt    # Python dependencies
    ├── config.yaml         # Tool configuration
    └── README.md           # Full documentation
```

## Support

For issues, check:
1. `error.log` in tools directory
2. MySQL error logs in your MySQL installation directory
3. Git status for any unexpected file changes

---

**Remember**: When working with a live database, always test procedures on a backup first!
