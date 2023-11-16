## Ubuntu  nas all in one记录
### 开启远程ssh
``` shell
sudo apt install openssh-server
sudo nano /etc/ssh/sshd.conf
# PermitRootLogin yes
reboot
或者：
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
```
### docker安装
``` shell
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker
sudo systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```
### Macvlan配置
创建macvlan并互通
``` shell
docker network create -d macvlan --subnet=10.10.10.0/24 --gateway=10.10.10.10 -o parent=br0 macvlan
nmcli con add con-name macvlan-router type macvlan ifname macvlan-router dev br0 mode bridge ip4 10.10.10.2/24 gw4 10.10.10.10
nmcli con mod macvlan-router ipv4.dns 10.10.10.10
```
docker-compose编写格式:
``` yaml
    networks:
      macvlan:
         ipv4_address: 10.10.10.98
    dns:
      - 114.114.114.114

networks:
  macvlan:
    external: true
    name: macvlan

```

kvm安装
``` shell
sudo apt update
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-manager
sudo adduser <your_username> libvirt
sudo adduser <your_username> libvirt-qemu
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo apt install virt-manager
```
编写br0网桥使虚拟机网络自动分配主路由相同网段: 
```sudo nano /etc/netplan/01-br0.yaml```
``` yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eno1:
      dhcp4: no
      dhcp6: no
  bridges:
    br0:
      interfaces: [eno1]
      addresses: [10.10.10.139/24]
      routes:
        - to: 0.0.0.0/0
          via: 10.10.10.10
      nameservers:
        addresses: [10.10.10.10]
``` 


``` shell
sudo netplan apply
``` 
``` shell
. /etc/os-release
sudo apt install -t ${VERSION_CODENAME}-backports cockpit
默认情况下，/etc/cockpit/disallowed-users默认禁用root登录，因此，如果您想允许root登录，则需要从该文件中删除root或者注释

sudo mkdir -p /usr/lib/x86_64-linux-gnu/udisks2/modules
sudo systemctl restart cockpit


zfs插件:
git clone https://github.com/45drives/cockpit-zfs-manager.git
sudo cp -r cockpit-zfs-manager/zfs /usr/share/cockpit
文件共享插件:
curl -sSL https://repo.45drives.com/setup | sudo bash
sudo apt-get update
sudo apt install cockpit-file-sharing
文件管理:
wget https://github.com/45Drives/cockpit-navigator/releases/download/v0.5.10/cockpit-navigator_0.5.10-1focal_all.deb
apt install ./cockpit-navigator_0.5.10-1focal_all.deb
``` 

N卡驱动安装
``` shell
N卡安装驱动
添加NVIDIA的PPA存储库。执行以下命令：

sudo add-apt-repository ppa:graphics-drivers/ppa

更新软件包列表。执行以下命令：

sudo apt-get update

安装最新版本的NVIDIA驱动程序。执行以下命令：

sudo apt-get install nvidia-driver

```
lxd安装
```sudo apt update```
如果未安装snapd软件包，运行以下命令：
```sudo apt install snapd```
安装snapd后，可以使用snap命令安装LXC。运行以下命令以安装LXD snap软件包：
```sudo snap install lxd```

lxd init
``` 
* Would you like to use LXD clustering? (yes/no) [default=no]:
* Do you want to configure a new storage pool? (yes/no) [default=yes]:
* Name of the new storage pool [default=default]: lxd
* Name of the storage backend to use (btrfs, ceph, dir, lvm, zfs) [default=zfs]:
* Create a new ZFS pool? (yes/no) [default=yes]:
* Would you like to use an existing empty block device (e.g. a disk or partition)? (yes/no) [default=no]: Size in GiB of the new loop device (1GiB minimum) [default=21GiB]:
* Would you like to connect to a MAAS server? (yes/no) [default=no]:
* Would you like to create a new local network bridge? (yes/no) [default=yes]: no -Would you like to configure LXD to use an existing bridge or host interface? (yes/no) [default=no]: yes -Name of the existing bridge or host interface: br0
* Would you like the LXD server to be available over the network? (yes/no) [default=no]:
* Would you like stale cached images to be updated automatically? (yes/no) [default=yes]:
* Would you like a YAML “lxd init” preseed to be printed? (yes/no) [default=no]:
```
使用的br0的网络,这样可以dhcp分配同网段.方便使用,可能会出现docker lxc网络问题这这里可以这么解决
``` 
sudo apt-get install iptables-persistent 
sudo nano /etc/iptables/rules.v4
```
下面代码加入进去
``` 
*filter
:DOCKER-USER - [0:0]
-I DOCKER-USER -i br0 -o br0 -j ACCEPT
COMMIT

``` 

ups
```
sudo apt install apcupsd
sudo nano /etc/apcupsd/apcupsd.conf
```
```
UPSCABLE usb：设置 ups 和主机的连接线材。这里设置为 usb

UPSTYPE usb：设置 ups 和主机之间的连接方式。这里设置为 usb

# DEVICE /dev/ttyS0：使用 usb 线材连接 ups 和 主机，此行需要注释掉。

TIMEOUT 30：设置停电后，电池开始供电多少秒后，开始关闭系统。这里设置为 30 秒

KILLDELAY 0：设置电池供电多少秒后，关闭 UPS。这里设置为 0 禁用，担心 主机没有完全关机，ups 就主动断电了。

以下是可选设置项，参数值为本文使用，保持默认即可，也可以自定义：

BATTERYLEVEL 30：设置停电后，使用电池供电时，电池电量剩余小于等于 30% 时，执行关闭系统操作。

MINUTES 10：设置停电后，使用电池供电时，电池电量供电剩余时间小于 10 分钟时，执行关闭系统操作。

ONBATTERYDELAY 6：从检测到电源故障到 apcupsd 对事件做出反应的秒数。
```
```
sudo systemctl restart apcupsd.service
sudo systemctl status apcupsd.service
sudo systemctl enable apcupsd.service
```
