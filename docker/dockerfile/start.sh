#!/bin/sh

VERSION=xdir_v1.4.0

# 下载 xdir
download() {
    cd /root && mkdir xdir && cd xdir
    wget -O ${VERSION}.tar.gz https://alist.52zr.top:4443/d/home/image/${VERSION}.tar.gz

    # 解压
    tar -xvf ${VERSION}.tar.gz --strip-components=1
     rm ${VERSION}.tar.gz
    cp -r /root/xdir/* /var/www/html/ 
    chown -R www-data:www-data /var/www/html/ 
    # 删除压缩文件
    rm -rf /root/xdir
}

# 判断目录是否为空
check() {
    if [ -z "$(ls -A /var/www/html)" ]; then
        echo "目录 /var/www/html 为空，开始部署..."
        download
    else
        echo "目录 /var/www/html 不为空，跳过下载."
    fi
}

# 调用 check 函数
check

# 启动 Apache
apache2-foreground
