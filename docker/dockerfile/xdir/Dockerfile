FROM lsiobase/nginx:3.11

# set label
LABEL maintainer="herozmy"

RUN \
 echo "**** 安装软件包 ****" && \
 apk add --no-cache  \
	curl \
	memcached \
	php7-memcached \
	php7-tidy \
	tar && \
 echo "**** 安装configure php-fpm ****" && \
 
 sed -i 's/;clear_env = no/clear_env = no/g' /etc/php7/php-fpm.d/www.conf && \
 echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php7/php-fpm.conf && \
 
 
 
 echo "**** 安装 xdir ****" && \
 mkdir -p\
	/data && \

 curl -o \
 /tmp/xdir.tar.gz -L \
	"https://xdir.herozmy.com/xdir.tar.gz" && \
	
 tar xf \
 /tmp/xdir.tar.gz -C \
	/data/ --strip-components=1 && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/*

# copy local files
COPY root/ /


VOLUME /data /config
