
#!/bin/bash
herozmy-Logo="==========================================================================
                                                                         
               Herozmy-自用脚本                      
                  Powered by www.herozmy.com 2023                          
                      All Rights Reserved                                
                                                                         
                                by herozmy 2023-08-27                     
==========================================================================";

finishlogo="=========================================================================
                                                                         
             Herozmy-脚本运行完成                      
                  Powered by www.herozmy.com 2023                          
                      All Rights Reserved                                
                                                                         
                                by Herozmy                  
==========================================================================";
host="https://github.com/MetaCubeX/Clash.Meta/releases/download";
version="v1.16.0";
clash="clash.meta-linux-amd64-v1.16.0";
ui="https://github.com/MetaCubeX/metacubexd/releases/download/v1.129.0/compressed-dist.tgz";


echo "开始下载 clash meta"
echo 
wget -o ${host}/${version}/${clash}.gz  >/dev/null 2>&1
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
 
ExecStart=/usr/bin/clash -d /etc/clash/
 
[Install]
WantedBy=default.target
EOF

echo "systemd 服务创建完成"


echo "设置clash开机自启动"

systemctl daemon-reload
systemctl start clash.service
systemctl enable clash.service
echo "所有操作完成"
