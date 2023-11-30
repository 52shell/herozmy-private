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

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
RUN a2enmod rewrite
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf
# 设置文件权限
RUN chown -R www-data:www-data /var/www/html/
# 暴露容器的 80 端口
EXPOSE 80
# 声明持久化数据卷
VOLUME /var/www/html
CMD ["bash", "/usr/local/bin/start.sh"]
