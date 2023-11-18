#!/bin/bash

# 入口
main() {
    home
}

# 主菜单
home() {
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
    set_timezone || exit 1
    apt_update_upgrade || exit 1
    install_dependencies || exit 1
    install || exit 1
}

# 设置时区
set_timezone() {
    echo -e "\n设置时区为Asia/Shanghai"
    timedatectl set-timezone Asia/Shanghai || { echo -e "\e[31m时区设置失败！退出脚本\e[0m"; exit 1; }
    echo -e "\e[32m时区设置成功\e[0m"
}

# 更新系统并升级
apt_update_upgrade() {
    echo "更新系统并升级"
    apt update && apt -y upgrade || { echo -e "\e[31m更新失败！退出脚本\e[0m"; exit 1; }
    echo -e "\e[32m安装必要软件包\e[0m"
}

# 安装依赖项
install_dependencies() {
    echo "安装依赖项"
    apt-get install curl wget git cron unzip nano -y || { echo -e "\e[31m安装失败！退出脚本\e[0m"; exit 1; }
}

# 安装 mosdns
install() {
    local mosdns_host="https://github.com/IrineSistiana/mosdns/releases/download/v4.5.3/mosdns-linux-amd64.zip"
    
    customize_settings || exit 1
    download_mosdns || exit 1
    extract_and_install_mosdns || exit 1
    configure_mosdns || exit 1
    enable_autostart || exit 1
    install_complete
}

# 用户自定义设置
customize_settings() {
    echo -e "\n自定义设置（以下设置可直接回车使用默认值）"
    read -p "输入mosdns端口（默认53）：" uiport
    uiport="${uiport:-53}"
    echo -e "已设置ui端口：\e[36m$uiport\e[0m"
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
    echo -e "ui-port: ${uiport}\ntimezone: Asia/Shanghai" >> /etc/mosdns/config.yaml
}

# 开机自启动 服务
enable_autostart() {
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
    echo -e "系统即将重启"
    echo -e "-----------------------------------"
    sleep 3
    reboot
}

main
