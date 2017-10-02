#!/bin/bash
#===============================================================================
#          file:  uninstall_docker.sh
#         usage:  ./uninstall_docker.sh 
# 
#   description:  
#        author:  tony lt@zqf.com.cn
#       version:  1.0
#       created:  11/01/2017 18:39:30 cst
#      revision:  ---
#===============================================================================

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

function log() {
    local prefix=$(date +'[%Y-%m-%d %H:%M:%S]')
    echo "$prefix $@" >&2
}

function check_root() {
    log "Check root account ---- start ----"
    if [ 0 -ne $UID ]; then
        log "Error: Please use ROOT account to execute the script"
        exit 1
    fi
    log "Check root account ---- end ----"
}

function check_release() {
    local release=""

    log "Check release version ---- start ----"
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        release='CentOS'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
        release='RHEL'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        release='Debian'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        release='Ubuntu'
    else
        release='unknow'
    fi
    echo $release

    log "Check release version ---- end ----"
}

function deb_uninstall() {
    log "Debian or Ubuntu server uninstall ---- start ----"
    if service docker stop &> /dev/null || (docker version | grep "Version" &> /dev/null); then
        # Delete docker binary
        rm -f /usr/bin/docker
        # Delete docker service script file
        rm -f /etc/init.d/docker
        rm -f /etc/init/docker.conf
        # Delete /etc/docker/key.json
        rm -rf /etc/docker
        # Deletea boot cmd
        sed -i '/^service/d' /etc/rc.local
        log "Uninstall docker service success"
    else
        log "Notice: Please make sure that the Docker service is installed"
        exit 1
    fi
    log "Debian or Ubuntu server uninstall ---- end ----"
}

function rh_uninstall() {
    log "rhel or centos server uninstall ---- start ----"

    rm -f /usr/bin/docker
    rm -rf /etc/docker
    # Remove boot start command to "rc.local" file
    sed -i '/^docker/d' /etc/rc.d/rc.local
    chmod 644 /etc/rc.d/rc.local
    log "Uninstall docker service success"
    log "RHEL or CentOS server install ---- end ----"
}

function uninstall() {
    local release=$(check_release)

    read -p "Please enter (yes) to confirm the uninstall:" read_enter
    if [ $read_enter == "yes" ]; then
        case "$release" in
            "Ubuntu" | "Debian" )
                deb_uninstall
                ;;
            "CentOS" | "RHEL" )
                rh_uninstall
                ;;
            *)
                log "Error: can not support uninstall"
                exit 1
                ;;
        esac
    else
        log "Please enter (yes) to confirm the uninstall"
    fi
}
# -------- shell entrance ---------
check_root
uninstall

# -------- shell end ---------
