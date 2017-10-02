#!/bin/bash
#===============================================================================
#          file:  offline_install_docker.sh
#         usage:  ./offline_install_docker.sh 
# 
#   description:  
#        author:  tony
#       version:  1.0
#       created:  11/01/2017 18:05:30 cst
#      revision:  ---
#===============================================================================

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

sh_c='sh -c'

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

function check_file() {
    log "Check file ---- start ----"
    [ -f ./init.d/docker ] || ( log "Error: docker service shell not exist"; exit 1 )
    [ -f ./init/docker.conf ] || ( log "Error: docker configure not exist"; exit 1 )
    [ -f ./bin/docker-17.04.0-ce.tgz ] || ( log "Error: docker binary file not exist"; exit 1 )
    log "Check file ---- end ----"
}

function check_bit() {
    log "Check bit ---- start ----"
    case "$(uname -m)" in
        *64)
            ;;
        *)
            log "Error: you are not using a 64bit platform, Docker currently only supports 64bit platforms"
            exit 1
            ;;
    esac
    log "Check bit ---- end ----"
}

# Install aufs support for ubuntn and deb
function aufs_support() {
    if ! grep -q aufs /proc/filesystems && ! $sh_c 'modprobe aufs'; then
        if uname -r | grep -q -- '-generic' && dpkg -l 'linux-image-*-generic' | grep -qE '^ii|^hi' 2>/dev/null; then
            kern_extras="linux-image-extra-$(uname -r) linux-image-extra-virtual"

            apt_get_update
            ( set -x; $sh_c 'sleep 3; apt-get update' )

            if ! grep -q aufs /proc/filesystems && ! $sh_c 'modprobe aufs'; then
                echo >&2 'Warning: tried to install '"$kern_extras"' (for AUFS)'
                echo >&2 ' but we still have no AUFS.  Docker may not work. Proceeding anyways!'
                ( set -x; sleep 3 )
            fi
         else
            echo >&2 'Warning: current kernel is not supported by the linux-image-extra-virtual'
            echo >&2 ' package.  We have no AUFS support.  Consider installing the packages'
            echo >&2 ' linux-image-virtual kernel and linux-image-extra-virtual for AUFS support.'
            ( set -x; sleep 3 )
         fi
    fi
}

#Install dependance for rhel 7
function rpm_package() {
    rpm --nodeps -Uvh ./rpm_package/* 
    cp ./init/docker.service /usr/lib/systemd/system/
}

# Current support Ubuntu server 14.04+
function deb_install() {
    log "Debian or Ubuntu server install ---- start ----"
    # Add execute for shell and copy docker binary file
    chmod 755 ./init.d/docker   
    cp ./init.d/docker /etc/init.d/
    cp ./init/docker.conf /etc/init/
    tar xf ./bin/docker-17.04.0-ce.tgz -C ./bin
    cp ./bin/docker/* /usr/bin/
    
    if update-rc.d docker defaults 95 &> /dev/null; then
        log "System start/stop links for /etc/init.d/docker success"
    else
        log "System start/stop links for /etc/init.d/docker failed"
        exit 1
    fi

    # start docker service
    if service docker start &> /dev/null; then
        log "Notice: Docker service start success"
    else
        log "Error: Docker service start failed, please check /etc/init/docker.conf"
        exit 1
    fi
    
    # Add boot start command to "rc.local" file
    sed -i '/^exit/i\service docker start' /etc/rc.local
    log "Debian or Ubuntu server install ---- end ----"
}

# Only support RHEL/CentOS 7+
function rh_install() {
    log "RHEL or CentOS server install ---- start ----"
    tar xf ./bin/docker-17.04.0-ce.tgz -C ./bin
    cp ./bin/docker/* /usr/bin/

    # Start docker service
#    (docker daemon &) &> /dev/null
     systemctl start docker

    # Add boot start command to "rc.local" file
    cp ./init/80-docker.rules /etc/udev/rules.d/ 
#    echo "docker daemon &" >> /etc/rc.d/rc.local

#    chmod 744 /etc/rc.d/rc.local
    log "RHEL or CentOS server install ---- end ----"
}

function offline_install() {
    log "Offline install docker ---- start ----"
    local release=$(check_release)
    case "$release" in 
        "Ubuntu" | "Debian" )
            aufs_support
            deb_install
            ;;
        "CentOS" | "RHEL" )
            rpm_package
            rh_install
            ;;
        *)
            log "Error: can not install"
            exit 1
            ;;
    esac
    log "Offline install docker ---- end ----"
}

function verify_docker() {
    if command -v docker &> /dev/null && [ -e /var/run/docker.sock ]; then
        log "Notice: Docker install success"
    else
        log "Error: Docker install failed"
    fi
}

# -------- shell entrance ---------
check_root
check_file
check_bit
offline_install
verify_docker

# -------- shell end ---------
