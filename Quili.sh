#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 脚本保存路径
SCRIPT_PATH="$HOME/Quili.sh"
export HOME=/root


# 节点安装功能
function install_node() {


# 增加swap空间
sudo mkdir /swap
sudo fallocate -l 24G /swap/swapfile
sudo chmod 600 /swap/swapfile
sudo mkswap /swap/swapfile
sudo swapon /swap/swapfile
echo '/swap/swapfile swap swap defaults 0 0' >> /etc/fstab

# 向/etc/sysctl.conf文件追加内容
echo -e "\n# 自定义最大接收和发送缓冲区大小" >> /etc/sysctl.conf
echo "net.core.rmem_max=600000000" >> /etc/sysctl.conf
echo "net.core.wmem_max=600000000" >> /etc/sysctl.conf

echo "配置已添加到/etc/sysctl.conf"

# 重新加载sysctl配置以应用更改
sysctl -p

echo "sysctl配置已重新加载"

export DEBIAN_FRONTEND=noninteractive
export TERM=xterm

# 更新并升级Ubuntu软件包
sudo apt-get update && sudo apt-get -y upgrade 

# 安装wget、screen和git等组件
sudo apt-get install git ufw bison screen binutils gcc make bsdmainutils -y

# 安装GVM
curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer | sudo bash
source /root/.gvm/scripts/gvm

gvm install go1.4 -B
gvm use go1.4
export GOROOT_BOOTSTRAP=$GOROOT
gvm install go1.17.13
gvm use go1.17.13
export GOROOT_BOOTSTRAP=$GOROOT
gvm install go1.20.2
gvm use go1.20.2

# 克隆仓库
git clone https://github.com/quilibriumnetwork/ceremonyclient

# 进入ceremonyclient/node目录
cd ceremonyclient/node 

# 赋予执行权限
chmod +x poor_mans_cd.sh

# 创建一个screen会话并运行命令
screen -dmS Quili bash -c './poor_mans_cd.sh'

# 创建配置
sed -i 's|listenGrpcMultiaddr:.*|listenGrpcMultiaddr: "/ip4/127.0.0.1/tcp/8337"|' .config/config.yml
sed -i 's|listenRESTMultiaddr:.*|listenRESTMultiaddr: "/ip4/127.0.0.1/tcp/8338"|' .config/config.yml

# 开放端口
printf 'y\n' | sudo ufw enable
sudo ufw allow 22
sudo ufw allow 8336
sudo ufw allow 8337
sudo ufw allow 8338
sudo ufw allow 8317
sudo ufw allow 8316

}




install_node
