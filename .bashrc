#!/bin/bash -x
####################################################################################################
#
# The structure of this .bashrc is as follows:
#
# [HOVT] [[PROCS]] [[VMS]] [[GIT]] [EXITCODE] USER@HOST PATH 
#  ||||      |        |       |
#  ||||      |        |       |- ONLY IF IN GIT FOLDER
#  ||||      |        |
#  ||||      |        |- VM STATS (ONLY IF VM HOST)
#  ||||      |
#  ||||      |- PROCS (ONLY IF ANY OF THE PROCS ARE RUNNING)
#  ||||      |- C (RED)     = CLUSTER (COROSYNC / PACEMAKER)
#  ||||      |- P (GREY)    = POSTFIX
#  ||||      |- E (GREY)    = EXIM
#  ||||      |- D (GREY)    = DOVECOT
#  ||||      |- C (GREY)    = CYRUS
#  ||||      |- P (WHITE)   = FTP (PROFTPD)
#  ||||      |- V (WHITE)   = FTP (VSFTPD)
#  ||||      |- M (BLUE)    = MARIADB / MYSQL
#  ||||      |- P (BLUE)    = POSTGRESQL
#  ||||      |- H (GREEN)   = HAPROXY
#  ||||      |- N (GREEN)   = NGINX
#  ||||      |- A (GREEN)   = APACHE2
#  ||||      |- V (GREEN)   = VARNISH
#  ||||      |- P (GREEN)   = PHP-FPM
#  ||||      |- E (CYAN)    = ELASTICSEARCH
#  ||||      |- K (CYAN)    = KIBANA
#  ||||      |- R (MAGENTA) = REDIS
#  ||||      |- M (MAGENTA) = MEMCACHED
#  ||||      |- B (YELLOW)  = BAREOS-DIR
#  ||||
#  ||||- TYPE (ONLY IF TYPE FOUND)
#  ||||- L = LIVECONFIG
#  ||||- C = CONFIXX
#  ||||- P = PLESK
#  ||||- V = VM HOST
#  |||
#  |||- VERSION NUMBER
#  ||
#  ||- OPERATING SYSTEM
#  ||- D = DEBIAN
#  ||- U = UBUNTU
#  ||- C = CENTOS
#  ||- X = XENSERVER
#  ||- ? = UNKNOWN
#  |
#  |- HARDWARE TYPE
#  |- C = VM (CITRIX XEN)
#  |- K = VM (KVM)
#  |- L = VM (LXC)
#  |- U = VM (DOMU)
#  |- V = VM (VBOX)
#  |- B = BARE
#
####################################################################################################



### EXIT IF NOT RUNNING INTERACTIVELY
[[ -z "$PS1" ]] && return

### SHELL HISTORY CONFIGURATION
shopt -s histappend
shopt -s cmdhist
export HISTCONTROL=ignoredups
export HISTSIZE=1000000000
export HISTFILESIZE=1000000000
export HISTTIMEFORMAT="%Y-%m-%d %T  ~  "

shopt -s checkwinsize

### SET LOCALE PARAMETERS
export LCNUMERICORIG="$LC_NUMERIC" LCCOLLATEORIG="$LC_COLLATE"
export LC_NUMERIC=C LC_COLLATE=C

### GENERATE FANCY COLOR PROMPT
PROMPT_COMMAND=_prompt_command
function _prompt_command() {
  ## EXIT CODE OF LAST COMMAND
  local EXIT="$?"

  ## SET PS1 TO EMPTY VALUE
  PS1=""

  ## ANSI COLOR CODES
  # RESET
  local RES='\[\e[00m\]'
  # REGULAR                      BOLD                            UNDERLINE                       INTENSE                         BOLD INTENSE                     BACKGROUND               BACKGROUND INTENSE
  local BLA='\[\e[00;30m\]';     local BBLA='\[\e[01;30m\]';     local UBLA='\[\e[04;30m\]';     local IBLA='\[\e[00;90m\]';     local BIBLA='\[\e[01;90m\]';     local _BLA='\e[40m';     local _IBLA='\[\e[00;100m\]';
  local RED='\[\e[00;31m\]';     local BRED='\[\e[01;31m\]';     local URED='\[\e[04;31m\]';     local IRED='\[\e[00;91m\]';     local BIRED='\[\e[01;91m\]';     local _RED='\e[41m';     local _IRED='\[\e[00;101m\]';
  local GRE='\[\e[00;32m\]';     local BGRE='\[\e[01;32m\]';     local UGRE='\[\e[04;32m\]';     local IGRE='\[\e[00;92m\]';     local BIGRE='\[\e[01;92m\]';     local _GRE='\e[42m';     local _IGRE='\[\e[00;102m\]';
  local YEL='\[\e[00;33m\]';     local BYEL='\[\e[01;33m\]';     local UYEL='\[\e[04;33m\]';     local IYEL='\[\e[00;93m\]';     local BIYEL='\[\e[01;93m\]';     local _YEL='\e[43m';     local _IYEL='\[\e[00;103m\]';
  local BLU='\[\e[00;34m\]';     local BBLU='\[\e[01;34m\]';     local UBLU='\[\e[04;34m\]';     local IBLU='\[\e[00;94m\]';     local BIBLU='\[\e[01;94m\]';     local _BLU='\e[44m';     local _IBLU='\[\e[00;104m\]';
  local MAG='\[\e[00;35m\]';     local BMAG='\[\e[01;35m\]';     local UMAG='\[\e[04;35m\]';     local IMAG='\[\e[00;95m\]';     local BIMAG='\[\e[01;95m\]';     local _MAG='\e[45m';     local _IMAG='\[\e[00;105m\]';
  local CYA='\[\e[00;36m\]';     local BCYA='\[\e[01;36m\]';     local UCYA='\[\e[04;36m\]';     local ICYA='\[\e[00;96m\]';     local BICYA='\[\e[01;96m\]';     local _CYA='\e[46m';     local _ICYA='\[\e[00;106m\]';
  local WHI='\[\e[00;37m\]';     local BWHI='\[\e[01;37m\]';     local UWHI='\[\e[04;37m\]';     local IWHI='\[\e[00;97m\]';     local BIWHI='\[\e[01;97m\]';     local _WHI='\e[47m';     local _IWHI='\[\e[00;107m\]';

  ## CHECK IF ROOT
  if [[ ${UID} -eq 0 ]]; then
		## CHECK HARDWARE TYPE
		PS1+="${BBLA}[${BWHI}"
		VMH=0
		if		[[ -d /proc/xen ]] && [[ -n "$(grep -o 'control_d' /proc/xen/capabilities 2>/dev/null)" ]]; then
			VMH=1
			if		[[ -z "$(head -n1 /etc/issue* 2>/dev/null |grep -oi 'XenServer')" ]]; then
				if [[ -n "$(xl help 2>/dev/null)" ]]; then
					TS="xl"
				else
					TS="xm"
				fi
				VMR=$(${TS} list 2>/dev/null |egrep -v 'Name.*ID|Dom[^ 	]*0' |wc -l)
				VMM=$(find /etc/xen -mindepth 1 -maxdepth 1 -type f -name "*.cfg" 2>/dev/null |wc -l)
#			elif	[[]]; then # TODO LXC
			else
				VMR=$(xe vm-list resident-on=$(xe host-list 2>/dev/null |grep -E -B1 "$(hostname)|$(hostname -f)" |grep uuid |rev |awk '{print $1}' |rev) is-control-domain=false power-state=running params=name-label 2>/dev/null |grep -Pv '^[ \t]*$' |wc -l)
				VMM=$(xe vm-list is-control-domain=false power-state=running params=name-label 2>/dev/null |grep -Pv '^[ \t]*$' |wc -l)
			fi
		elif	[[ -n "$(which xe-daemon 2>/dev/null)" ]]; then
			PS1+="C"
		elif	[[ -d /proc/xen ]] && [[ -z "$(grep -o 'control_d' /proc/xen/capabilities 2>/dev/null)" ]]; then
			PS1+="U"
		elif	[[ -n "$(grep -ao 'container=lxc' /proc/1/environ 2>/dev/null)" ]]; then
			PS1+="L"
		elif	[[ "$(dmidecode -s system-product-name 2>/dev/null)" == "KVM" ]] && [[ -d /lib/modules/*/kernel ]] && [[ -n "$(find /lib/modules/*/kernel |grep -o 'kvm.ko' 2>/dev/null)" ]] || [[ -n "$(grep -Eio 'QEMU|KVM' /proc/cpuinfo)" ]]; then
			PS1+="K"
		elif	[[ "$(dmidecode -s system-product-name 2>/dev/null)" == "VirtualBox" ]]; then
			PS1+="V"
		else
			PS1+="B"
		fi

		## CHECK OPERATING SYSTEM
		PS1+="${WHI}"
		if		[[ -n "$(head -n1 /etc/issue* 2>/dev/null |grep -oi 'Debian')" ]]; then
			PS1+="D"
			CV=10
			V=$(head -n1 /etc/debian_version 2>/dev/null |cut -d'.' -f1)
			if		[[ ${V} -ge ${CV} ]]; then
				PS1+="${GRE}${V}"
			elif	[[ ${V} -ge $(echo $(( ${CV} - 1 ))) ]]; then
				PS1+="${YEL}${V}"
			else
				PS1+="${RED}${V}"
			fi
		elif	[[ -n "$(head -n1 /etc/issue* 2>/dev/null |grep -oi 'Ubuntu')" ]]; then
			PS1+="U"
			CV=$(( $(date +%Y |tail -c3) / 2 * 2 ))
			V=$(egrep -o '[0-9]{1,2}\.[0-9]{1,2}' /etc/issue 2>/dev/null |cut -d'.' -f1)
			if		[[ ${V} -ge ${CV} ]]; then
				PS1+="${GRE}${V}"
			elif	[[ ${V} -ge $(echo $(( ${CV} - 4 ))) ]]; then
				PS1+="${YEL}${V}"
			else
				PS1+="${RED}${V}"
			fi
		elif	[[ -n "$(head -n1 /etc/issue* 2>/dev/null |grep -oi 'XenServer')" ]]; then
			PS1+="X"
			CV=7
			V=$(head -n1 /etc/issue* |egrep -o '([0-9]{1,2}\.){2}[0-9]{1,2}' |cut -d'.' -f1)
			if		[[ ${V} -ge ${CV} ]]; then
				PS1+="${BGRE}${V}"
			elif	[[ ${V} -ge $(echo $(( ${CV} - 1 ))) ]]; then
				PS1+="${BYEL}${V}"
			else
				PS1+="${BRED}${V}"
			fi
		elif	[[ -n "$(head -n1 /etc/issue* 2>/dev/null |grep -oi 'CentOS')" ]]; then
			PS1+="C"
			CV=7
			V=$(egrep -o '[0-9]{1,2}\.[0-9]{1,2}' /etc/issue 2>/dev/null |cut -d'.' -f1)
			if		[[ ${V} -ge ${CV} ]]; then
				PS1+="${GRE}${V}"
			elif	[[ ${V} -ge $(echo $(( ${CV} - 1 ))) ]]; then
				PS1+="${YEL}${V}"
			else
				PS1+="${RED}${V}"
			fi
		elif	[[ -f /etc/fedora-release ]]; then
			PS1+="F"
			CV=31
			V="$(grep -Po '[0-9]+' /etc/fedora-release)"
			if		[[ ${V} -ge ${CV} ]]; then
				PS1+="${GRE}${V}"
			elif	[[ ${V} -ge $(echo $(( ${CV} - 1 ))) ]]; then
				PS1+="${YEL}${V}"
			else
				PS1+="${RED}${V}"
			fi
		else
			PS1+="?${WHI}?"
		fi

		## CHECK TYPE
    if		[[ -n "$(ps -o pid=,comm= -C liveconfig,lcclient 2>/dev/null)" ]]; then
			PS1+="${BGRE}L"
		elif	[[ -d "/etc/apache2/confixx_vhosts" ]]; then
			PS1+="${BYEL}C"
		elif	[[ -d "/etc/apache2/plesk.conf.d" ]] || [[ -d "/etc/nginx/plesk.conf.d" ]]; then
			PS1+="${BRED}P"
		elif	[[ ${VMH} = 1 ]]; then
			PS1+="${BWHI}V"
		fi
		PS1+="${BBLA}] "

		# CHECK PROCS
		PROCS=""
		if		[[ -n "$(ps -o pid= -C corosync,pacemaker 2>/dev/null)" ]]; then                            PROCS+="${BRED}C"; fi # RED/C     - CLUSTER
		if		[[ -n "$(ps -o pid= -C smtpd,postfix,master 2>/dev/null)" ]]; then                          PROCS+="${WHI}P";  fi # GREY/P    - POSTFIX
		if		[[ -n "$(ps -o pid= -C exim 2>/dev/null)" ]]; then                                          PROCS+="${WHI}E";  fi # GREY/E    - EXIM
		if		[[ -n "$(ps -o pid= -C dovecot 2>/dev/null)" ]]; then                                       PROCS+="${WHI}D";  fi # GREY/D    - DOVECOT
		if		[[ -n "$(ps -o pid= -C cyrmaster 2>/dev/null)" ]]; then                                     PROCS+="${WHI}C";  fi # GREY/C    - CYRUS
		if		[[ -n "$(ps -o pid= -C proftpd 2>/dev/null)" ]]; then                                       PROCS+="${BWHI}F"; fi # WHITE/F  - PROFTPD
		if		[[ -n "$(ps -o pid= -C vsftpd 2>/dev/null)" ]]; then                                        PROCS+="${BWHI}V"; fi # WHITE/V  - VSFTPD
		if		[[ -n "$(ps -o pid= -C mysqld,mariadb 2>/dev/null)" ]]; then                                PROCS+="${BBLU}M"; fi # BLUE/M    - MARIADB / MYSQL
		if		[[ -n "$(ps -o pid= -C postgres 2>/dev/null)" ]]; then                                      PROCS+="${BBLU}P"; fi # BLUE/P    - POSTGRESQL
		if		[[ -n "$(ps -o pid= -C haproxy 2>/dev/null)" ]]; then                                       PROCS+="${GRE}H";  fi # GREEN/H   - HAPROXY
		if		[[ -n "$(ps -o pid= -C nginx 2>/dev/null)" ]]; then                                         PROCS+="${GRE}N";  fi # GREEN/N   - NGINX
		if		[[ -n "$(ps -o pid= -C apache2,httpd 2>/dev/null)" ]]; then                                 PROCS+="${GRE}A";  fi # GREEN/A   - APACHE2
		if		[[ -n "$(ps -o pid= -C varnishd 2>/dev/null)" ]]; then                                      PROCS+="${GRE}V";  fi # GREEN/V   - VARNISH
		if		[[ -n "$(ps -A -o args= 2>/dev/null |grep -v "grep" |grep "php-fpm")" ]]; then              PROCS+="${GRE}P";  fi # GREEN/P   - PHP-FPM
		if		[[ -n "$(ps -A -o args= 2>/dev/null |grep -v "grep" |grep "elasticsearch")" ]]; then        PROCS+="${BCYA}E"; fi # CYAN/E    - ELASTICSEARCH
		if		[[ -n "$(ps -A -o args= 2>/dev/null |grep -v "grep" |grep "kibana")" ]]; then               PROCS+="${BCYA}K"; fi # CYAN/K    - KIBANA
		if		[[ -n "$(ps -o pid= -C redis-server 2>/dev/null)" ]]; then                                  PROCS+="${BMAG}R"; fi # MAGENTA/R - REDIS
		if		[[ -n "$(ps -o pid= -C memcached 2>/dev/null)" ]]; then                                     PROCS+="${BMAG}M"; fi # MAGENTA/M - MEMCACHED
		if		[[ -n "$(ps -o pid= -C bareos-dir 2>/dev/null)" ]]; then                                    PROCS+="${YEL}B";  fi # YELLOW/B  - BAREOS-DIR
		if [[ -n "${PROCS}" ]]; then
			PS1+="${BBLA}[${PROCS}${BBLA}] "
		fi

		## CHECK IF VM HOST
		if [[ ${VMH} -eq 1 ]]; then
			PS1+="${BBLA}["
			
			if		[[ ${VMR} -eq ${VMM} ]]; then
				PS1+="${BGRE}"
			elif	[[ ${VMR} -lt ${VMM} ]] && [[ ${VMR} -gt 0 ]]; then
				PS1+="${BYEL}"
			else
				PS1+="${BRED}"
			fi
			
			PS1+="${VMR}${WHI}/"
			
			if		[[ ${VMM} -eq 0 ]]; then
				PS1+="${BYEL}"
			else
				PS1+="${BGRE}"
			fi

			PS1+="${VMM}${BBLA}] "
		fi


	## IF NOT ROOT
  else
		# ADD GIT REPO STATUS TO PS1
		git rev-parse &>/dev/null
		REPO=$?
		if [[ ${REPO} -eq 0 ]]; then
			PS1+="${BBLA}["
			UPS=${1:-'@{u}'}
			LOC=$(git rev-parse @{0} 2>/dev/null)
			REM=$(git rev-parse "${UPS}" 2>/dev/null)
			BAS=$(git merge-base @{0} "${UPS}" 2>/dev/null)
			COM=$(git status |grep 'modified\|new file\|deleted\|Untracked files:')
			if		[[ "${LOC}" == "${REM}" ]] && [[ -z "${COM}" ]]; then
				PS1+="${BGRE}OK"
			elif	[[ "${REM}" == "${BAS}" ]] || [[ -n "${COM}" ]]; then
				PS1+="${BYEL}PUSH"
			elif	[[ "${LOC}" == "${BAS}" ]]; then
				PS1+="${BYEL}PULL"
			else
				PS1+="${BRED}DIV"
			fi
			PS1+="${BBLA}] "
		fi
  fi

  ## ADD EXIT CODE OF LAST COMMAND TO PS1
  if [[ ${EXIT} -eq 0 ]]; then
    PS1+="${BBLA}[${BGRE}+${WHI}${BBLA}] "
  else
    PS1+="${BBLA}[${BRED}-${WHI}${BBLA}] "
  fi

	if [[ "$(whoami |egrep '^web[0-9]*')" != "" ]]; then
		PS1+="${BGRE}\u"
	else
		PS1+="${BBLU}\u"
	fi

  ## ADD HOSTNAME AND CURRENT FOLDER TO PS1
  PS1+="${BBLA}@${BWHI}\h${BBLA} ${BBLU}\w${BWHI} \$${RES} "
}

### ENABLE FORWARD SEARCH (CTRL + s)
stty -ixon

### ENABLE LS COLOR SUPPORT
if [[ -x /usr/bin/dircolors ]]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

### ACTIVATE BASH COMPLETION
if [[ -f /etc/bash_completion ]] && ! shopt -oq posix; then
	. /etc/bash_completion
fi

### SOURCE /ETC/PROFILE.D/ FILES
for i in /etc/profile.d/*.sh; do
	if [ -r "$i" ]; then
		if [ "$PS1" ]; then
			. "$i"
		else
			. "$i" >/dev/null
		fi
	fi
done

### INCLUDE BASH_SUBFILES
if [[ -f ~/.bash_aliases ]]; then
  . ~/.bash_aliases
fi
if [[ -f ~/.bash_functions ]]; then
  . ~/.bash_functions
fi

### INCLUDE ANSIBLE ENV
if [[ -f /opt/ansible/hacking/env-setup ]]; then
	. /opt/ansible/hacking/env-setup -q
fi

### INCLUDE BITWARDEN ENV
if [[ -f ~/.bw.session ]]; then
	. ~/.bw.session
fi

### CHANGE TO ~/workspace IF EXISTS
if [[ -d ~/workspace ]]; then
	cd ~/workspace
fi


### LOGIN MESSAGE
if [[ $UID -eq 0 ]]; then
	## ANSI COLOR CODES
	# RESET
	RES='\e[00m'
	# REGULAR            BOLD                  UNDERLINE             INTENSE               BOLD INTENSE            BACKGROUND        BACKGROUND INTENSE
	BLA='\e[00;30m';     BBLA='\e[01;30m';     UBLA='\e[04;30m';     IBLA='\e[00;90m';     BIBLA='\e[01;90m';     _BLA='\e[40m';     _IBLA='\e[00;100m';
	RED='\e[00;31m';     BRED='\e[01;31m';     URED='\e[04;31m';     IRED='\e[00;91m';     BIRED='\e[01;91m';     _RED='\e[41m';     _IRED='\e[00;101m';
	GRE='\e[00;32m';     BGRE='\e[01;32m';     UGRE='\e[04;32m';     IGRE='\e[00;92m';     BIGRE='\e[01;92m';     _GRE='\e[42m';     _IGRE='\e[00;102m';
	YEL='\e[00;33m';     BYEL='\e[01;33m';     UYEL='\e[04;33m';     IYEL='\e[00;93m';     BIYEL='\e[01;93m';     _YEL='\e[43m';     _IYEL='\e[00;103m';
	BLU='\e[00;34m';     BBLU='\e[01;34m';     UBLU='\e[04;34m';     IBLU='\e[00;94m';     BIBLU='\e[01;94m';     _BLU='\e[44m';     _IBLU='\e[00;104m';
	MAG='\e[00;35m';     BMAG='\e[01;35m';     UMAG='\e[04;35m';     IMAG='\e[00;95m';     BIMAG='\e[01;95m';     _MAG='\e[45m';     _IMAG='\e[00;105m';
	CYA='\e[00;36m';     BCYA='\e[01;36m';     UCYA='\e[04;36m';     ICYA='\e[00;96m';     BICYA='\e[01;96m';     _CYA='\e[46m';     _ICYA='\e[00;106m';
	WHI='\e[00;37m';     BWHI='\e[01;37m';     UWHI='\e[04;37m';     IWHI='\e[00;97m';     BIWHI='\e[01;97m';     _WHI='\e[47m';     _IWHI='\e[00;107m';

	MESG="\n"

	if [[ -n "$(which uptime 2>/dev/null)" ]] && [[ -n "$(uptime -sp 2>/dev/null)" ]]; then
		UP=$(which uptime 2>/dev/null)
		UP_STRH=$($UP -s)
		UP_STRU=$(date -d"$UP_STRH" +%s)
		UP_NOWU=$(date +%s)
		UP_NOWH=$(date +%F\ %T)
		UP_DURS=$(( ${UP_NOWU} - ${UP_STRU} ))
		UP_DURH=$(printf "${BWHI}%.2d${RES}d ${BWHI}%.2d${RES}h ${BWHI}%.2d${RES}m ${BWHI}%.2d${RES}s" $((${UP_DURS}/86400)) $((${UP_DURS}%86400/3600)) $((${UP_DURS}%3600/60)) $((${UP_DURS}%60)))
		MESG+="  Uptime: ${UP_DURH} since ${UP_STRH}\n"
	fi

	if [[ -n "$(which last 2>/dev/null)" ]] && [[ -n "$(last -iw -n2 --time-format=iso 2>/dev/null)" ]]; then
		L=$(which last 2>/dev/null)
		L_STAT=$($L -iw --time-format=iso |grep -Pv '^([bw]tmp begins|(re)?boot|$)|still[ \t]+logged[ \t]+in[ \t]*$' |head -n1)
		L_USER=$(echo "$L_STAT" |awk '{print $1}')
		L_TIME=$(echo "$L_STAT" |awk '{print $4}' |sed -r 's/T/ /g;s/\+[0-9]+//g')
		L_FROM=$(echo "$L_STAT" |awk '{print $3}')
		L_MESG="  Last login: ${BWHI}${L_USER}${RES} from ${BWHI}${L_FROM}${RES} ${BBLA}[${WHI}${L_TIME}${BBLA}]${RES}"
		MESG+="${L_MESG}\n"
	fi

	I_STAT=$(ip a |grep -P 'inet[ \t]+.+[ \t]+scope global' |sed -r 's/[ \t]*inet[ \t]*//g;s/(brd[ \t]*((25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])[ \t]*)?scope[ \t]*global//g')
	I_HOST=$(cat /etc/issue.net 2>/dev/null |sed -r 's/GNU\/Linux //g;s/\\\S//g;s/\\\m//g;s/[\(\)]//g;s/(on[ \t]+an?|Host|Kernel|Release|Final)//gI' |tr '\n' ' ' |sed -r 's/[ \t]+/ /g;s/[ \t]+$//g')
	if [[ -z "$I_HOST" ]] || [[ -z "$(echo $I_HOST |grep -Pv '^[ \t]*$')" ]]; then
		I_HOST=$(cat /etc/issue 2>/dev/null |head -n1 |sed -r 's/GNU\/Linux //g;s/\\\S//g;s/\\\m//g;s/[\(\)]//g;s/(on[ \t]+an?|Host|Kernel|Release|Final)//gI' |tr '\n' ' ' |sed -r 's/[ \t]+/ /g;s/[ \t]+$//g')
	fi
	if [[ -z "$I_HOST" ]] || [[ -z "$(echo $I_HOST |grep -Pv '^[ \t]*$')" ]]; then
		I_HOST=$(cat /etc/fedora-release 2>/dev/null |head -n1 |grep -Poi 'fedora|[0-9]+' |tr '\n' ' ' |sed -r 's/[ \t]+$//g')
	fi
	I_MESG="  ${BWHI}$(hostname -f)${RES} ${BBLA}[${YEL}${I_HOST}${BBLA}]${RES} ${BBLA}[${WHI}$(uname -r) $(uname -m)${BBLA}]${RES}"
	OIFS="$IFS"; IFS=$'\n'
	for I_LINE in $I_STAT; do
		I_ADDR=$(echo "$I_LINE" |awk '{print $1}')
		I_NAME=$(echo "$I_LINE" |awk '{print $2 " " $3}' |sed -r 's/[ \t]+$//g;/secondary /s/$/ (2ry)/g;/secondary /s/secondary //g')
		I_MESG+="\n    ${GRE}${I_ADDR}${RES}\t${BBLA}[${WHI}${I_NAME}${BBLA}]${RES}"
	done
	IFS="$OIFS"
	MESG+="\n$I_MESG\n"

	CPU_NUM=$(grep -P '^[ \t]*processor[ \t]*:' /proc/cpuinfo 2>/dev/null |wc -l)
  if [[ $(printf "$CPU_NUM" |wc -c) -lt 2 ]]; then CPU_SPC="  "; elif [[ $(printf "$CPU_NUM" |wc -c) -lt 3 ]]; then CPU_SPC=" "; else CPU_SPC=""; fi
	CPU_SPD="$(cat /proc/cpuinfo |grep -E '^model name' |head -n1 |cut -d':' -f2 |grep -Eoi '[0-9]+\.[0-9]+ ?GHz' |grep -Eoi '[0-9]+\.[0-9]+')"
	if [[ -z "$CPU_SPD" ]]; then CPU_SPD="$(lscpu |grep -i 'max MHz' |grep -Eo '[0-9]+' |head -n1 |sed -r 's/([0-9]{2})[0-9]$/.\1/g')"; fi
	if [[ -z "$CPU_SPD" ]]; then CPU_SPD="?"; fi
	CPU_LOAD_1=$(cat /proc/loadavg |awk '{print $1}')
	CPU_LOAD_5=$(cat /proc/loadavg |awk '{print $2}')
	CPU_LOAD_15=$(cat /proc/loadavg |awk '{print $3}')
	if [[ -x $(which bc 2>/dev/null) ]]; then
		if [[ -z $(echo "scale=2;(${CPU_NUM}-(${CPU_NUM}*0.2))-${CPU_LOAD_1}" |bc |grep -E '^-') ]]; then CPU_LOAD_1_CLR=${GRE}; elif [[ -z $(echo "scale=2;(${CPU_NUM}+(${CPU_NUM}*0.2))-${CPU_LOAD_1}" |bc |grep -E '^-') ]]; then CPU_LOAD_1_CLR=${YEL}; else CPU_LOAD_1_CLR=${RED}; fi
		if [[ -z $(echo "scale=2;(${CPU_NUM}-(${CPU_NUM}*0.2))-${CPU_LOAD_5}" |bc |grep -E '^-') ]]; then CPU_LOAD_5_CLR=${GRE}; elif [[ -z $(echo "scale=2;(${CPU_NUM}+(${CPU_NUM}*0.2))-${CPU_LOAD_5}" |bc |grep -E '^-') ]]; then CPU_LOAD_5_CLR=${YEL}; else CPU_LOAD_5_CLR=${RED}; fi
		if [[ -z $(echo "scale=2;(${CPU_NUM}-(${CPU_NUM}*0.2))-${CPU_LOAD_15}" |bc |grep -E '^-') ]]; then CPU_LOAD_15_CLR=${GRE}; elif [[ -z $(echo "scale=2;(${CPU_NUM}+(${CPU_NUM}*0.2))-${CPU_LOAD_15}" |bc |grep -E '^-') ]]; then CPU_LOAD_15_CLR=${YEL}; else CPU_LOAD_15_CLR=${RED}; fi
	else
		CPU_LOAD_1_CLR="${BWHI}"
		CPU_LOAD_5_CLR="${BWHI}"
		CPU_LOAD_15_CLR="${BWHI}"
	fi
	MESG+="\n          ${BWHI}CPU${RES}:  ${CPU_SPC}${BWHI}${CPU_NUM}${BBLA}x${RES} ${BWHI}${CPU_SPD}${RES}GHz ${BBLA}/${RES} ${CPU_LOAD_1_CLR}${CPU_LOAD_1}${RES} ${BBLA}[${WHI}1m${BBLA}]${RES} | ${CPU_LOAD_5_CLR}${CPU_LOAD_5}${RES} ${BBLA}[${WHI}5m${BBLA}]${RES} | ${CPU_LOAD_15_CLR}${CPU_LOAD_15}${RES} ${BBLA}[${WHI}15m${BBLA}]${RES}\n"

	MEM_ALL=$(grep -P '^[ \t]*MemTotal[ \t]*:' /proc/meminfo |grep -Eo '[0-9]+' |head -n1)
	MEM_FREE=$(grep -P '^[ \t]*MemAvailable[ \t]*:' /proc/meminfo |grep -Eo '[0-9]+' |head -n1)
  	MEM_USE=$(( $MEM_ALL - $MEM_FREE ))
	MEM_PCT=$(( $MEM_USE * 100 / $MEM_ALL ))
	if [[ $MEM_PCT -lt 70 ]]; then MEM_CLR=${GRE}; elif [[ $MEM_PCT -lt 90 ]]; then MEM_CLR=${YEL}; else MEM_CLR=${RED}; fi
	if [[ $(printf "$MEM_PCT" |wc -c) -lt 2 ]]; then MEM_SPC="  "; elif [[ $(printf "$MEM_PCT" |wc -c) -lt 3 ]]; then MEM_SPC=" "; else MEM_SPC=""; fi
	MESG+="          ${BWHI}MEM${RES}:  ${MEM_SPC}${MEM_CLR}${MEM_PCT}${BBLA}%%${RES} "
	if [[ -x $(which bc 2>/dev/null) ]]; then
		MEM_ALL_G=$(printf %.0f $(echo "scale=2;(${MEM_ALL}*0.97)/1000/1000" |bc))
		MEM_USE_G=$(printf %.2f $(echo "scale=2;(${MEM_USE}*0.97)/1000/1000" |bc))
		MESG+="${MEM_CLR}${MEM_USE_G}${WHI}G${BBLA} / ${BWHI}${MEM_ALL_G}${WHI}G${RES}\n"
	else
		MESG+="${MEM_CLR}${MEM_USE}${WHI}K${BBLA} / ${BWHI}${MEM_ALL}${WHI}K${RES}\n"
	fi

	SWAP_ALL=$(grep -P '^[ \t]*SwapTotal[ \t]*:' /proc/meminfo |grep -Eo '[0-9]+' |head -n1)
	if [[ $SWAP_ALL -gt 0 ]]; then
		SWAP_USE=$(vmstat |tail -n1 |awk '{print $3}')
		SWAP_PCT=$(( $SWAP_USE * 100 / $SWAP_ALL ))
		if [[ $SWAP_PCT -lt 50 ]]; then SWAP_CLR=${GRE}; elif [[ $SWAP_PCT -lt 80 ]]; then SWAP_CLR=${YEL}; else SWAP_CLR=${RED}; fi
		if [[ $(printf "$SWAP_PCT" |wc -c) -lt 2 ]]; then SWAP_SPC="  "; elif [[ $(printf "$SWAP_PCT" |wc -c) -lt 3 ]]; then SWAP_SPC=" "; else SWAP_SPC=""; fi
		MESG+="         ${BWHI}SWAP${RES}:  ${SWAP_SPC}${SWAP_CLR}${SWAP_PCT}${BBLA}%%${RES} "
		if [[ -x $(which bc 2>/dev/null) ]]; then
			SWAP_ALL_M=$(printf %.0f $(echo "scale=2;${SWAP_ALL}/1000" |bc))
			SWAP_USE_M=$(printf %.0f $(echo "scale=2;${SWAP_USE}/1000" |bc))
			MESG+="${SWAP_CLR}${SWAP_USE_M}${WHI}M${BBLA} / ${BWHI}${SWAP_ALL_M}${WHI}M${RES}\n"
		else
			MESG+="${SWAP_CLR}${SWAP_USE}${WHI}K${BBLA} / ${BWHI}${SWAP_ALL}${WHI}K${RES}\n"
		fi
	else
		MESG+="         ${BWHI}SWAP${RES}: ${GRE}NONE${RES}\n"
	fi

	if [[ -z "$(grep -i 'xenserver' /etc/issue* 2>/dev/null)" ]] || [[ $(grep -Ei 'xenserver.*[0-9]' /etc/issue* 2>/dev/null |grep -Eo '[0-9]+' |head -n1) -ge 7 ]]; then
		DF=$(which df 2>/dev/null)
		DF_STAT="$($DF -h)"
		DF_NUMB=$(echo "$DF_STAT" |grep -E '^/dev' |grep -Evi 'cdrom|/snap/' |rev |grep -Po '^[^ \t]+' |rev |sort -u |wc -l)
		if [[ $(printf "$DF_NUMB" |wc -c) -lt 2 ]]; then DF_SPC="   "; elif [[ $(printf "$DF_NUMB" |wc -c) -lt 3 ]]; then DF_SPC="  "; elif [[ $(printf "$DF_NUMB" |wc -c) -lt 4 ]]; then DF_SPC=" "; else DF_SPC=""; fi
		DF_FSES=$(echo "$DF_STAT" |grep -E '^/dev' |grep -Evi 'cdrom|/snap/' |rev |grep -Po '^[^ \t]+' |rev |sort -u |tr '\n' ' ')
		DF_MESG="  ${BWHI}FILESYSTEMS${RES}: ${DF_SPC}${BWHI}${DF_NUMB}\n"
		DF_INCR=1
		for DF_FSYS in $DF_FSES; do
			DF_PROC=$(echo "$DF_STAT" |grep -P "[ \t]+${DF_FSYS}$" |head -n1 |grep -Eo '[0-9]+%' |sed -r 's/%$//g')
			DF_SIZE=$(echo "$DF_STAT" |grep -P "[ \t]+${DF_FSYS}$" |head -n1 |grep -Eo '[0-9]+(\.[0-9]+)?[KMGT]' |head -n1)
			DF_SIZE_NUMB=$(echo "$DF_SIZE" |grep -Po '[0-9\.]+')
			DF_SIZE_UNIT=$(echo "$DF_SIZE" |sed 's/[0-9\.]//g'); [[ -z "$DF_SIZE_UNIT" ]] && DF_SIZE_UNIT="B"
			DF_SIZE_LENG=$(printf "$DF_SIZE_NUMB" |wc -c)
			DF_USED=$(echo "$DF_STAT" |grep -P "[ \t]+${DF_FSYS}$" |head -n1 |grep -Eo '[0-9]+(\.[0-9]+)?[KMGT]' |head -n2 |tail -n1)
			DF_USED_NUMB=$(echo "$DF_USED" |grep -Po '[0-9\.]+')
			DF_USED_UNIT=$(echo "$DF_USED" |sed 's/[0-9\.]//g'); [[ -z "$DF_USED_UNIT" ]] && DF_USED_UNIT="B"
			DF_USED_LENG=$(printf "$DF_USED_NUMB" |wc -c)
			if [[ $DF_PROC -lt 90 ]]; then DF_COLR=${GRE}; elif [[ $DF_PROC -lt 95 ]]; then DF_COLR=${YEL}; else DF_COLR=${BRED}; fi
			if [[ $DF_PROC -lt 10 ]]; then DF_PROCSPACE="  "; elif [[ $DF_PROC -lt 100 ]]; then DF_PROCSPACE=" "; else DF_PROCSPACE=""; fi
			if [[ $DF_SIZE_LENG -le 1 ]]; then DF_SIZESPACE="   "; elif [[ $DF_SIZE_LENG -eq 2 ]]; then DF_SIZESPACE="  "; elif [[ $DF_SIZE_LENG -eq 3 ]]; then DF_SIZESPACE=" "; else DF_SIZESPACE=""; fi
			if [[ $DF_USED_LENG -le 1 ]]; then DF_USEDSPACE="   "; elif [[ $DF_USED_LENG -eq 2 ]]; then DF_USEDSPACE="  "; elif [[ $DF_USED_LENG -eq 3 ]]; then DF_USEDSPACE=" "; else DF_USEDSPACE=""; fi
			DF_MESG+="                ${DF_PROCSPACE}${DF_COLR}${DF_PROC}${BBLA}%% ${BBLA}[${RES}${DF_USEDSPACE}${DF_COLR}${DF_USED_NUMB}${WHI}${DF_USED_UNIT}${BBLA}/${RES}${DF_SIZESPACE}${BWHI}${DF_SIZE_NUMB}${WHI}${DF_SIZE_UNIT}${BBLA}]${RES} ${BBLU}${DF_FSYS}${RES}\n"
			let DF_INCR++
		done
		MESG+="$DF_MESG"
	fi

	MAILQ=$(which mailq 2>/dev/null)
	if [[ -x $MAILQ ]]; then
		MAILQ_OUT="$($MAILQ 2>/dev/null)"
		MAILQ_ALL=$(echo "$MAILQ_OUT" |tail -n1 |grep -Poi '[0-9]+[ \t]+Requests' |grep -Eo '[0-9]+')
		if [[ -z "$MAILQ_ALL" ]]; then
			MAILQ_ALL=0
		else
			MAILQ_USER=$(echo "$MAILQ_OUT" |grep -Pi 'User unknown in (virtual mailbox|local recipient) table|Domain not found' |wc -l)
			MAILQ_GREY=$(echo "$MAILQ_OUT" |grep -Pi 'Greylist|Postgrey' |wc -l)
			MAILQ_QUOT=$(echo "$MAILQ_OUT" |grep -Pi 'The email account that you tried to reach is over quota|Mailbox full' |wc -l)
			MAILQ_RATE=$(echo "$MAILQ_OUT" |grep -Pi 'is receiving mail too quickly|is receiving mail at a rate|MXIN502 mailbox \S+ is receiving emails too fast|has exceeded their message rate limit|too many recent messages|421-Reject due to policy restrictions' |wc -l)
			MAILQ_CONN=$(echo "$MAILQ_OUT" |grep -Pi 'lost connection with|Connection timed out|conversation with .+ timed out|No route to host|Network is unreachable|Cannot assign requested address|Too many concurrent SMTP connections|Server busy\. Please try again later|Service currently unavailable|All server ports are busy|Host not found|Temporary lookup failure|server is temporarily offline' |wc -l)
			MAILQ_RFSD=$(echo "$MAILQ_OUT" |grep -Pi 'Connection refused' |wc -l)
			MAILQ_CONF=$(echo "$MAILQ_OUT" |grep -Pi 'This message does not have authentication information or fails to pass( 421-4.7.0)? authentication checks.' |wc -l)
			MAILQ_BPTR=$(echo "$MAILQ_OUT" |grep -Pi 'Bad DNS PTR resource record' |wc -l)
			MAILQ_BLKD=$(echo "$MAILQ_OUT" |grep -Pi 'refused to talk to me(?!:.+Too many concurrent SMTP connections|:.+Ask your postmaster for help)|deferred due to user complaints' |wc -l)
			MAILQ_CONT=$(echo "$MAILQ_OUT" |grep -Pi 'suspicious due to( the)? nature of( the)? content' |wc -l)
			MAILQ_LSTD=$(echo "$MAILQ_OUT" |grep -Pi 'Your IP [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ is in RBL.|A problem occurred. \(Ask your postmaster for help or to contact tosa@rx.t-online.de to clarify.\) \(BL\)' |wc -l)
			if [[ $MAILQ_USER -gt 0 ]]; then MAILQ_MESG+="${BWHI}${MAILQ_USER}${RES}x invalid recipient | "; fi
			if [[ $MAILQ_GREY -gt 0 ]]; then MAILQ_MESG+="${GRE}${MAILQ_GREY}${RES}x greylisted | "; fi
			if [[ $MAILQ_QUOT -gt 0 ]]; then MAILQ_MESG+="${GRE}${MAILQ_QUOT}${RES}x quota exceeded | "; fi
			if [[ $MAILQ_RATE -gt 0 ]]; then MAILQ_MESG+="${YEL}${MAILQ_RATE}${RES}x rate limited | "; fi
			if [[ $MAILQ_CONN -gt 0 ]]; then MAILQ_MESG+="${YEL}${MAILQ_CONN}${RES}x target unreachable | "; fi
			if [[ $MAILQ_RFSD -gt 0 ]]; then MAILQ_MESG+="${RED}${MAILQ_RFSD}${RES}x connection refused | "; fi
			if [[ $MAILQ_CONF -gt 0 ]]; then MAILQ_MESG+="${RED}${MAILQ_CONF}${RES}x ${RED}configuration problem${RES} (bit.ly/2AsxPTL) | "; fi
			if [[ $MAILQ_BPTR -gt 0 ]]; then MAILQ_MESG+="${RED}${MAILQ_BPTR}${RES}x ${RED}configuration problem${RES} (${BWHI}bad PTR${RES}) | "; fi
			if [[ $MAILQ_BLKD -gt 0 ]]; then MAILQ_MESG+="${BRED}${MAILQ_BLKD}${RES}x blocked (${YEL}blacklisted?${RES}) | "; fi
			if [[ $MAILQ_CONT -gt 0 ]]; then MAILQ_MESG+="${BRED}${MAILQ_CONT}${RES}x blocked (${YEL}suspicious content${RES}) | "; fi
			if [[ $MAILQ_LSTD -gt 0 ]]; then MAILQ_MESG+="${BRED}${MAILQ_LSTD}${RES}x ${BRED}BLACKLISTED${RES}! | "; fi
		fi
		if [[ $MAILQ_ALL -lt 10 ]]; then MAILQ_CLR=${GRE}; elif [[ $MAILQ_ALL -lt 70 ]]; then MAILQ_CLR=${YEL}; else MAILQ_CLR=${RED}; fi
		if [[ $(printf "$MAILQ_ALL" |wc -c) -lt 2 ]]; then MAILQ_SPC="   "; elif [[ $(printf "$MAILQ_ALL" |wc -c) -lt 3 ]]; then MAILQ_SPC="  "; elif [[ $(printf "$MAILQ_ALL" |wc -c) -lt 4 ]]; then MAILQ_SPC=" "; else MAILQ_SPC=""; fi
		MESG+="        ${BWHI}MAILQ${RES}: ${MAILQ_SPC}${MAILQ_CLR}${MAILQ_ALL}${RES}  "
		MESG+=$(echo "$MAILQ_MESG" |sed -r 's/ \| $//g')
		MESG+="\n"
	fi

	W=$(which who 2>/dev/null)
	if [[ -n "$($W --ips 2>/dev/null)" ]]; then
		W_STAT="$($W --ips)"
	else
		W_STAT="$($W)"
	fi
	W_NUMB=$(echo "$W_STAT" |wc -l)
	W_USRS=$(echo "$W_STAT" |awk '{print $1}' |sort -u |tr '\n' ' ')
	if [[ $(printf "$W_NUMB" |wc -c) -lt 2 ]]; then W_SPC="   "; elif [[ $(printf "$W_NUMB" |wc -c) -lt 3 ]]; then W_SPC="  "; elif [[ $(printf "$W_NUMB" |wc -c) -lt 4 ]]; then W_SPC=" "; else W_SPC=""; fi
	W_MESG="     ${BWHI}SESSIONS${RES}: ${W_SPC}${BWHI}${W_NUMB}  "
	for W_USER in $W_USRS; do
		W_USES=$(echo "$W_STAT" |grep -P "^${W_USER/\\/\\\\}[ \t]+" |wc -l)
		W_MESG+="${BBLU}${W_USER}${RES} ${BBLA}[${WHI}${W_USES}${BBLA}]${RES} | "
	done
	MESG+=$(printf "$W_MESG" |sed -r 's/ \| $//g')
	MESG+="\n"

	if [[ -n "$(ps -o pid= -C corosync 2>/dev/null)" && ( -n "$(ps -o pid= -C pacemaker 2>/dev/null)" || -n "$(ps -o pid= -C pacemakerd 2>/dev/null)" ) && -n "$(which crm 2>/dev/null)" ]]; then
		CRM=$(which crm 2>/dev/null)
		CRM_STAT=$($CRM status)

		CRM_NODE_NUMB=$(echo "$CRM_STAT" |grep -Poi '^[0-9]+[ \t]+nodes[ \t]+(and.+)?configured' |awk '{print $1}')
		CRM_NODE_ONLN=$(echo "$CRM_STAT" |grep -Pi '^Online: ' |sed -r 's/^.*\[[ \t]+//g;s/[ \t]+\].*$//g' |tr ' ' '\n' |wc -l)
		if [[ $CRM_NODE_ONLN -eq $CRM_NODE_NUMB ]]; then
			CRM_NODE_COLR="${BGRE}"
		else
			CRM_NODE_COLR="${BRED}"
		fi
		CRM_NODE_MESG="  ${CRM_NODE_COLR}${CRM_NODE_ONLN} of ${CRM_NODE_NUMB} cluster node(s) online."

		CRM_LIVE_NUMB=$(echo "$CRM_STAT" |grep -E "Started $(hostname)" |grep -v 'FAILED' |awk '{print $1}' |wc -l)
		CRM_LIVE_RESL=$(echo "$CRM_STAT" |grep -E "Started $(hostname)" |grep -v 'FAILED' |awk '{print $1}' |tr '\n' ' ')
		if [[ $CRM_LIVE_NUMB -gt 0 ]]; then
			CRM_LIVE_COLR="${BWHI}"
			CRM_LIVE_COLN=": "
		else
			CRM_LIVE_COLR="${BYEL}"
			CRM_LIVE_COLN="!"
		fi
		CRM_LIVE_MESG="  ${CRM_LIVE_COLR}${CRM_LIVE_NUMB} cluster resource(s) live${RES} on this node${CRM_LIVE_COLN}"
		for CRM_LIVE_RESC in $CRM_LIVE_RESL; do
			CRM_LIVE_MESG+="${BGRE}${CRM_LIVE_RESC}${RES} | "
		done

		CRM_FAIL_NUMB=$(echo "$CRM_STAT" |grep -Pi "FAILED[ \t]*$" |awk '{print $1}' |wc -l)
		CRM_FAIL_RESF=$(echo "$CRM_STAT" |grep -Pi "FAILED[ \t]*$" |awk '{print $1}' |tr '\n' ' ')
		if [[ $CRM_FAIL_NUMB -ne 0 ]]; then
			CRM_FAIL_MESG="  ${BRED}${CRM_FAIL_NUMB} cluster resource(s) FAILED${RES}: "
			for CRM_FAIL_RESC in $CRM_FAIL_RESF; do
				CRM_FAIL_MESG+="${BRED}${CRM_FAIL_RESC}${RES} | "
			done
		fi

		MESG+="\n$CRM_NODE_MESG\n"
		MESG+=$(echo "$CRM_LIVE_MESG" |sed -r 's/ \| $//g')
		MESG+="\n"
		if [[ -n "$CRM_FAIL_MESG" ]]; then
			MESG+=$(echo "$CRM_FAIL_MESG" |sed -r 's/ \| $//g')
			MESG+="\n"
		fi

	elif [[ ( -z "$(ps -o pid= -C corosync 2>/dev/null)" || ( -z "$(ps -o pid= -C pacemaker 2>/dev/null)" && -z "$(ps -o pid= -C pacemakerd 2>/dev/null)" ) ) && -n "$(which crm 2>/dev/null)" && -f /etc/corosync/corosync.conf ]]; then
		MESG+="\n  ${BRED}Cluster not running!${RES}\n"
	fi


	printf "${MESG}\n"
fi

# RESTORE ORIGINAL SHELL PARAMETERS
export LC_NUMERIC="$LCNUMERICORIG" LC_COLLATE="$LCCOLLATEORIG"
