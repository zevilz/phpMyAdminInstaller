# phpMyAdminInstaller [![Version](https://img.shields.io/badge/version-v2.0.0-brightgreen.svg)](https://github.com/zevilz/PhpMyAdminInstaller/releases/tag/2.0.0)

Simple bash script for install and configure phpMyAdmin. The script download it specified version from [www.phpmyadmin.net/downloads/](https://www.phpmyadmin.net/downloads/).

## Requirements

- wget

## Usage

Notices:
- installed versions from repositories must be removed before using script if you install phpMyAdmin in the same directory (recommended);
- there is no need to delete PhpMyAdmin installed with this script, old versions will be backupped in the same directory;
- the script must be run with sudo if current user is not root;
- Blowfish secret for authentification generate automatically durign installation and add to `$cfg['blowfish_secret']` in `/pma/working/directory/config.inc.php`;
- `setup` directory deleting after installation for security issues;
- you may combine options.

### Options

- -h (--help) - shows help message;
- -p (--path) - specify full path to phpMyAdmin directory (usage: `p <dir> | --path=<dir>`; `/usr/share/phpmyadmin` by default);
- -v (--version) - specify version of phpMyAdmin to install (usage: `-v <version> | --version=<version>`; latest version will be installed by default);
- -e (--english-only) - install english version (version with all language packs will be installed by default);
- -t (--temp-dir) - specify TEMP_DIR constant value ($cfg['TempDir']) that define directory for phpMyAdmin template caches (usage: `-t <value> | --temp-dir=<value>`; `'./tmp/'` by default)
- -u (--user) - specify owner (user) of phpMyAdmin directory (usage: `-u <user> | --user=<user>`; it is inherited from parent directory owner by default);
- -g (--group) - specify owner (group) of phpMyAdmin directory (usage: `-g <group> | --group=<group>`; it is inherited from parent directory owner by default);
- -f (--force) - force reinstall phpMyAdmin if current version already installed;
- -q (--quiet) - execute the script without any users actions (enabled in cron usage by default);
- -d (--debug) - show disabled output of commands.

### Direct usage

```bash
bash pma_installer.sh
```

or

```bash
chmod +x pma_installer.sh
./pma_installer.sh
```

Then create database for PhpMyAdmin in web interface (`<pma_url>/chk_rel.php`) if it not exists yet (required for full functionality). You will see related warning with link in the bottom of page.

### Custom phpMyAdmin working directory

Working directory is `/usr/share/phpmyadmin` by default. You may change it using `-p (--path)` option. End slash in path say to the script create directory `phpmyadmin` in selected directory.

Example:

```bash
# working directory will be /some/directory/phpmyadmin
bash pma_installer.sh -p /some/directory/

# working directory will be /some/directory/pma
bash pma_installer.sh -p /some/directory/pma
```

Notices:
- the script inherit permissions to all phpMyAdmin files and folders from parent directory;
- parent directory must be exist.

### TEMP_DIR value

`TEMP_DIR` constant ($cfg['TempDir']) define derectory for phpMyAdmin template caches (the constant define in `/pma/working/directory/libraries/vendor_config.php`). Default value is `'./tmp/'` (`/pma/working/directory/tmp`). No need create it if phpMyAdmin will be installed only for specific user, and current user that run phpMyAdmin have write access to it directory. It will be created automatically. You may change it location using `-t (--temp-dir)` option.

Example:

```bash
bash pma_installer.sh -t "'/home/user/tmp/pma'"
```

But users haven't access to it directory if phpMyAdmin will be installed for all users in system directories that owner is root. The script automatically create this directory in working phpMyAdmin directory with write access for all users (`777`) if directory owner is `root` and `TEMP_DIR` constant value is `'./tmp/'`. This is not recommended because it might impose risk of other users on system reading and writing data in this directory. You may create separate directories for each user.

Example:

```bash
bash pma_installer.sh -t "'/home/' . \$_SERVER['USER'] . '/tmp/pma/'"
```

Notices:

- value must be in double quotes;
- php vars and double quotes inside value must be escaped by backslash.

### User and group

User and group is inherited from parent directory owner by default. Use `-u (--user)` and `-g (--group)` option if you want change them or one of it.

Examples:

```bash
# Change both
bash pma_installer.sh -u someuser -g somegroup

# Change only user
bash pma_installer.sh -u someuser

# Change only group
bash pma_installer.sh -g somegroup

``` 

## Cron usage

Cron usage same as direct usage except `-q (--quiet)` option. User actions disabled by default for cron usage.

Example:

```bash
0 0 * * 1 /bin/bash /path/to/script/pma_installer.sh [options]
```

You must add sudo permissions to the script in `/etc/sudoers` if you have sudo access and will added cron job not in root crontab.

Example:

```bash
someuser ALL=(ALL) NOPASSWD: sudo /bin/bash /path/to/script/pma_installer.sh [options]
```

Then add `sudo` before command in cron job.

Example:

```bash
0 0 * * 1 sudo /bin/bash /path/to/script/pma_installer.sh [options]
```

## Changelog

- 2018.09.08 - 2.0.0 - [a lot of changes and code refactoring](https://github.com/zevilz/PhpMyAdminInstaller/releases/tag/2.0.0)
- 2018.09.04 - 1.1.0 - [bug fixes and refactoring](https://github.com/zevilz/PhpMyAdminInstaller/releases/tag/1.1.0)
- 2018.09.03 - 1.0.0 - released
