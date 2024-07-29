#!/bin/bash

# vi = vim
[[ -n $(which vim 2>/dev/null) ]] && alias vi="vim"

# file operations
alias mkdir="mkdir -pv"
#alias cp="cp -v"
#alias mv="mv -v"
#alias rm="rm -v"

# ls
alias ls="ls --color=auto"
alias ll="ls -hlF"
alias la="ls -AhlF"
alias le="ls -ACF"
alias l="ls -CF"

# grep
alias grep="grep --color=auto"

# less
alias less="less -R"

# pwgen
alias bpwgen="pwgen -cnsB1r yzYZ"

# dig
alias digs="dig +short"

# netstat
alias fnetstat="netstat -tulnapee"

# df
alias dfs="df -hT | grep -Pv 'etc/pve|cdrom|/snap/' | grep -P '^(Filesystem|/dev[^\s]*|((25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9]):/[^\s]*)' | grep -P '/[^\s]*\s*$|$'"
alias dfi="df -iT | grep -Ev 'etc/pve|cdrom|/snap/' | grep -P '^(Filesystem|/dev[^\s]*|((25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9]):/[^\s]*)' | grep -P '/[^\s]*\s*$|$'"

# mount
alias mnt="mount | sed -r 's/ (on|type) / /g;s/[\(\)]//g' | grep -Pv '^udev|cdrom|proc|sunrpc|fusectl|gvfsd|systemd|pstore|mqueue|binfmt|nfsd|etc/pve|/sys/fs/bpf|/run/user/1000/doc|\s+(iso9660|udf|(sys|security|efivar|selinux|debug|hugetlb|rpc_pipe|config|trace|(fuse\.)?lxc|(dev)?tmp)fs|devpts|cgroup2?)\s+' | column -t | sed 's/,/ /g'"
alias mntf="mount | sed -r 's/ (on|type) / /g;s/[\(\)]//g' | column -t | sed 's/,/ /g'"

# top tools
alias iotop="iotop -o"
alias mytop="mytop --color -s1"
alias innotop="innotop --color --delay 1"
alias hatop="hatop -s /run/haproxy/admin.sock"

# apache2
alias a2="apache2ctl"
alias a2l="apache2ctl -t && systemctl reload apache2.service"
alias a2r="apache2ctl -t && systemctl restart apache2.service"
alias a2s="apache2ctl -S"
alias a2t="apache2ctl -t"

# nginx
alias nx="nginx"
alias nxl="nginx -t && systemctl reload nginx.service"
alias nxr="nginx -t && systemctl restart nginx.service"
alias nxt="nginx -t"

# mysql/mariadb
alias sqlprocs="curl -fsSL https://bin.craven.cc/analyze_sql_processlist.sh | bash"
alias sqlslavestat="mysql -e 'SHOW SLAVE STATUS\G' | grep -Pi '^\s*(Seconds_Behind_Master:|Slave_(IO|SQL)_Running:(?!\s*Yes)|Using_Gtid:|Gtid_IO_Pos:|Last(_(IO|SQL))?_Errno:(?!\s*0)|Last(_(IO|SQL))?_Error:(?!\s*$))'"

# stuff
alias whatsmyip="curl ip.craven.cc"

alias lower="tr '[:upper:]' '[:lower:]'"
alias upper="tr '[:lower:]' '[:upper:]'"

alias roulette='[[ $(( $RANDOM % 6 )) -eq 0 ]] && echo BOOM || echo click'
alias flipcoin='[[ $(( $RANDOM % 2 )) -eq 0 ]] && echo heads || echo tails'
