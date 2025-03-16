#!/bin/bash
# filepath: /home/ucar/fei/src/fei_bringup/tool/absl.sh

# 显示使用方法
show_usage() {
    echo "使用方法: $0 [install|uninstall]"
    echo "  install   - 安装abseil-cpp库"
    echo "  uninstall - 卸载abseil-cpp库"
}

# 检查是否设置了FEI_DIR环境变量
check_env() {
    if [ -z "$FEI_DIR" ]; then
        echo "错误: 未设置环境变量FEI_DIR"
        echo "请先运行source venv"
        exit 1
    fi
}

# 安装abseil-cpp
install_absl() {
    echo "开始安装abseil-cpp..."
    
    # 删除ROS自带的abseil-cpp包
    sudo apt-get remove -y ros-${ROS_DISTRO}-abseil-cpp
    
    # 创建并进入构建目录
    mkdir -p ${FEI_DIR}/build_isolated/abseil-cpp
    cd ${FEI_DIR}/build_isolated/abseil-cpp
    
    # 配置和构建
    echo "配置和构建abseil-cpp..."
    cmake -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DCMAKE_INSTALL_PREFIX=/usr/local/stow/absl \
        ${FEI_DIR}/src/fei_plugins/abseil-cpp
    
    # 安装
    echo "安装abseil-cpp..."
    sudo ninja install
    
    # 使用stow创建符号链接
    cd /usr/local/stow
    sudo stow absl
    
    echo "abseil-cpp安装完成"
}

# 卸载abseil-cpp
uninstall_absl() {
    echo "开始卸载abseil-cpp..."
    
    # 取消stow链接
    cd /usr/local/stow
    if [ -d "absl" ]; then
        sudo stow -D absl
    else
        echo "警告: stow目录中没有absl"
    fi
    
    # 返回原目录
    cd ${FEI_DIR}
    
    # 删除安装文件
    BUILD_DIR="${FEI_DIR}/build_isolated/abseil-cpp"
    MANIFEST="${BUILD_DIR}/install_manifest.txt"
    
    if [ -f "$MANIFEST" ]; then
        echo "根据安装清单删除文件..."
        sudo xargs rm < "$MANIFEST"
        sudo rm -rf /usr/local/stow/absl
        echo "卸载完成"
    else
        echo "警告: 找不到安装清单文件 ${MANIFEST}"
        echo "可能需要手动删除文件"
        
        # 尝试直接删除stow目录
        if [ -d "/usr/local/stow/absl" ]; then
            echo "删除/usr/local/stow/absl目录..."
            sudo rm -rf /usr/local/stow/absl
        fi
    fi
}

# 主逻辑
main() {
    # 检查参数
    if [ $# -ne 1 ]; then
        show_usage
        exit 1
    fi
    
    # 检查环境变量
    check_env
    
    # 根据参数执行操作
    case "$1" in
        install)
            install_absl
            ;;
        uninstall)
            uninstall_absl
            ;;
        *)
            echo "错误: 无效的参数: $1"
            show_usage
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"