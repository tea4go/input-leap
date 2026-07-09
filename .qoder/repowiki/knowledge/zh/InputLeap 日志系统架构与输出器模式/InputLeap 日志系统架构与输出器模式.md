---
kind: logging_system
name: InputLeap 日志系统架构与输出器模式
category: logging_system
scope:
    - '**'
---

## 1. 使用的系统与框架

InputLeap 使用自研的轻量级 C++ 日志子系统，基于单例 Log 类加可插拔 ILogOutputter 输出器链模式实现。该子系统位于 src/lib/base/ 目录，不依赖第三方日志库，通过宏接口提供线程安全的结构化日志能力。

## 2. 核心文件与包

- 核心 API：src/lib/base/Log.h / Log.cpp — 单例 Log 类、优先级过滤、输出器链管理
- 输出器接口：src/lib/base/ILogOutputter.h — 所有输出器的抽象基类
- 内置输出器：src/lib/base/log_outputters.h / .cpp — Console/File/System/Buffered/MessageBox 等实现
- GUI 集成：src/gui/src/LogWindow.h / .cpp — Qt 日志窗口，支持实时查看与清理
- Windows 托盘集成：src/client/MSWindowsClientTaskBarReceiver.cpp — 托盘菜单动态调整日志级别

## 3. 架构与设计决策

### 3.1 输出器链模式
CLOG->insert(new FileLogOutputter("app.log")) 追加到头部，消息依次经过每个 outputter，返回 false 则停止传播。默认安装 ConsoleLogOutputter，调试构建时默认过滤级别为 DEBUG，发布构建为 INFO。支持 alwaysAtHead 参数确保某些输出器始终优先执行。StopLogOutputter 用于短路后续输出器。

### 3.2 日志级别体系
FATAL(致命)、ERROR(错误)、WARNING(警告)、NOTE(通知)、INFO(信息)、DEBUG~DEBUG5(分级调试)、PRINT(不受过滤控制无前缀)。

### 3.3 线程安全与性能
全局 std::mutex 保护输出器列表与过滤器设置。消息格式化使用固定大小缓冲区（2048 字节），避免频繁分配。非 NDEBUG 构建自动附加文件名和行号。

### 3.4 多平台系统集成
SystemLogOutputter 通过 ARCH->writeLog() 桥接到平台系统日志。SystemLogger RAII 包装器可在作用域内临时重定向到系统日志并阻塞控制台输出。

## 4. 开发者规范

### 4.1 使用约定
统一通过 LOG_* 宏调用，禁止直接操作 Log 实例。在头文件中包含 base/Log.h，在源文件中使用 #include "base/Log.h"。严重错误使用 LOG_CRIT/LOG_ERR，用户可见问题用 LOG_WARN/LOG_NOTE，调试信息按粒度选择 LOG_DEBUG ~ LOG_DEBUG5。

### 4.2 输出器扩展指南
新输出器需继承 ILogOutputter 并实现 open/close/show/write。write() 返回 true 继续传播，false 终止链。严禁在 ILogOutputter 实现中递归调用日志 API。

### 4.3 GUI 应用集成
使用 BufferedLogOutputter 缓存最近 N 条日志供 LogWindow 实时显示。Windows 托盘菜单通过 IDC_TASKBAR_LOG_LEVEL_* 资源动态切换过滤级别。生产环境建议同时启用 FileLogOutputter 持久化日志。

### 4.4 构建期开关
定义 NOLOGGING 完全移除日志代码。定义 NDEBUG 关闭文件名/行号前缀以提升性能。