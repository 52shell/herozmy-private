#!/bin/bash
echo "开始下载 clash meta"
wget https://github.com/MetaCubeX/Clash.Meta/releases/download/v1.16.0/clash.meta-linux-amd64-v1.16.0.gz
echo "clash meta 下载完成"

echo "开始解压"
gunzip clash.meta-linux-amd64-v1.16.0.gz
echo "解压完成"

echo "开始重命名"
mv clash.meta-linux-amd64-v1.16.0 clash
echo "重命名完成"

echo "开始添加执行权限"
chmod u+x clash
echo "执行权限添加完成"

echo "开始复制 clash 到 /usr/bin"
cp clash /usr/bin
echo "复制完成"

echo "开始创建 /etc/clash 目录"
mkdir /etc/clash
echo "/etc/clash 目录创建完成"

echo "开始下载 webui"
cd /etc/clash
wget https://github.com/MetaCubeX/metacubexd/releases/download/v1.129.0/compressed-dist.tgz
echo "webui 下载完成"

echo "开始解压 webui"
tar -zxvf compressed-dist.tgz
echo "webui 解压完成"

echo "开始重命名 yacd"
mv public ui
echo "yacd 重命名完成"

echo "创建ip转发"
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
echo "ip转发创建完成"

echo "开始创建 systemd 服务"

sudo tee /etc/systemd/system/clash.service > /dev/null <<EOF
[Unit]
Description=clash auto run
 
[Service]
Type=simple
 
ExecStart=/usr/bin/clash -d /etc/clash/
 
[Install]
WantedBy=default.target
EOF

echo "systemd 服务创建完成"

echo "所有操作完成"
