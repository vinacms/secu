# secu
- @author: NguyenTuanSieu
- @email: dev.phpjs@gmail.com

### Reset password root
```
$>mysqld_safe --skip-grant-tables
$>mysql -uroot
$>ALTER USER 'root'@'localhost' IDENTIFIED BY 'MrSi3u@#!';
----------or-----------
$>UPDATE mysql.user SET authentication_string = PASSWORD('MrSi3u@#!'), password_expired = 'N' WHERE User = 'root' AND Host = 'localhost';
--------MySQL 5.7.5 and earlier
$>SET PASSWORD FOR 'root'@'localhost' = PASSWORD('MrSi3u@#!');
$>FLUSH PRIVILEGES;
```
### Scan Shell

```
$>bash scanshell.sh  -v -single /home/ -time all
$>ngrep "^POST" | grep -i --color "host.+conn"
```

### Setup Apache2, PHP, MySQL, Composer

```
$>chmod +x setup.sh
$>./setup.sh
```

### Create virtual host

```
$>chmod +x vhosts.sh
$>sudo ./vhosts.sh create bds3mien.com bds3mien
```
### Create hosts domain in windows

```
$>./hosts.bat domain.dev
```
### Turn on or off Hyper-V

```
#Off
$>bcdedit /set hypervisorlaunchtype off
#On
$>bcdedit /set hypervisorlaunchtype auto
```

### Find top 10 large files

```
$>for i in G M K; do du -ah | grep [0-9]$i | sort -nr -k 1; done | head -n 11
```

### Display error PHP

```php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
```

### Disabled views vendors

```.htaccess
Require all denied
Order deny,allow
Deny from all
```

### Disable execute PHP

```.htaccess
<IfModule mod_php5.c>
  php_flag engine off
</IfModule>
<Files *.php>
deny from all
</Files>
```
