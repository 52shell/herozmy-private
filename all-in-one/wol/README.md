## wol远程唤醒：在BIOS里开启Wake on lan, ubuntu也需要设置，才能支持Wake on Lan

``` shell
sudo apt-get install ethtool
```
查看网卡名称```ip addr```
我这里是enp7s0，可能是eth0,eth1,enp2s0之类的，同时记录网卡的mac地址，发送唤醒包需要
```sudo ethtool enp7s0 |grep Wake-on ```
查询是否开启了远程唤醒。d为关闭g为开启，如果为d可以运行以下开启：
```sudo ethtool -s enp7s0 wol g```
关机，就可以远程唤醒了，但是再次启动以后 远程唤醒又会关闭，所以我们要设置开机自动开启唤醒，

添加开机自启动服务：``` sudo nano /etc/systemd/system/wol.service```
```
[Unit]
Description=Wake-on-LAN

[Service]
Type=oneshot
ExecStartPre=/bin/sleep 20
ExecStart=/sbin/ethtool -s enp7s0 wol g
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
```
这里我设置了延迟20S启动，因为不延迟，可能会导致启动失败。

保存配置，启用

```
sudo systemctl enable wol
sudo systemctl start wol
```
