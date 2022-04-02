#!/bin/sh

yum update

# 从官网下载docker安装脚本
curl -sSL https://get.docker.com/ | sh

# 启动docker
systemctl start docker

# docker容器拉取qbittorrent
docker pull linuxserver/qbittorrent

# 创建docker容器需要的文件夹
mkdir -p /root/downloads/
mkdir -p /root/docker/qbittorrent/config/

# 开放防火墙端口
firewall-cmd --zone=pulic --add-port=8999/tcp --permanent
firewall-cmd --zone=pulic --add-port=8999/udp --permanent
firewall-cmd --zone=pulic --add-port=9090/tcp --permanent
firewall-cmd --zone=pulic --add-port=18081/tcp --permanent
firewall-cmd --reload

# 创建并启动qbittorrent的docker容器
# 容器命名为qbittorrent，开放9090端口作为Web UI访问端口，注意防火墙设置
# 以http://{server_ip}:9090访问Web UI
docker run \
  --name=qbittorrent \
  -it \
  -d \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Aisa/Shanghai \
  -e UMASK_SET=022 \
  -e WEBUI_PORT=9090 \
  -p 8999:8999 \
  -p 8999:8999/udp \
  -p 9090:9090 \
  -v /root/docker/qbittorrent/config:/config \
  -v /root/downloads:/downloads \
  --restart unless-stopped \
  linuxserver/qbittorrent

# qbittorrent的Web UI默认账户信息
# User: admin
# Password: adminadmin


# 使用nginx作为文件服务器
# 将宿主机目录/root/downloads挂载到容器的/data目录，从而将其暴露出去
# niginx的两个conf配置文件同样也挂载
# 以http://{server_ip}:18081访问文件服务器
docker run -d -p 18081:18081 --name file-server \
           -v /root/downloads:/data \
           -v /root/docker/nginx/nginx.conf:/etc/nginx/nginx.conf \
           -v /root/docker/nginx/nginx-file-server.conf:/etc/nginx/conf.d/nginx-file-server.conf nginx



