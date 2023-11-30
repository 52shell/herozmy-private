FROM php:7.4-apache

# 安装所需的 PHP 扩展和依赖
RUN apt-get update && apt-get install -y \
    libzip-dev \
    wget \
    zip \
    libxml2-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    tar \
    && docker-php-ext-install -j$(nproc) zip 

# 下载并解压 Directory Lister
#WORKDIR /var/www/html/
#ADD https://alist.52zr.top:4443/d/home/image/xdir.tar.gz /var/www/html/

# 解压文件并删除压缩包
#RUN tar -xzf xdir.tar.gz --strip-components=1 && rm xdir.tar.gz

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
#COPY xdir /var/www/html/
# 配置 Apache 服务器
RUN a2enmod rewrite
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf

# 设置文件权限
RUN chown -R www-data:www-data /var/www/html/

# 暴露容器的 80 端口
EXPOSE 80

# 指定容器启动时执行的命令
#CMD ["apache2-foreground"]

# 声明持久化数据卷
VOLUME /var/www/html

CMD ["bash", "/usr/local/bin/start.sh"]
