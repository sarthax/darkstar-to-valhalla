# DSP Database Management Tool

A database management utility for DarkStar Project (DSP) server at `D:\Claude\old-dsp-reference`.

## Features

- **Backup**: Create full or lite SQL backups of your database
- **Update**: Apply database migrations and updates safely
- **Import**: Restore from backup files
- **Reset**: Reset database to default state (with backup first!)
- **Lite Backup**: Export only character data for faster backups

## Installation

### 1. Install Dependencies

```cmd
cd D:\Claude\old-dsp-reference\tools
pip install -r requirements.txt
```

### 2. Ensure MySQL is Available

Make sure MySQL client binaries are in your PATH or will be prompted when needed.

## Usage

### Quick Commands

```cmd
REM Run interactive menu
DBtool.bat

REM Backup database (requires confirmation)
DBtool.bat backup

REM Check for migrations
DBtool.bat migrate

REM Update database (full update with backup)
DBtool.bat update
```

### Interactive Menu Options

1. **Update DB** - Apply database updates with automatic backup
2. **Check Migrations** - Review pending migrations
3. **Backup** - Create full database backup
4. **Restore/Import** - Restore from a previous backup
5. **r** - Reset database to default (WARNING: destructive!)
6. **s** - Settings and configuration
7. **q** - Quit

## Important Notes

### Safety Features

- **Automatic Backups**: Database is backed up before any update operation
- **Protected Tables**: Character data tables are preserved during updates
- **Version Tracking**: DB version is tracked to prevent applying old migrations

### Backup Types

- **Full Backup**: Complete database with all tables, structure, and data
- **Lite Backup**: Only character-related tables (faster for large databases)

### File Locations

- **Config**: `..\conf\map_darkstar.conf` - Database credentials
- **Version**: `..\conf\version.conf` or `..\conf\default\version.conf` - Version tracking
- **SQL Files**: `..\sql\*` - Database SQL files
- **Backups**: `..\sql\backups\` - Backup storage location

## Configuration

Edit `config.yaml` (if it exists) to customize:

```yaml
mysql_bin: "C:\Program Files\MySQL\bin\"  # MySQL bin directory
auto_backup: true                        # Automatically backup before updates
auto_update_client: true                 # Auto-update client version
```

Or configure interactively via the Settings menu option.

## Troubleshooting

### Error: Database not found
- Ensure `mysql_database` is set in `..\conf\map_darkstar.conf`
- Create with: `DBtool.bat setup <database_name>`

### Error: MySQL connection failed
- Check credentials in config file
- Verify MySQL server is running and accessible
- Check firewall settings

### Permission denied on SQL files
- Ensure Python has read/execute permissions on the SQL files directory

## License

This tool is modified from the Topaz project. Please respect original licensing terms.

---

**Remember**: Always test updates on a copy of your database first!
