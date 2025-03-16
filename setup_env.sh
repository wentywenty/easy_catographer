#!/bin/bash
# filepath: d:\github\easy_catographer\setup_ros_env.sh

# 显示彩色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 打印带颜色的信息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查ROS版本
check_ros_version() {
    print_info "检查ROS版本..."
    
    # 检查/opt/ros目录下是否存在noetic
    if [ -d "/opt/ros/noetic" ]; then
        print_success "检测到ROS Noetic安装"
        ROS_VERSION="noetic"
    else
        # 检查是否存在其他ROS版本
        ros_versions=$(ls /opt/ros 2>/dev/null)
        if [ -z "$ros_versions" ]; then
            print_error "未检测到ROS安装。请先安装ROS Noetic"
        else
            print_error "需要ROS Noetic, 但检测到其他版本: $ros_versions"
        fi
        exit 1
    fi
}

# 根据终端类型source ROS安装
source_ros_setup() {
    print_info "配置ROS环境变量..."
    
    # 检测终端类型
    shell_type=$(basename "$SHELL")
    
    case "$shell_type" in
        bash)
            if ! grep -q "source /opt/ros/noetic/setup.bash" ~/.bashrc; then
                echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
                print_info "已添加ROS环境变量到 .bashrc"
            fi
            source /opt/ros/noetic/setup.bash
            ;;
        zsh)
            if ! grep -q "source /opt/ros/noetic/setup.zsh" ~/.zshrc; then
                echo "source /opt/ros/noetic/setup.zsh" >> ~/.zshrc
                print_info "已添加ROS环境变量到 .zshrc"
            fi
            source /opt/ros/noetic/setup.zsh
            ;;
        *)
            print_warning "未识别的shell类型: $shell_type，手动source ROS环境"
            source /opt/ros/noetic/setup.bash
            ;;
    esac
    
    print_success "ROS环境变量已配置"
}

# 检查并安装rosdep或rosdepc
check_install_rosdep() {
    print_info "检查rosdep工具..."
    
    # 优先检查rosdepc (国内版)
    if command -v rosdepc &> /dev/null; then
        print_success "检测到rosdepc已安装"
        ROSDEP_CMD="rosdepc"
    # 检查rosdep
    elif command -v rosdep &> /dev/null; then
        print_success "检测到rosdep已安装"
        ROSDEP_CMD="rosdep"
    else
        print_info "未检测到rosdep/rosdepc，正在安装rosdepc..."
        
        # 安装rosdepc
        sudo apt-get update
        sudo apt-get install -y python3-pip
        sudo pip3 install rosdepc
        
        if command -v rosdepc &> /dev/null; then
            print_success "rosdepc安装成功"
            ROSDEP_CMD="rosdepc"
        else
            print_error "rosdepc安装失败，尝试安装标准rosdep..."
            sudo apt-get install -y python3-rosdep
            
            if command -v rosdep &> /dev/null; then
                print_success "rosdep安装成功"
                ROSDEP_CMD="rosdep"
            else
                print_error "rosdep安装失败，请手动安装后重试"
                exit 1
            fi
        fi
    fi
}

# 初始化和更新rosdep/rosdepc
init_update_rosdep() {
    print_info "初始化和更新${ROSDEP_CMD}..."
    
    # 检查是否需要初始化
    if [ ! -d "/etc/ros/rosdep" ]; then
        print_info "正在初始化${ROSDEP_CMD}..."
        if [ "$ROSDEP_CMD" = "rosdepc" ]; then
            sudo $ROSDEP_CMD init
        else
            sudo $ROSDEP_CMD init
        fi
    else
        print_info "/etc/ros/rosdep目录已存在，跳过初始化"
    fi
    
    # 更新
    print_info "正在更新${ROSDEP_CMD}数据库..."
    $ROSDEP_CMD update
    
    print_success "${ROSDEP_CMD}初始化和更新完成"
}

# 更新系统软件包
update_system() {
    print_info "正在更新系统软件包..."
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y python3-wstool python3-rosdep ninja-build stow
    print_success "系统软件包更新完成"
}

# 主函数
main() {
    print_info "开始检查并配置ROS环境..."
    
    # 检查是否以root权限运行
    if [ "$(id -u)" -eq 0 ]; then
        print_error "请不要以root权限运行此脚本"
        exit 1
    fi
    
    # 检查ROS版本
    check_ros_version
    
    # 配置ROS环境
    source_ros_setup
    
    # 检查并安装rosdep/rosdepc
    check_install_rosdep
    
    # 初始化和更新rosdep/rosdepc
    init_update_rosdep
    
    # 更新系统软件包
    update_system
    
    print_success "ROS环境检查和配置完成！"
}

# 执行主函数
main