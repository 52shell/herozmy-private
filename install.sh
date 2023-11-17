#!/bin/bash

####### 入口
main() {
home
}
function home() {
clear
echo
echo "
==================================================================
		linux lxc 旁路 | 一键搭建脚本
                 Powered by www.herozmy.com 2023
                 www.lxg2016.com


     温馨提示：
         本脚本仅在lxc debian10/11环境下安装，其他环境未测试，仅为自己所用 
         本脚本仅适用于学习与研究等个人用途,请勿用于任何违法国家法律的活动！

==================================================================

回车Enter继续~
"
read
sleep 1
apt update && apt -y upgrade
echo "安装必要软件包"
apt install -y iptables nano wget curl git
install
}




function install() {
host="https://github.com/MetaCubeX/Clash.Meta/releases/download";
version="v1.16.0";
clash="clash.meta-linux-amd64-v1.16.0";
echo "自定义设置（以下设置可直接回车使用默认值）"
 echo -n "输入clash webui端口（默认9090）：" 
 read uiport 
 if [[ -z $uiport ]] 
 then 
 echo  "已设置ui端口：9090" 
 uiport=9090 
 else 
 echo "已设置ui端口：$uiport"
 fi 
 echo -n "输入订阅连接：" 
 read suburl
 if [[ -z $suburl ]] 
 then 
 echo  "已设置订阅连接地址" 
 suburl=https://
 else 
 echo "已设置订阅连接地址：$suburl" 
 fi 
echo "开始下载 clash meta"
echo 
wget ${host}/${version}/${clash}.gz
sleep 1
echo "开始解压"
gunzip ${clash}.gz >/dev/null 2>&1
sleep 1
echo "开始重命名"
mv ${clash} clash >/dev/null 2>&1
sleep 1
echo "开始添加执行权限"
chmod u+x clash >/dev/null 2>&1
sleep 1
echo "复制 clash 到 /usr/bin"
cp clash /usr/bin >/dev/null 2>&1
sleep 1
echo "创建 /etc/clash 目录"
mkdir /etc/clash >/dev/null 2>&1
cd /etc/clash
sleep 1
git init 
git remote add -f origin https://github.com/52shell/herozmy-private.git
git config core.sparsecheckout true
echo 'clash' >> .git/info/sparse-checkout
git pull origin main
cd /etc/clash/clash
sleep 1
sed -i "s|^external-controller: :.*|external-controller: :$uiport|" /etc/clash/clash/config.yaml
sed -i "s|^subscribe-url:.*|subscribe-url: $suburl|" /etc/clash/clash/config.yaml
sed -i "s|url=机场订阅|url=$suburl|" /etc/clash/clash/config.yaml
sleep 1
echo "开始创建 systemd 服务"
cat << EOF > /etc/systemd/system/clash.service
[Unit]
Description=clash auto run
 
[Service]
Type=simple
 
ExecStart=/usr/bin/clash -d /etc/clash/clash
 
[Install]
WantedBy=default.target
EOF
echo "systemd 服务创建完成"
systemctl daemon-reload
echo "设置开机自启动"
systemctl daemon-reload
systemctl enable clash.service
echo "设置开机自启动完成"
Install_firewall
return 1
}

Install_firewall()
{
sleep 1
echo "创建ip转发"
echo 'net.ipv4.ip_forward=1'>>/etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1'>>/etc/sysctl.conf
echo "ip转发创建完成"
sleep 1
echo "开始配置iptables"
iptables -t nat -N clash
iptables -t nat -A clash -d 0.0.0.0/8 -j RETURN
iptables -t nat -A clash -d 10.0.0.0/8 -j RETURN
iptables -t nat -A clash -d 127.0.0.0/8 -j RETURN
iptables -t nat -A clash -d 169.254.0.0/16 -j RETURN
iptables -t nat -A clash -d 172.16.0.0/12 -j RETURN
iptables -t nat -A clash -d 192.168.0.0/16 -j RETURN
iptables -t nat -A clash -d 224.0.0.0/4 -j RETURN
iptables -t nat -A clash -d 240.0.0.0/4 -j RETURN
iptables -t nat -A clash -p tcp -j REDIRECT --to-port 7892
iptables -t nat -A PREROUTING -p tcp -j clash
iptables -A INPUT -p udp --dport 53 -j ACCEPT
echo "安装iptables-persistent"
sleep 1
apt-get install -y iptables-persistent 
iptables-save  > /etc/iptables/rules.v4
echo "防火墙转发规则设置完成"

return 1
}
main
