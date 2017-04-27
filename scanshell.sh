#!/bin/bash
# This script is used for detect webshell in server
# Release 06-12-2012
# Usage: ./scanshell.sh [all|user|path] time

# Define log file locations:
LOGDIR="/tmp"
DATE=`date +"%d-%m-%H:%M"`
LOGFILE="$LOGDIR/${DATE}.log"
TEMPFILE=`mktemp`

# egrep default options:
OP="il"

# Define shell's signatures:
# PATTERN1: PHP upload file
PATTERN_PHP_UPLOAD="move_uploaded_file"

# PATTERN2: PHP SHELL
PATTERN_PHP_SHELL="base.+decode|eval\(|gzuncompress\(base64_decode\(|gzinflate\(base64_decode\(|eval\(gzinflate\(base64_decode\(|\/etc\/passwd|admin123456|'FilesMan'|Bypass Safe_Mode And Open_basedir|fakesymlink|webadmin\.php|r57shell|bypass safe_mode|bypass open_basedir|KioqKioqKioq|eval\(base64_decode\(|base64_decode\(|preg_replace\(\"/\.\*/e\""

# PATTERN3: PERL SHELL
PATTERN_PERL_SHELL="CGI-Telnet|CGI-Shell|ShellExecute|Gamma Web Shell|PerlKit"
EXCLUDE_EXT='b(mp|z2?)|css|d(b|iff|ocx?)|g(if|z)|s?html?|i(co|ni)|j(pe?g|s)|log|m(o|p3)|p(df|hp|ng|o|ptx?)|s(ql|wf)|t(tf|xt)|url|x(ml|lsx?)|zip|rtf|ht(access|passwd)|ftpquota'
EXCLUDE_FILE='c(opying|hangelogs?)|readme|(error|access)_log|license|todo|news|install'

# PATTERN4: .htaccess AND php.ini
PATTERN_HTACCESS_PHPINI="addhandler|sethandler|php-value|followsymlinks|safe_mode|disable"

# PATTERN6: PHP malicious functions
PATTERN_PHP_REQUEST="\\\$_(POST|GET|REQUEST)"
PATTERN_PHP_FUNC="(\s|\(|^)(system\(|shell_exec\(|exec\(|passthru\(|eval\()"


function log() {
	echo "$*" | tee -a $TEMPFILE
}

function parseOptions() {
	all_cpanel=0
	
	while [[ ! -z $1 ]]
	do
		option=$1
		shift
		
		case "$option" in
			-v )
				OP="Hin --color"
				;;
			-single )
				path=$1
				shift
				;;
			-cpanel )
				user=$1
				shift
				if [[ "$user" != "all" ]]
				then
					path="/home/$user/public_html"
				else
					all_cpanel=1
				fi
				;;
			-time )
				time=$1
				shift
				;;
			* )
				echo "Invalid Option: \"$option\""
				help
		esac
	done
	
	if [[ "$all_cpanel" -eq 1 ]] && [[ ! -z "$time" ]]
	then
		scan_all_cpanel
	else
		if [[ -z "$path" ]] || [[ -z "$time" ]]
		then
			echo "Invalid input"
			help
		else
			scan $path $time
		fi
	fi
}

function help() {
	echo "Usage: 	./$0 -cpanel user -time all
	./$0 -v -cpanel user -time -2
	./$0 -single /home/user/public_html -time all
	./$0 -v -single /home/user/public_html -time -2"

	exit 1
}

function scan() {
	if [[ "$time" == "all" ]]
	then
		# Scan without mtime
		log "[+] No time defined - Scan all files"
		
		# Scan PHP upload
		log "[+] Scan PHP upload files"
		find $path -type f -name "*.php*" -exec egrep -$OP "$PATTERN_PHP_UPLOAD" '{}' \; 
		
		# Scan PHP shell
		log "[+] Scan PHP Shell"
		find $path -type f -name "*.php*" -exec egrep  -$OP "$PATTERN_PHP_SHELL" '{}' \; 
		
		# Scan Perl shell
		log "[+] Scan PERL Shell"
		find $path -regextype posix-extended -type f -not \( -iregex ".*\.(${EXCLUDE_EXT})" -o -iregex ".*(${EXCLUDE_FILE})" \) -exec file {} \; | grep -i perl | cut -d":" -f 1 | xargs -d"\n" egrep -$OP "$PATTERN_PERL_SHELL" 
		
		# Scan malicious .htaccess
		log "[+] Scan Malicious .htaccess and php.ini"
		find $path -type f \( -name ".htaccess" -o -name "php.ini" \) -exec egrep -$OP "$PATTERN_HTACCESS_PHPINI" '{}' \; 
		
		# Scan PHP malicious functions
#		log "[+] Scan PHP malicious functions"
#		find $path -type f -name "*.php" -exec egrep -Hn --color=auto -A 2 "$PATTERN_PHP_REQUEST" '{}' \;
	else
		log "[+] Time: $time"
		
		# Scan PHP upload
		log "[+] Scan PHP upload files"
		find $path -type f -name "*.php*" -mtime $time -exec egrep -$OP "$PATTERN_PHP_UPLOAD" '{}' \; 
		
		# Scan PHP Shell
		log "[+] Scan PHP Shell"
		find $path -type f -name "*.php*" -mtime $time -exec egrep -$OP "$PATTERN_PHP_SHELL" '{}' \; 
		
		# Scan Perl shell
		log "[+] Scan PERL Shell"
		find $path -regextype posix-extended -type f -mtime $time -not \( -iregex ".*\.(${EXCLUDE_EXT})" -o -iregex ".*(${EXCLUDE_FILE})" \) -exec file '{}' \; | grep -i perl | cut -d":" -f1 | xargs -d"\n" egrep -$OP "$PATTERN_PERL_SHELL" 
		
		# Scan malicious .htaccess
		log "[+] Scan Malicious .htaccess and php.ini"
		find $path -type f -name ".htaccess" -o -name "php.ini" -mtime $time -exec egrep -$OP "$PATTERN_HTACCESS_PHPINI" '{}' \; 
 	fi
}

function scan_all_cpanel() {
	log "Scan all account cPanel"
	for cpanel_user in `ls -A /var/cpanel/users | grep -v "./"`
	do
		path="/home/$cpanel_user/public_html"
		log "Scanning user \"$cpanel_user\": \"$path\""
		scan $path $time
		log "======================================="
	done
}

parseOptions $@

