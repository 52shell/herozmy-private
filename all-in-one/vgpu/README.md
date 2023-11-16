## vgpu

先查看内核：```uname -r ```如果为6.x内核需要先降级为5.x内核，这里为使用的是第三方内核xanmod,

下载内核:
```
https://sourceforge.net/projects/xanmod/files/releases/lts/5.15.95-xanmod1/
```
下载linux-image和linux-header两个文件

上传到root目录（随意吧），执行：
```
sudo dpkg -i linux-image-*xanmod*.deb linux-headers-*xanmod*.deb
```
安装完成以后reboot,重启完成以后uname -r,查看内核是否为5.15.95-xanmod1

记录下命令备用：
```
查看已有内核：
dpkg --list | grep linux-image
删除内核
apt-get purge linux-image-x.x.x-x-generic
删除软件包
apt-get autoremove --purge
```

宿主机安装vgpu驱动

安装必要的软件包：
```
chmod +x N卡驱动
./N卡驱动
```
安装完成以后reboot,查看nvidia-smi是否成功，mdevctl types 验证是否出现mdev设备
```
root@herozmy-server:~# nvidia-smi 
Tue Aug 29 22:01:27 2023       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 525.105.14   Driver Version: 525.105.14   CUDA Version: N/A      |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  Tesla P4            On   | 00000000:01:00.0 Off |                    0 |
| N/A   39C    P8    10W /  75W |     27MiB /  7680MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```
```
root@herozmy-server:~# mdevctl types
0000:01:00.0
  nvidia-157
    Available instances: 0
    Device API: vfio-pci
    Name: GRID P4-2B
    Description: num_heads=4, frl_config=45, framebuffer=2048M, max_resolution=5120x2880, max_instance=4
  nvidia-214
    Available instances: 0
    Device API: vfio-pci
    Name: GRID P4-2B4
    Description: num_heads=4, frl_config=45, framebuffer=2048M, max_resolution=5120x2880, max_instance=4
  nvidia-243
    Available instances: 0
    Device API: vfio-pci
    Name: GRID P4-1B4
    Description: num_heads=4, frl_config=45, framebuffer=1024M, max_resolution=5120x2880, max_instance=8
  nvidia-288
    Available instances: 0
    Device API: vfio-pci
    Name: GRID P4-4C
    Description: num_heads=1, frl_config=60, framebuffer=4096M, max_resolution=4096x2400, max_instance=2
  nvidia-289
    Available instances: 0
    Device API: vfio-pci
    Name: GRID P4-8C
    Description: num_heads=1, frl_config=60, framebuffer=8192M, max_resolution=4096x2400, max_instance=1
  nvidia-63
    Available instances: 0
    Device API: vfio-pci
    Name: GRID P4-1Q
    Description: num_heads=4, frl_config=60, framebuffer=1024M, max_resolution=5120x2880, max_instance=8
  nvidia-64
    Available instances: 0
    Device API: vfio-pci
    Name: GRID P4-2Q
    Description: num_heads=4, frl_config=60, framebuffer=2048M, max_resolution=7680x4320, max_instance=4
  nvidia-65
    Available instances: 0
    Device API: vfio-pci
    Name: GRID P4-4Q
    Description: num_heads=4, frl_config=60, framebuffer=4096M, max_resolution=7680x4320, max_instance=2
  nvidia-66
    Available instances: 0
    Device API: vfio-pci
    Name: GRID P4-8Q
    Description: num_heads=4, frl_config=60, framebuffer=8192M, max_resolution=7680x4320, max_instance=1
  nvidia-67
    Available instances: 0
    Device API: vfio-pci
    Name: GRID P4-1A
    Description: num_heads=1, frl_config=60, framebuffer=1024M, max_resolution=1280x1024, max_instance=8
  nvidia-68
    Available instances: 0
    Device API: vfio-pci
    Name: GRID P4-2A
    Description: num_heads=1, frl_config=60, framebuffer=2048M, max_resolution=1280x1024, max_instance=4
  nvidia-69
    Available instances: 0
    Device API: vfio-pci
    Name: GRID P4-4A
    Description: num_heads=1, frl_config=60, framebuffer=4096M, max_resolution=1280x1024, max_instance=2
  nvidia-70
    Available instances: 0
    Device API: vfio-pci
    Name: GRID P4-8A
    Description: num_heads=1, frl_config=60, framebuffer=8192M, max_resolution=1280x1024, max_instance=1
  nvidia-71
    Available instances: 0
    Device API: vfio-pci
    Name: GRID P4-1B
    Description: num_heads=4, frl_config=45, framebuffer=1024M, max_resolution=5120x2880, max_instance=8
root@herozmy-server:~# 
```
因为我只有2个虚拟机需求，所以我选择：nvidia-65

创建uuid:
```
uuidgen
#生成随机uuid：4d045383-c0da-45ae-b849-a5939e4bebb4
```
使用命令把uuid 写入到nvidia-65的配置中：
```
mdevctl start -u 4d045383-c0da-45ae-b849-a5939e4bebb4 -p 0000:01:00.0 -t nvidia-65
```
创建持久化：
#将profile持久化，只需要使用 
```
mdevctl define -a -u 4d045383-c0da-45ae-b849-a5939e4bebb4
#要删除vGPU设备也很简单，使用 mdevctl stop -u UUID 就可以，例如 
mdevctl stop -u 4d045383-c0da-45ae-b849-a5939e4bebb4
```


