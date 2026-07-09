---
kind: configuration_system
name: InputLeap 配置系统：分层加载与双格式支持
category: configuration_system
scope:
    - '**'
source_files:
    - src/lib/server/Config.h
    - src/lib/server/Config.cpp
    - src/lib/inputleap/ServerApp.cpp
    - src/lib/inputleap/ServerApp.h
    - src/gui/src/AppConfig.h
    - src/gui/src/BaseConfig.h
    - src/gui/src/ServerConfig.h
    - doc/input-leap.conf.example
---

## 1. 系统概览

InputLeap 采用**双层配置体系**：
- **服务器运行时配置**（`input-leap.conf`）：声明式文本文件，描述屏幕拓扑、链接、别名、全局选项与输入过滤规则。由 `src/lib/server/Config.h/.cpp` 中的 `Config` 类解析。
- **GUI 应用配置**（Qt `QSettings`）：存储界面偏好、上次打开的文件路径等，由 `src/gui/src/AppConfig.h` 管理。

配置文件加载入口在 `ServerApp::loadConfig()`（`src/lib/inputleap/ServerApp.cpp`），遵循“显式参数 > 用户目录 > 系统目录”的优先级链。

## 2. 核心文件与职责

| 文件 | 职责 |
|---|---|
| `src/lib/server/Config.h` / `.cpp` | 服务器配置模型与自定义段式解析器（`section: options/screens/links/aliases`） |
| `src/lib/inputleap/ServerApp.cpp` | 配置文件发现、加载、重载信号处理 |
| `src/lib/inputleap/ArgParser.cpp` | 命令行参数 `-c/--config` 解析 |
| `src/gui/src/AppConfig.h` / `.cpp` | GUI 持久化设置（`QSettings`） |
| `src/gui/src/BaseConfig.h` / `.cpp` | GUI 侧配置基类，提供键值读写封装 |
| `src/gui/src/ServerConfig.h` / `.cpp` | GUI 中与服务端配置对应的对象模型 |
| `doc/input-leap.conf.example*` | 官方示例配置文件（basic/barebones/advanced） |

## 3. 架构与约定

### 3.1 配置文件位置与查找顺序
```
--config <path>          ← 最高优先级
~/.input-leap/input-leap.conf   ← 用户 profile 目录（CONFIG_NAME）
~/.input-leap.conf              ← 兼容旧版本（deprecated）
/etc/input-leap/input-leap.conf ← 系统级配置（DataDirectories::systemconfig）
```
未找到任何文件时，服务端以退出码 `kExitConfig` 终止。

### 3.2 文件格式（`input-leap.conf`）
基于自定义段式语法，关键字段：
- `section: options` — 全局选项（`address`, `heartbeat`, `switchCorners`, `clipboardSharing` 等）及输入过滤规则（条件 + 动作，支持激活/停用两阶段）。
- `section: screens` — 定义屏幕名称列表。
- `section: links` — 定义屏幕间边缘连接（left/right/up/down，支持区间映射）。
- `section: aliases` — 为屏幕名添加别名。

解析器位于 `Config::readSection*`，通过 `ConfigReadContext` 逐行解析并抛出 `XConfigRead` 异常。

### 3.3 运行时重载
服务端监听 SIGHUP（或平台等效信号），触发 `reloadSignalHandler` → `reload_config()`，重新调用 `loadConfig(args().m_configFile)` 并热更新到已运行的 Server。

### 3.4 GUI 配置层
- `BaseConfig` 提供统一的键值存取接口。
- `AppConfig` 封装 `QSettings`，保存窗口大小、语言、最近文件等 UI 状态。
- `ServerConfig` 将 GUI 编辑结果序列化为 `operator<<` 输出，供 `MainWindow` 写入临时 `input-leap.conf` 后启动子进程。

## 4. 开发者应遵循的规则

1. **新增全局选项**：在 `Config::readSectionOptions` 中添加分支，并在 `option_types.h` 注册 `OptionID`。
2. **新增配置段**：在 `readSection` 中增加分支，实现 `readSectionXXX` 方法，保持错误信息使用 `XConfigRead(s, "...")` 风格。
3. **配置文件路径**：不要硬编码路径，使用 `DataDirectories::profile()` / `systemconfig()`；如需新文件名，同步更新 `ServerApp::help()` 的输出。
4. **向后兼容**：对废弃路径（如 `.input-leap.conf`）保留读取逻辑并输出警告日志。
5. **GUI 与 CLI 一致性**：GUI 中 `ServerConfig` 序列化输出必须能被 `Config` 解析器正确消费，建议通过示例文件回归验证。
6. **重载安全**：`reload_config()` 仅替换配置对象引用，不重启服务；确保所有组件能无锁切换配置。

## 5. 关键常量与类型

- `CONFIG_NAME`：`"input-leap.conf"`（Windows 下宏条件编译为 `"input-leap.sgc"`，见 `ServerApp.h`）。
- `XConfigRead`：配置解析异常基类，携带行号与格式化错误消息。
- `ConfigReadContext`：流式解析上下文，提供 `parseBoolean/parseInt/parseModifierKey/parseKeystroke` 等强类型解析器。
