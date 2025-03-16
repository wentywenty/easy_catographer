#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # 无颜色

# 全局变量
WORKSPACE_DIR=$(pwd)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 输出函数
print_header() {
    echo -e "\n${BLUE}===========================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===========================================================${NC}"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo
}

# 清屏函数
clear_screen() {
    clear
}

# 显示主菜单
show_main_menu() {
    clear_screen
    echo -e "${PURPLE}============================================${NC}"
    echo -e "${PURPLE}          Cartographer 管理工具            ${NC}"
    echo -e "${PURPLE}============================================${NC}"
    echo -e "${CYAN}1.${NC} 检查环境依赖"
    echo -e "${CYAN}2.${NC} 下载源码"
    echo -e "${CYAN}3.${NC} 编译"
    echo -e "${CYAN}4.${NC} 安装"
    echo -e "${CYAN}5.${NC} 卸载"
    echo -e "${CYAN}6.${NC} 完全卸载（包括依赖）"
    echo -e "${CYAN}7.${NC} 一键工作区编译安装"
    echo -e "${CYAN}8.${NC} 清理工作区"
    echo -e "${CYAN}0.${NC} 退出"
    echo
    echo -e "${YELLOW}请选择操作[0-8]:${NC} "
    read -r choice
    
    case $choice in
        1) check_environment ;;
        2) download_source ;;
        3) compile_cartographer ;;
        4) install_cartographer ;;
        5) uninstall_cartographer ;;
        6) complete_uninstall ;;
        7) workspace_compile_install ;;
        8) clean_workspace ;;
        0) exit 0 ;;
        *) 
            print_error "无效的选择"
            sleep 1
            show_main_menu
            ;;
    esac
}

# 检查环境函数
check_environment() {
    print_header "环境检查"

    # 调用setup_env.sh脚本进行环境检查
    if [ -f "${SCRIPT_DIR}/setup_env.sh" ]; then
        print_info "正在执行环境检查脚本..."
        bash "${SCRIPT_DIR}/setup_env.sh"
        if [ $? -ne 0 ]; then
            print_error "环境检查失败，请查看错误信息"
            press_enter_to_continue
            return 1
        fi
    else
        print_error "未找到setup_env.sh脚本"
        press_enter_to_continue
        return 1
    fi
    print_success "环境检查完成，所有依赖已安装"
    press_enter_to_continue
}

# 下载源码
download_source() {
    print_header "下载Cartographer源码"
    
    if [ ! -f "${SCRIPT_DIR}/catographer.repos" ]; then
        print_error "未找到catographer.repos文件"
        press_enter_to_continue
        return 1
    fi
    
    print_info "使用vcs导入依赖项..."
    if ! vcs import < "${SCRIPT_DIR}/catographer.repos"; then
        print_error "导入失败"
        press_enter_to_continue
        return 1
    fi
    
    print_info "检出特定版本的abseil-cpp..."
    if [ -d "abseil-cpp" ]; then
        (cd abseil-cpp && git checkout 215105818dfde3174fe799600bb0f3cae233d0bf)
    else
        print_error "未找到abseil-cpp目录"
        press_enter_to_continue
        return 1
    fi
    
    print_success "源码下载完成"
    press_enter_to_continue
}

# 编译Cartographer
compile_cartographer() {
    print_header "编译Cartographer"
    
    if [ ! -d "cartographer" ] || [ ! -d "cartographer_ros" ]; then
        print_error "缺少必要的源码目录，请先下载源码"
        press_enter_to_continue
        return 1
    fi
    
    # 安装abseil-cpp
    print_info "安装abseil-cpp..."
    if [ -f "${SCRIPT_DIR}/absl.sh" ]; then
        # 设置FEI_DIR环境变量（absl.sh需要此环境变量）
        export FEI_DIR=${WORKSPACE_DIR}
        bash "${SCRIPT_DIR}/absl.sh" install
        if [ $? -ne 0 ]; then
            print_error "abseil-cpp安装失败"
            press_enter_to_continue
            return 1
        fi
    else
        print_error "未找到absl.sh脚本"
        press_enter_to_continue
        return 1
    fi
    
    # 编译
    print_info "开始编译Cartographer..."
    if ! catkin_make_isolated --install --use-ninja; then
        print_error "编译失败"
        press_enter_to_continue
        return 1
    fi
    
    print_success "Cartographer编译完成"
    press_enter_to_continue
}

# 安装Cartographer
install_cartographer() {
    print_header "安装Cartographer"
    
    if [ ! -d "install_isolated" ]; then
        print_error "未找到编译后的安装目录，请先编译"
        press_enter_to_continue
        return 1
    fi
    
    # 检测终端类型
    shell_type=$(basename "$SHELL")
    setup_file=""
    rc_file=""
    
    case "$shell_type" in
        bash)
            setup_file="${WORKSPACE_DIR}/install_isolated/setup.bash"
            rc_file=~/.bashrc
            ;;
        zsh)
            setup_file="${WORKSPACE_DIR}/install_isolated/setup.zsh"
            rc_file=~/.zshrc
            ;;
        *)
            setup_file="${WORKSPACE_DIR}/install_isolated/setup.sh"
            rc_file=~/.bashrc
            print_warning "未识别的shell类型: $shell_type，使用默认setup.sh"
            ;;
    esac
    
    # 添加到.bashrc或.zshrc
    print_info "添加Cartographer环境变量到$rc_file..."
    
    if ! grep -q "$setup_file" "$rc_file"; then
        echo "source $setup_file" >> "$rc_file"
        print_success "环境变量已添加"
    else
        print_info "环境变量已存在，无需添加"
    fi
    
    print_info "正在source环境变量..."
    source "$setup_file"
    
    print_success "Cartographer安装完成"
    print_info "请重新打开终端或执行 source $rc_file 使环境变量生效"
    press_enter_to_continue
}

# 卸载Cartographer
uninstall_cartographer() {
    print_header "卸载Cartographer"
    
    # 从.bashrc或.zshrc移除配置
    shell_type=$(basename "$SHELL")
    setup_file=""
    rc_file=""
    
    case "$shell_type" in
        bash)
            setup_file="${WORKSPACE_DIR}/install_isolated/setup.bash"
            rc_file=~/.bashrc
            ;;
        zsh)
            setup_file="${WORKSPACE_DIR}/install_isolated/setup.zsh"
            rc_file=~/.zshrc
            ;;
        *)
            setup_file="${WORKSPACE_DIR}/install_isolated/setup.sh"
            rc_file=~/.bashrc
            ;;
    esac
    
    print_info "从$rc_file移除Cartographer环境变量..."
    if grep -q "$setup_file" "$rc_file"; then
        sed -i "\#source $setup_file#d" "$rc_file"
        print_success "环境变量已移除"
    else
        print_info "环境变量不存在，无需移除"
    fi
    
    # 移除安装目录
    if [ -d "install_isolated" ]; then
        print_info "删除安装目录..."
        rm -rf install_isolated
        print_success "安装目录已删除"
    else
        print_info "安装目录不存在，无需删除"
    fi
    
    print_success "Cartographer卸载完成"
    press_enter_to_continue
}

# 完全卸载
complete_uninstall() {
    print_header "完全卸载Cartographer（包括依赖）"
    
    # 卸载Cartographer
    uninstall_cartographer
    
    # 卸载abseil-cpp
    print_info "卸载abseil-cpp..."
    if [ -f "${SCRIPT_DIR}/absl.sh" ]; then
        # 设置FEI_DIR环境变量（absl.sh需要此环境变量）
        export FEI_DIR=${WORKSPACE_DIR}
        bash "${SCRIPT_DIR}/absl.sh" uninstall
        if [ $? -ne 0 ]; then
            print_warning "abseil-cpp卸载可能未完全成功"
        else
            print_success "abseil-cpp卸载成功"
        fi
    else
        print_error "未找到absl.sh脚本"
    fi
    
    # 询问是否删除源码
    echo
    read -p "是否删除源码目录? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "删除源码目录..."
        if [ -d "cartographer" ]; then rm -rf cartographer; fi
        if [ -d "cartographer_ros" ]; then rm -rf cartographer_ros; fi
        if [ -d "abseil-cpp" ]; then rm -rf abseil-cpp; fi
        print_success "源码目录已删除"
    fi
    
    print_success "Cartographer完全卸载完成"
    press_enter_to_continue
}

# 工作区内编译安装
workspace_compile_install() {
    print_header "工作区编译安装"
    
    # 检查环境
    check_environment
    
    # 下载源码
    download_source
    
    # 编译
    compile_cartographer
    
    # 安装
    install_cartographer
    
    print_success "工作区编译安装完成"
    press_enter_to_continue
}

# 清理工作区
clean_workspace() {
    print_header "清理工作区"
    
    # 询问是否删除build和devel目录
    read -p "是否删除build_isolated和devel_isolated目录? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "删除编译和开发目录..."
        if [ -d "build_isolated" ]; then rm -rf build_isolated; fi
        if [ -d "devel_isolated" ]; then rm -rf devel_isolated; fi
        print_success "编译和开发目录已删除"
    fi
    
    print_success "工作区清理完成"
    press_enter_to_continue
}

# 按Enter继续
press_enter_to_continue() {
    echo
    read -p "按Enter键继续..."
    show_main_menu
}

# 主程序
main() {
    # 检查是否以root权限运行
    if [ "$(id -u)" -eq 0 ]; then
        echo -e "${RED}错误: 请不要以root权限运行此脚本${NC}"
        exit 1
    fi
    
    show_main_menu
}

# 执行主程序
main