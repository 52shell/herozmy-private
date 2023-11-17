#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin


function update() {
apt install git wget nano curl -y



return 1
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
echo "开始重命名"
mv ${clash} clash >/dev/null 2>&1
echo "开始添加执行权限"
chmod u+x clash >/dev/null 2>&1
echo "复制 clash 到 /usr/bin"
cp clash /usr/bin >/dev/null 2>&1
echo "创建 /etc/clash 目录"
mkdir /etc/clash >/dev/null 2>&1
cd /etc/clash
git init 
git remote add -f origin https://github.com/52shell/herozmy-private.git
git config core.sparsecheckout true
echo 'clash' >> .git/info/sparse-checkout
git pull origin main
cd /etc/clash/clash
sed -i "s|^external-controller: :.*|external-controller: :$uiport|" /etc/clash/clash/config.yaml
sed -i "s|^subscribe-url:.*|subscribe-url: $suburl|" /etc/clash/clash/config.yaml
sed -i "s|url=机场订阅|url=$suburl|" /etc/clash/clash/config.yaml

echo "创建ip转发"
echo 'net.ipv4.ip_forward=1'>>/etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1'>>/etc/sysctl.conf
#echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
#echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
echo "ip转发创建完成"

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

return 1
}


update
install
