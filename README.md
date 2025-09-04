# 本地编译
- 环境准备  
  安装 Linux 系统（推荐 Ubuntu LTS），并安装编译依赖  
  ```bash
    sudo apt -y update  
    sudo apt -y full-upgrade  
    sudo apt install -y dos2unix libfuse-dev  
    sudo bash -c 'bash <(curl -sL https://build-scripts.immortalwrt.org/init_build_environment.sh)'
  ```

- 源码获取 
  ```bash
    git clone https://github.com/Niculuse/openwrt.git openwrt
    cd openwrt  
  ```
- 固件编译
  ```bash 
  ./build.sh jdcloud_ipq60xx_immwrt  
  ./build.sh jdcloud_ipq60xx_libwrt  
  ```
  
# GitHub Action在线编译
- fork本仓库
- 进入自己的项目主页，
- 点击[**Release WRT**](../../actions/workflows/release_wrt.yml)
- 点击右侧**Run workflow**
- 选择固件版本，点击下方的绿色按钮**Run workflow**，等待1-2h查看release页面获取固件

# 拨号IPv6指北
- 网络 --> 接口 --> lan口编辑 --> DHCP服务器 --> IPv6设置 --> RA服务（选择混合模式）--> IPVv6 RA设置 --> 勾选SLAAC --> 保存
- 保存并应用
- 检查下游设备是否能够获取IPv6公网地址

# 特别说明
- 三方插件源自 https://github.com/kenzok8/small-package.git  
  
- 使用OAF（应用过滤）功能前，需先完成以下操作：
  - 打开系统设置 → 启动项 → 定位到「appfilter」
  - 将「appfilter」当前状态**从已禁用更改为已启用**
  - 完成配置后，点击**启动**按钮激活服务  

- 固件说明：
  - factory为uboot直刷固件，sysupgrade为网页升级固件，任选其一即可 
  - 本项目fork于[ZqinKingd的仓库](https://github.com/ZqinKing/wrt_release)，并进行了进一步精简，默认移除了easytier、quickfile、mosdns、smartdns、lucky等插件
