# easy_catographer

## 简介

easy_catographer 是一个针对 Ubuntu 20.04 环境下的 Google Cartographer 安装管理工具，旨在简化 Cartographer SLAM 系统的安装、配置和管理过程，避免繁琐的手动操作和可能遇到的各种问题。

## 功能特点

- ✅ 自动检测并安装 ROS Noetic 环境
- ✅ 一键下载和配置 Cartographer 源码
- ✅ 自动处理 abseil-cpp 依赖
- ✅ 交互式菜单界面，操作简单直观
- ✅ 完整的编译、安装、卸载功能
- ✅ 详细的日志输出和错误处理

## 系统要求

- Ubuntu 20.04 LTS (Focal Fossa)
- ROS Noetic
- 至少 4GB 内存和 4GB 可用磁盘空间

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/yourusername/easy_catographer.git
cd easy_catographer
```

### 2. 设置执行权限

```bash
chmod +x *.sh
```

### 3. 运行主脚本

```bash
./catographer.sh
```

## 使用指南

主脚本提供了以下功能：

1. **检查环境依赖** - 自动检测并安装所需的所有环境依赖
2. **下载源码** - 下载 Cartographer 和相关库的源码
3. **编译** - 编译 Cartographer 项目
4. **安装** - 安装编译后的 Cartographer 并配置环境变量
5. **卸载** - 卸载 Cartographer
6. **完全卸载** - 卸载 Cartographer 及其依赖
7. **一键工作区编译安装** - 自动完成环境检查、下载、编译和安装
8. **清理工作区** - 清理编译生成的临时文件

## 脚本说明

- **catographer.sh** - 主界面脚本，提供所有功能的入口
- **setup_env.sh** - 环境检查和配置脚本，确保 ROS 环境正确设置
- **absl.sh** - abseil-cpp 库的安装和管理脚本
- **catographer.repos** - 包含 Cartographer 依赖仓库的配置文件

## 常见问题解答

### Q: 为什么需要特别处理 abseil-cpp 库？

A: Cartographer 依赖特定版本的 abseil-cpp 库，而 ROS 自带的版本可能不兼容。本工具会自动处理这些兼容性问题。

### Q: 编译过程卡住或失败怎么办？

A: 尝试增加系统资源（特别是内存），或者使用清理工作区功能后重新编译。也可以检查是否有错误日志输出。

### Q: 如何使用编译好的 Cartographer？

A: 安装完成后，请重新打开终端或执行 `source ~/.bashrc`（如果使用 bash）。然后您可以通过 ROS 启动文件使用 Cartographer。

## 疑难解答

如果在使用过程中遇到问题，请尝试以下步骤：

1. 确保系统和 ROS 环境是最新的
2. 使用完全卸载功能后重新安装
3. 检查 `/tmp` 目录是否有足够的空间
4. 查看详细的错误输出信息

## 贡献指南

欢迎提交问题报告、功能请求或代码贡献。请遵循以下步骤：

1. Fork 本仓库
2. 创建您的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request

## 许可证

本项目采用 MIT 许可证 - 详情请参见 LICENSE 文件。

## 致谢

- [Google Cartographer](https://github.com/cartographer-project/cartographer)
- [ROS (Robot Operating System)](https://www.ros.org/)
- 所有为此项目做出贡献的开发者
