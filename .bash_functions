#!/bin/bash
##########
#
# BASH FUNCTIONS
#



# sops
sopsenc() {
	local files=${@} file newfile extension
	for file in $files; do
		if [[ $file =~ \.enc\. ]]; then
			newfile=$(echo "$file" | sed -r "s/\.enc\./.clear./g")
			sops -d $file > $newfile
		else
			extension=${file##*.}
			newfile="${file%.*}.enc.$extension"
			sops -e $file > $newfile
		fi
	done
}




# bdiff - BETTER DIFF (COLORIZED & SIDE BY SIDE)
function bdiff() {
	local FILE1="$1" FILE2="$2"
	[[ ! -x "$(which diff 2>/dev/null)" ]] && echo "ERROR: diff not installed" && return 1
	{ [[ -z "$FILE1" ]] || [[ -z "$FILE2" ]] ; } && echo "ERROR: please provide two files to compare" && return 2
	if [[ -x "$(which ydiff 2>/dev/null)" ]]; then
		diff -u1 "$FILE1" "$FILE2" |ydiff -s -w0 -t2
	elif [[ -x "$(which cdiff 2>/dev/null)" ]]; then
		diff -yW $COLUMNS "$FILE1" "$FILE2" |cdiff
	else
		echo "NOTICE: neither ydiff nor cdiff installed, falling back to regular uncolored side-by-side diff"
		diff -yW $COLUMNS "$FILE1" "$FILE2"
	fi
}



# showcert - CHECK SSL CERTIFICATE FOR GIVEN DOMAIN(S)
#   example: showcert www.compositiv.com
function showcert() {
	local OUT ERR=0 DOMAIN DOMAINS="${@}"
	for DOMAIN in $DOMAINS; do
		OUT=$(openssl s_client -showcerts -servername $DOMAIN -connect $DOMAIN:443 </dev/null 2>&1)
		[[ $? -ne 0 ]] && let ERR++ && echo "ERROR: openssl returned error:" && echo "$OUT" && continue
		printf "\e[01;36m${DOMAIN^^}\e[0m `tput smul`CERTIFICATE CHAIN (RAW)`tput rmul`:\n\n" && echo "$OUT" && printf "\n\n\n\e[01;36m${DOMAIN^^}\e[0m `tput smul`CERTIFICATE PROPERTIES`tput rmul`:\n\n" && echo "$OUT" |openssl x509 -noout -text
	done
	return $ERR
}



# esindices - GET ELASTICSEARCH INDEX STATUS FROM $ESINSTANCE
#   example: esindices 127.0.0.3:9205
#            esindices 127.0.0.2
#            esindices
#
function esindices() {
	local ESINSTANCE=$(esaddr "${@}")

	printf "Checking $ESINSTANCE...\n\n"
	wget -qO- http://$ESINSTANCE/_cat/indices
}



# eshealth - GET ELASTICSEARCH HEALTH STATUS FROM $ESINSTANCE
#   example: eshealth 127.0.0.3:9205
#            eshealth 127.0.0.2
#            eshealth
#
function eshealth() {
	local ESINSTANCE=$(esaddr "${@}")

	printf "Checking $ESINSTANCE...\n\n"
	wget -qO- http://$ESINSTANCE/_cluster/health?pretty=true
}



# esaddr - GET ELASTICSEARCH ADDRESS FROM INPUT, $ES OR /ETC/ELASTICSEARCH/ELASTICSEARCH.YML
#   example: esaddr 127.0.0.3:9205
#            esaddr 127.0.0.2
#            esaddr
#
function esaddr() {
	local ESINSTANCE
	if [[ -n "$1" ]]; then
		if [[ "$1" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(:[0-9]+)?$ ]]; then
			if [[ "$1" == "${1//:[0-9]*/}" ]]; then
				ESINSTANCE="$1:9200"
			else
				ESINSTANCE="$1"
			fi
		else
			echo "Invalid input format. Please specify ipaddress or ipaddress:port or leave empty."
			return 1
		fi
	elif [[ -n "$ES" ]]; then
		if [[ "$ES" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(:[0-9]+)?$ ]]; then
			if [[ "$ES" == "${ES//:[0-9]*/}" ]]; then
				ESINSTANCE="$ES:9200"
			else
				ESINSTANCE="$ES"
			fi
		fi
	else
		if [[ -n "$(grep -P '^\s*network\.host:' /etc/elasticsearch/elasticsearch.yml 2>/dev/null)" ]] && \
		   [[ -n "$(grep -P '^\s*http\.port:' /etc/elasticsearch/elasticsearch.yml 2>/dev/null)" ]]; then
			local ESHOST=$(grep -P '^\s*network\.host:' /etc/elasticsearch/elasticsearch.yml 2>/dev/null |cut -d':' -f2 |tr -d '[:space:]')
			local ESPORT=$(grep -P '^\s*http\.port:' /etc/elasticsearch/elasticsearch.yml 2>/dev/null |cut -d':' -f2 |tr -d '[:space:]')
			ESINSTANCE="$ESHOST:$ESPORT"
		else
			ESINSTANCE="127.0.0.1:9200"
		fi
	fi

	echo "$ESINSTANCE"
}



# sshtunnel - OPEN AN SSH TUNNEL AND RUN IT IN THE BACKGROUND
#   example: sshtunnel <tunnelserver> <localport> <tunneltarget> <targetport>
#            sshtunnel myserver.com 50080 127.0.0.1 80
#
function sshtunnel() {
	if [[ -z "$1" ]] || [[ -z "$2" ]] || [[ -z "$3" ]] || [[ -z "$4" ]]; then
		printf "Missing arguments! Usage:\n  sshtunnel <tunnelserver> <localport> <tunneltarget> <targetport>\n  sshtunnel myserver.com 50080 127.0.0.1 80\n"
		return 1
	else
		local SRV="$1"
		local TAR="$3"
		local LP="$2"
		local RP="$4"
		ssh -N -L $LP:$TAR:$RP $SRV &
	fi
}



# speedtest - TEST NETWORK SPEED WITH PYTHON SCRIPT FROM GITHUB
#
function speedtest() {
	if [[ -x $(which python) ]]; then
		echo
		curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py |python -
		echo
	else
		printf "No python executable found!\n"
		return 1
	fi
}



# ptk - AUTOMATICALLY KILL SQL QUERIES RUNNING LONGER THAN $1
#
function ptk() {
	if [[ -x $(which pt-kill) ]]; then
		if [[ "$1" == "-d" ]]; then
			pt-kill --daemonize --kill --busy-time=$2 --interval=5 --victims=all
			return $?
		else
			pt-kill --verbose --kill --busy-time=$1 --interval=5 --victims=all
			return $?
		fi
	else
		printf "No percona-toolkit installed or pt-kill not executable!\n"
		return 1
	fi
}



# comodoverify - CREATE FOLDER AND TEXT FILE FOR COMODO DOMAIN BASED VALIDATION
#   example: comodoverify 549E4A36482D01BBCE786613B22BCF62 9B1E75DA57DCD4DFCF793FC7B128377689A4D122CF1CA1616D0D7C3048B7EF6C
#
function comodoverify() {
	local MD5="$1"; local SHA="$2"; local VAL="$3"
	if [[ -n "$MD5" ]] && [[ -n "$SHA" ]]; then
		mkdir -p .well-known/pki-validation/
		printf "$SHA\ncomodoca.com\n" > .well-known/pki-validation/$MD5.txt
		if [[ -n "$VAL" ]]; then
			printf "$VAL\n" >> .well-known/pki-validation/$MD5.txt
		fi
		echo "URL:   /.well-known/pki-validation/$MD5.txt"
		return 0
	else
		echo "USAGE: comodoverify <CSR MD5 HASH> <CSR SHA256 HASH>"
		return 1
	fi
}



# whichweb - GET WEBUSER BY DOMAIN OR PARTIAL DOMAIN
#   example: whichweb compositiv
#
function whichweb() {
	GREP="${@}"
	RES=$(grep -ri "$GREP" /etc/apache2 /etc/nginx 2>/dev/null |grep -Ei 'Server(Name|Alias)')
	if [[ -n "$RES" ]]; then
		USRS=$(echo "$RES" |grep -Eo 'web[0-9]+' |sort -u |tr '\n' ' ')
		USRG=$(echo "$USRS" |head -n1)
		DOMS=$(echo "$RES" |grep -Po 'Server(Name|Alias)[ \t]([a-zA-Z0-9_-]+\.)+[a-zA-Z0-9_-]+' |sed -r 's/Server(Name|Alias)[ \t]//g' |sort -u |sed -r 's/^/         /g')
		printf "USERS:   $USRS\nDOMAINS:\n$DOMS\nGUESS:   $(hostname -f 2>/dev/null) / $USRG\n"
		return 0
	else
		printf "NO RESULTS!\n"
		return 1
	fi
}



# tunerupdate - UPDATE/INSTALL mysqltuner AND tuning-primer
#
function tunerupdate() {
	for DEL in $(find /usr/local/bin /usr/local/sbin -type f |grep -E 'mysqltuner|tuning-primer'); do
		if ! rm -fv $DEL &>/dev/null; then
			printf "Couldn't remove $DEL. Aborting.\n"
			return 13
		fi
	done

	if ! wget --no-check-certificate -qO'/usr/local/bin/mysqltuner' http://mysqltuner.pl &>/dev/null; then
		printf "Couldn't download mysqltuner. Aborting.\n"
		return 12
	fi
	if ! wget --no-check-certificate -qO'/usr/local/bin/tuning-primer' https://raw.githubusercontent.com/mattiabasone/tuning-primer/master/tuning-primer.sh &>/dev/null; then
		printf "Couldn't download tuning-primer. Aborting.\n"
		return 11
	fi

	for F in /usr/local/bin/mysqltuner /usr/local/bin/tuning-primer; do
		if ! ( chown root: $F &>/dev/null && chmod 750 $F &>/dev/null ); then
			printf "Couldn't set permissions on $F. Please fix manually.\n"
			return 10
		fi
	done

	printf "Installed /usr/local/bin/mysqltuner and /usr/local/bin/tuning-primer.\n"
	return 0
}



# ioncubeupdate - UPDATE ionCube LOADER TO CURRENT VERSION
#
function ioncubeupdate() {
	local CURRDIR=$(pwd)
	local TU='http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz'
	local TP='/tmp/ioncube_update'
	local TF='ioncube.tar.gz'

	if mkdir $TP &>/dev/null; then
		if wget $TU -O$TP/$TF &>/dev/null; then
			if cd $TP && tar -zxvf $TF &>/dev/null; then
				if [ -d /usr/share/ioncube ] || [ -f /usr/share/ioncube ]; then
					if cp -a /usr/share/ioncube /usr/share/ioncube.bak_$(date +%Y-%m-%d-%H-%M-%S) &>/dev/null; then
						if ! rm -rf /usr/share/ioncube &>/dev/null; then
							printf "ERROR: Couldn't remove /usr/share/ioncube - aborting!\n"
							cd $CURRDIR
							return 6
						fi
					else
						printf "ERROR: Couldn't create backup of /usr/share/ioncube - aborting!\n"
						cd $CURRDIR
						return 5
					fi
				fi

				if mv -f ioncube /usr/share/ &>/dev/null; then
					if chown -R root:root /usr/share/ioncube &>/dev/null; then
						printf "SUCCESS! ionCube has been updated. Default PHP version information:\n\n"
						$(which php) -v
					else
						printf "ERROR: Couldn't set owner on /usr/share/ioncube - please fix manually!\n"
						cd $CURRDIR
						return 7
					fi
				else
					printf "ERROR: Couldn't move ioncube to /usr/share/ioncube - please fix manually!\n"
					cd $CURRDIR
					return 4
				fi
			else
				printf "ERROR: Couldn't unpack tar file $TF - aborting!\n"
				cd $CURRDIR
				return 3
			fi
		else
			printf "ERROR: Couldn't download tar file from $TU - aborting!\n"
			rm -rf $TP &>/dev/null
			cd $CURRDIR
			return 2
		fi

		if ! rm -rf $TP &>/dev/null; then
			printf "\nERROR: Couldn't remove $TP for cleanup - please fix manually!\n"
			cd $CURRDIR
			return 8
		else
			cd $CURRDIR
			return 0
		fi
	else
		printf "ERROR: Couldn't create directory $TP - aborting!\n"
		cd $CURRDIR
		return 1
	fi
}



# lcreconfvhosts - RECONFIGURE WEB SERVER VHOSTS ON A LIVECONFIG SERVER
#
function lcreconfvhosts() {
	if [[ -f /etc/apache2/liveconfig.status || -f /etc/nginx/liveconfig.status ]]; then
		if [[ -z "$(dpkg -l sqlite3 2>/dev/null)" ]]; then
			DEBIAN_FRONTEND=noninteractive
			apt-get update 1>/dev/null
			apt-get install -y --force-yes sqlite3 1>/dev/null
		fi
		sqlite3 /var/lib/liveconfig/liveconfig.db "UPDATE HOSTINGCONTRACTS SET HC_REFRESHCFG=1000;"
		service liveconfig restart 1>/dev/null
	else
		printf "System doesn't appear to be a liveconfig web server.\n"
	fi
}



# bak - CREATE A BACKUP COPY OF FILES
function bak() {
	FILES="${@}"
	for FILE in $FILES; do
		cp -av "$FILE" "$FILE".bak_$(date +%Y-%m-%d-%H-%M-%S)
	done
}



# dbak - CREATE A TAR'ED BACKUP COPY OF DIRECTORIES
#
function dbak() {
	local SYSUSER USER STARTDIR="$(pwd)" HOMEDIR BAKDIR BAKFILEBASE BAKFILE DIR DIRPATH DIRNAME DIRLONG DONE="" DIRS="${@}"
	for DIR in $DIRS; do
		[[ -z "${DIR##*/*}" ]] && DIRPATH="${DIR%/*}" DIRNAME="${DIR##*/}" || DIRPATH="." DIRNAME="$DIR"
		[[ "$DIRPATH" != '.' ]] && BAKFILEBASE=$(echo "$DIR" |sed -r 's/^\/+//g;s/\//_/g') || BAKFILEBASE="$DIRNAME"
		DIRLONG=$(cd $DIRPATH && pwd) && cd $STARTDIR 1>/dev/null
		for SYSUSER in $(grep -P '^[^:]+:[^:]+:1\d{3}' /etc/passwd |cut -d':' -f1); do
			HOMEDIR=$(grep -P "^$SYSUSER:" /etc/passwd |cut -d':' -f6)
			[[ -n $(echo "$DIRLONG" |grep -P "^$HOMEDIR(/.*)?$") ]] && USER=$SYSUSER && break
		done
		[[ -n "$USER" ]] && BAKDIR="$HOMEDIR/files/backup" || BAKDIR="$STARTDIR"
		[[ "$BAKDIR" != "$STARTDIR" ]] && [[ ! -d "$BAKDIR" ]] && mkdir -p $BAKDIR && chown $USER: $BAKDIR && chmod 700 $BAKDIR
		STAMP="$(date +%F-%H-%M-%S)" && BAKFILE="$BAKDIR/${BAKFILEBASE}.bak_${STAMP}.tar.gz"

		cd $DIRLONG && tar -pczf $BAKFILE $DIRNAME 1>/dev/null
		[[ -n "$USER" ]] && chown $USER: $BAKFILE
		DONE+="\n $BAKFILE"
	done
	cd $STARTDIR
	printf "${DONE}\n\n"
}



# mbak - CREATE A BACKUP DUMP OF MYSQL/MARIADB DATABASES
#
function mbak() {
	local SYSUSER USER DIR DONE="" DBS="${@}"
	for DB in $DBS; do
		for SYSUSER in $(grep -P '^[^:]+:[^:]+:1\d{3}' /etc/passwd |cut -d':' -f1); do
			[[ -n $(echo $DB |grep -P "^((db|usr)_${SYSUSER}_\d+|${SYSUSER}db\d+)$") ]] && USER=$SYSUSER && break
		done
		[[ -n "$USER" ]] && DIR="$(grep -P "^$USER:" /etc/passwd |cut -d':' -f6)/files/backup" || DIR='.'
		[[ "$DIR" != '.' ]] && [[ ! -d "$DIR" ]] && mkdir -p $DIR && chown $USER: $DIR && chmod 700 $DIR
		STAMP="$(date +%F-%H-%M-%S)" && BAKFILE="$DIR/${DB}__${STAMP}.sql.gz"

		mysqldump --default-character-set=utf8 --events --routines --triggers --single-transaction --no-create-db $DB |gzip > $BAKFILE
		[[ -n "$USER" ]] && chown $USER: $BAKFILE
		DONE+="\n $BAKFILE"
	done
	printf "${DONE}\n\n"
}



# cleandb - EMPTY A DATABASE
#
function cleandb() {
	local FAILED=0 ERROR COUNT TBL DBS="${@}"
	for DB in $DBS; do
		COUNT=1
		while [[ -n "$(mysql $DB -sse 'SHOW TABLES;')" ]] && [[ $COUNT -le 100 ]]; do
			for TBL in $(mysql $DB -sse 'SHOW TABLES;'); do
				! ERR=$(mysql $DB -e "SET FOREIGN_KEY_CHECKS=0; DROP TABLE \`$TBL\`;" 2>&1) && echo "ERROR: $DB.$TBL - $ERR" && let FAILED++
			done
			let COUNT++
		done
		[[ $COUNT -ge 100 ]] && echo "ERROR: $DB - Could not clear the database in 100 iterations."
	done
	[[ $FAILED -eq 0 ]] && return 0 || return $FAILED
}



# trimconfig - TRIM A CONFIG FILE FROM COMMENTS, EMPTY LINES AND LEADING/TRAILING WHITESPACE
#
function trimconfig() {
	FILES="${@}"
	for FILE in ${FILES}; do
		BAK="${FILE}.bak_$(date +%Y-%m-%d-%H-%M-%S)"
		cp -a "${FILE}" "${BAK}" &>/dev/null
		if [ $? -eq 0 ]; then
			printf "\n I created a backup file because I think you don't know what you are doing:\n   ${BAK}\n"
		else
			printf "\n I could not create a backup file: ${BAK}\n   Skipping this file...\n"
			continue
		fi
		perl -pi -e 's/^\s*$//g;s/^[ \t]+//g;s/[ \t]+$//g;s/^\s*[;#]+.*\s*$//g' "${FILE}" 1>/dev/null
	done
	echo
}



# til - SLEEP UNTIL <YYYY-MM-DD HH:MM:SS>
#
function til() {
	local TAR="${@}"
	local NOW=$(date +%s)
	local	THEN=$(date -d"${TAR}" +%s)
	local	THENH=$(date -d"${TAR}" +%F\ %T)
	local DUR=$(( ${THEN} - ${NOW} ))
	local DURH=$(printf "%.2dd/%.2dh/%.2dm/%.2ds" $((${DUR}/86400)) $((${DUR}%86400/3600)) $((${DUR}%3600/60)) $((${DUR}%60)))

	if [ ${DUR} -lt 0 ]; then
		printf "${THENH} is in the past!\n"
		return 1
	fi

	printf "$(date +%F\ %T) - Sleeping for ${DUR} seconds (${DURH}) until ${THENH}.\n"
	sleep ${DUR}
	printf "$(date +%F\ %T) - Done.\n"
	return 0
}



# rolldice - ROLL A DICE WITH X PIPS
#
function rolldice() {
	if [[ -n "$1" ]] && [[ -n "$2" ]]; then
		local NUM="$1"
		local PIP="$2"
	elif [[ -n "$1" ]] && [[ -z "$2" ]]; then
		local NUM="1"
		local PIP="$1"
	else
		local NUM="1"
		local PIP="6"
	fi

	if [[ $NUM -ne 1 ]]; then local S="s"; else local S=""; fi
	local SUM=0
	printf "Rolling $NUM dice$S with $PIP pips:\n"
	for (( i = 1 ; i <= $NUM ; i++ )); do
		local ROLL=$(( $RANDOM % $PIP + 1 ))
		printf "  $ROLL\n"
		SUM=$(( $SUM + $ROLL ))
	done
	if [[ $SUM -ne $ROLL ]]; then
		AVG=$(echo "scale=2; $SUM/$NUM" |bc)
		printf "Sum: $SUM\nAvg: $AVG\n"
	fi

	return 0
}



#
#
#
##########
