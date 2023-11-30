## xdir文件列表程序
``` yaml
version: "3.3"
services:
  xdir:
    image: dirtest
    container_name: xdir
    volumes:
      - ./dir:/var/www/html/
    ports:
      - 8777:80
    restart: unless-stopped
```
