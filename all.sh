#!/bin/bash

# 入口
main() {
  select_action
}

# 选择菜单
select_action() {
  clear
  echo "请选择要运行的脚本"
  echo "1. linux lxc clash"
  echo "2. linux lxc mosdns"
  echo -n "输入选择（1/2）："
  read -r choice
  case $choice in
  1)
    home_clash
    ;;
  2)
    home_mosdns
    ;;
  *)
    echo "无效的选择！退出脚本"
    exit 1
    ;;
  esac
}
home_clash() {
    clear
    echo "=================================================================="
    echo -e "\t\tlinux lxc 旁路 | 一键搭建脚本"
    echo -e "\t\tPowered by www.herozmy.com 2023"
    echo -e "\t\twww.lxg2016.com\n"
    echo -e "温馨提示：\n本脚本仅在lxc debian10/11环境下安装，其他环境未测试，仅为自己所用"
    echo -e "本脚本仅适用于学习与研究等个人用途，请勿用于任何违法国家法律的活动！"
    echo "=================================================================="
    read -p "回车Enter继续~" -r
    sleep 1
    apt_update_upgrade
    install_dependencies
    install
}

# 更新系统并升级
apt_update_upgrade() {
    apt update && apt -y upgrade || { echo "更新失败！退出脚本"; exit 1; }
    echo "安装必要软件包"
}

# 安装依赖项
install_dependencies() {
    apt install -y iptables nano wget curl git || { echo "安装失败！退出脚本"; exit 1; }
}

# 安装 Clash Meta
install() {
    host="https://github.com/MetaCubeX/mihomo/releases/download"
    version="v1.17.0"
    clash="mihomo-linux-amd64-v1.17.0"

    set_timezone
    clash_customize_settings
    download_clash_meta
    extract_and_install_clash
    configure_clash
    create_systemd_service
    clash_enable_autostart
    clash_install_firewall
    clash_install_complete
   
}

# 用户自定义设置
clash_customize_settings() {
    echo "自定义设置（以下设置可直接回车使用默认值）"
    read -p "输入clash webui端口（默认9090）：" uiport
    uiport="${uiport:-9090}"
    echo "已设置ui端口：$uiport"
    
    read -p "dns监听端口：" clashport
    suburl="${clashport:-53://}"
    echo "已设置dns监听端口：$clashport"
    if [[ "$clashport" == "53" ]]; then
        modify_dns_stub_listener
    fi
}

    read -p "输入订阅连接：" suburl
    suburl="${suburl:-https://}"
    echo "已设置订阅连接地址：$suburl"
}

# 下载 Clash Meta                             
download_clash_meta() {
    echo "开始下载 Clash Meta"
    wget "${host}/${version}/${clash}.gz" || { echo "下载失败！退出脚本"; exit 1; }
}

# 解压并安装 Clash Meta
extract_and_install_clash() {
    echo "开始解压"
    gunzip "${clash}.gz" >/dev/null 2>&1
    echo "开始重命名"
    mv "${clash}" clash >/dev/null 2>&1
    echo "开始添加执行权限"
    chmod u+x clash >/dev/null 2>&1
    echo "复制 clash 到 /usr/bin"
    cp clash /usr/bin >/dev/null 2>&1
}

# 配置 Clash Meta
configure_clash() {
    echo "创建 /etc/clash 目录"
    mkdir /etc/clash >/dev/null 2>&1
    cd /etc/clash
    git_init_and_pull
    sed -i "s|^external-controller: :.*|external-controller: :$uiport|" /etc/clash/clash/config.yaml
    sed -i "s|^subscribe-url:.*|subscribe-url: $suburl|" /etc/clash/clash/config.yaml
    sed -i "s/listen: 0.0.0.0:53/listen: 0.0.0.0:$clashport/" /etc/clash/clash/config.yaml
    sed -i "s|url=机场订阅|url=$suburl|" /etc/clash/clash/config.yaml
}

# 初始化并拉取 git 仓库
git_init_and_pull() {
git init
git remote add -f origin https://github.com/52shell/herozmy-private.git
git config core.sparsecheckout true
echo 'clash' >> .git/info/sparse-checkout
git pull origin main

}

# 创建 systemd 服务
create_systemd_service() {
    echo "开始创建 systemd 服务"
    mv /etc/clash/clash/clash.service /etc/systemd/system/
    echo "systemd 服务创建完成"
    systemctl daemon-reload
}

# 设置开机自启动
clash_enable_autostart() {
    echo "设置开机自启动"
    systemctl daemon-reload
    systemctl enable clash.service
    echo "设置开机自启动完成"
}

# 安装防火墙规则
clash_install_firewall() {
    sleep 1

    echo "创建ip转发"
    echo 'net.ipv4.ip_forward=1'>>/etc/sysctl.conf
    echo 'net.ipv6.conf.all.forwarding = 1'>>/etc/sysctl.conf
    echo "ip转发创建完成"
    sleep 1

    echo "开始配置iptables"
    echo "安装iptables-persistent"
    sleep 1
    apt install -y iptables-persistent
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
    sleep 1
    iptables-save  > /etc/iptables/rules.v4
    sleep 1
    echo "防火墙转发规则设置完成"
    sleep 1
}

# 安装完成
clash_install_complete() {
   # clear
    echo "lxc clash旁路由安装完成"
    echo "-----------------------------------"
    echo "clash webui地址:http://ip:$uiport/ui"
    echo "-----------------------------------"
    echo "系统即将重启"
    sleep 3
    reboot
}


###### clash部分结束

home_mosdns() {
    clear
    echo -e "\n=================================================================="
    echo -e "\t\tlinux lxc mosdns | 一键搭建脚本"
    echo -e "\t\tPowered by www.herozmy.com 2023"
    echo -e "\t\twww.lxg2016.com\n"
    echo -e "温馨提示：\n本脚本仅在lxc debian10/11环境下安装，其他环境未测试，仅为自己所用"
    echo -e "本脚本仅适用于学习与研究等个人用途，请勿用于任何违法国家法律的活动！"
    echo -e "==================================================================\n"
    read -p "回车Enter继续~" -r
    sleep 1
    apt_update_upgrade || exit 1
    install_dependencies || exit 1
    mosdns_install || exit 1
}


set_timezone() {
    echo -e "\n设置时区为Asia/Shanghai"
    timedatectl set-timezone Asia/Shanghai || { echo -e "\e[31m时区设置失败！退出脚本\e[0m"; exit 1; }
    echo -e "\e[32m时区设置成功\e[0m"
}

# 安装 mosdns
mosdns_install() {
    local mosdns_host="https://github.com/IrineSistiana/mosdns/releases/download/v4.5.3/mosdns-linux-amd64.zip"
    set_timezone
    mosdns_customize_settings
    download_mosdns
    extract_and_install_mosdns
    configure_mosdns
    mosdns_enable_autostart
    install_complete
}

# 用户自定义设置
mosdns_customize_settings() {
    echo -e "\n自定义设置（以下设置可直接回车使用默认值）"
    read -p "输入mosdns端口（默认53）：" dnsport
    uiport="${dnsport:-53}"
    echo -e "已设置mosdns端口：\e[36m$dnsport\e[0m"

    if [[ "$dnsport" == "53" ]]; then
        modify_dns_stub_listener
    fi
}

# 下载 mosdns
download_mosdns() {
    echo "开始下载 mosdns"
    wget "${mosdns_host}" || { echo -e "\e[31m下载失败！退出脚本\e[0m"; exit 1; }
}

# 解压并安装 mosdns   
extract_and_install_mosdns() {
    echo "开始解压"
    unzip ./mosdns-linux-amd64.zip >/dev/null 2>&1
    echo "复制 mosdns 到 /usr/bin"
    sleep 1
    cp -rv ./mosdns /usr/bin >/dev/null 2>&1
    chmod 0777 /usr/bin/mosdns >/dev/null 2>&1
}

# 配置 easymosdns
configure_mosdns() {
    echo "克隆easymosdns仓库"
    sleep 1
    cd /etc >/dev/null 2>&1
    git clone https://github.com/pmkol/easymosdns.git
    mv ./easymosdns ./mosdns >/dev/null 2>&1
    echo "配置mosdns"
    sed -i "s|addr: \"0.0.0.0:53\"|addr: \"0.0.0.0:$dnsport\"|g" /etc/mosdns/config.yaml

}

# 修改 DNSStubListener
modify_dns_stub_listener() {
    echo "dns端口设置为53，关闭DNSStubListener"
    sed -i '/^#*DNSStubListener/s/#*DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf
    systemctl restart systemd-resolved.service
}

# 开机自启动 服务
mosdns_enable_autostart() {
    echo "设置mosdns开机自启动"
    mosdns service install -d /etc/mosdns -c /etc/mosdns/config.yaml
    echo "mosdns开机启动完成"
    sleep 1
}

# 安装完成
install_complete() {
    clear
    echo -e "\nlxc mosdns安装完成"
    echo -e "-----------------------------------"
    echo -e "-----------------------------------"
    echo -e "系统即将重启"
    sleep 3
    reboot
}
main
