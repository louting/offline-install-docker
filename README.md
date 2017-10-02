# offline-install-docker
# QQ:34530529
## 中文说明： 
	离线安装docker脚本，centos7 和ubuntu14.04 + 验证通过。
	工程内封装的docker版本为：docker-17.04.0-ce
 	参考下面的option配置加速器，加速器使用的daocloud镜像，可以通过修改文件修改为阿里的镜像服务器。目前来看阿里的速度更快。
 	加速器使用我个人的加速账号，貌似公用也没问题。

```shell
Directory structure
.
├── bin
│   ├── docker
│   │   ├── completion
│   │   │   ├── bash
│   │   │   │   └── docker
│   │   │   ├── fish
│   │   │   │   └── docker.fish
│   │   │   └── zsh
│   │   │       └── _docker
│   │   ├── docker
│   │   ├── docker-containerd
│   │   ├── docker-containerd-ctr
│   │   ├── docker-containerd-shim
│   │   ├── dockerd
│   │   ├── docker-init
│   │   ├── docker-proxy
│   │   └── docker-runc
│   └── docker-17.04.0-ce.tgz
├── init
│   ├── docker.conf
│   └── docker.service
├── init.d
│   └── docker
├── offline_install_docker.sh
├── opt
│   ├── daemon.json
│   ├── docker
│   └── docker.centos
├── README.md
├── rpm_package
│   ├── docker-engine-selinux-17.05.0.ce-1.el7.centos.noarch.rpm
│   ├── libgudev1-219-30.el7_3.8.x86_64.rpm
│   ├── libseccomp-2.3.1-2.el7.x86_64.rpm
│   ├── libselinux-2.5-6.el7.x86_64.rpm
│   ├── libselinux-python-2.5-6.el7.x86_64.rpm
│   ├── libselinux-utils-2.5-6.el7.x86_64.rpm
│   ├── libsemanage-2.5-5.1.el7_3.x86_64.rpm
│   ├── libsemanage-python-2.5-5.1.el7_3.x86_64.rpm
│   ├── libsepol-2.5-6.el7.x86_64.rpm
│   ├── libtool-ltdl-2.4.2-22.el7_3.x86_64.rpm
│   ├── policycoreutils-2.5-11.el7_3.x86_64.rpm
│   ├── policycoreutils-python-2.5-11.el7_3.x86_64.rpm
│   ├── selinux-policy-3.13.1-102.el7_3.16.noarch.rpm
│   ├── selinux-policy-targeted-3.13.1-102.el7_3.16.noarch.rpm
│   ├── setools-libs-3.3.8-1.1.el7.x86_64.rpm
│   ├── systemd-219-30.el7_3.8.x86_64.rpm
│   ├── systemd-libs-219-30.el7_3.8.x86_64.rpm
│   └── systemd-sysv-219-30.el7_3.8.x86_64.rpm
└── uninstall_docker.sh
```
## Function describe (support list):
    Server      Version
                Ubuntu      ubuntu-14.04.4-server-amd64 & and later
                Centos7     CentOS-7-x86_64-Minimal-1511 & and later
 
## Use guide:
    Install:
        bash offline_install_docker.sh
        or
        chmod 755 ./offline_install_docker.sh
        ./offline_install_docker.sh
     
    Uninstall:
        bash uninstall_docker.sh
        or
        chmod 755 ./uninstall_docker.sh
        ./uninstall_docker.sh
 
## Reference:
    https://get.docker.com/
    https://get.docker.com/builds/
    https://github.com/docker/docker/releases

## Option:
    1).If you want to change docker Storage base:
 
        ubuntu: please copy opt/docker to /etc/default/docker,
        centos: please copy opt/docker.centos to /etc/sysconfig/

    And edit it for what you want.

    2).Use mirro registry:
        ubuntu: please copy opt/daemon.json to /etc/docker
        centos: Please copy opt/docker.centos to /etc/sysconfig/, and edit file opt/docker.centos for what you want.

    You must `restart docker daemon` or `systemctl restart docker.service` to valid these option.
