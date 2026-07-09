---
kind: build_system
name: CMake 多平台构建与打包系统
category: build_system
scope:
    - '**'
source_files:
    - CMakeLists.txt
    - cmake/Version.cmake
    - cmake/Package.cmake
    - clean_build.sh
    - clean_build.ps1
    - src/CMakeLists.txt
    - src/lib/CMakeLists.txt
    - src/gui/CMakeLists.txt
    - src/client/CMakeLists.txt
    - src/server/CMakeLists.txt
    - src/daemon/CMakeLists.txt
    - src/test/CMakeLists.txt
---

InputLeap 采用 CMake 作为统一的跨平台构建系统，顶层 `CMakeLists.txt` 负责依赖探测、编译器特性检测、平台分支配置以及递归引入 `src/` 子模块。核心构建逻辑集中在根级 CMake 脚本与 `cmake/` 辅助模块中，并通过 shell/PowerShell 包装脚本提供一键构建入口。

## 1. 使用的系统与工具链
- **构建系统**: CMake ≥ 3.21，默认启用 Ninja（若可用）以加速并行构建。
- **语言标准**: Qt6 → C++17；Qt5 → C++14，由 `QT_DEFAULT_MAJOR_VERSION` 自动切换。
- **GUI 框架**: Qt Core/Widgets/Network/LinguistTools，支持 Qt5 (≥5.9) 与 Qt6 (≥6.2)。
- **加密库**: OpenSSL ≥ 1.1.1，在 macOS/Windows 上优先静态链接。
- **Unix 依赖探测**: pkg-config + `CheckIncludeFiles`/`CheckLibraryExists`/`CheckFunctionExists` 等 CMake 内置模块。
- **测试框架**: GoogleTest（可外部安装或内嵌 `ext/gtest`）。
- **打包**: CPack（UNIX 下生成 TBZ2/TXZ 源码包）、Inno Setup / WiX（Windows 安装包）、macOS Bundle + `build_dist.sh`。
- **发行说明**: towncrier（`towncrier.toml` + `doc/newsfragments/`）。

## 2. 关键文件与位置
- `CMakeLists.txt` — 顶层工程定义、选项开关、平台分支、依赖查找、install/uninstall 目标。
- `cmake/Version.cmake` — 版本三元组 (`INPUTLEAP_VERSION_MAJOR/MINOR/PATCH`) 与 git 描述符拼接为完整版本号，并注入编译期宏。
- `cmake/Package.cmake` — UNIX 下 CPack 基本配置（TBZ2/TXZ 源包）。
- `clean_build.sh` / `clean_build.ps1` — 开发者一键构建脚本：初始化子模块、清理 build 目录、选择 Ninja、设置 macOS SDK 路径、调用 CMake 配置与构建。
- `src/CMakeLists.txt` 及各子目录 `CMakeLists.txt` — 按 `lib/`、`client/`、`server/`、`daemon/`、`gui/`、`test/` 组织目标。
- `res/io.github.input_leap.input-leap.desktop` / `.appdata.xml` — Linux 桌面集成元数据。
- `dist/rpm/`、`dist/wix/`、`dist/inno/`、`dist/macos/bundle/` — 各平台安装包模板。

## 3. 架构与约定
- **模块化分层**: `src/lib/` 按功能域拆分为 `base/`、`common/`、`inputleap/`、`io/`、`ipc/`、`mt/`、`net/`、`platform/`、`server/`、`client/`、`arch/`，每个子目录独立 `CMakeLists.txt` 暴露为库目标，供上层应用链接。
- **平台抽象**: 通过 `SYSAPI_UNIX`/`SYSAPI_WIN32` 及 `WINAPI_XWINDOWS`/`WINAPI_LIBEI`/`WINAPI_MSWINDOWS`/`BUILD_CARBON` 等宏在编译期切换平台后端；非 Apple Unix 下 X11 与 libei 二选一（至少开启其一）。
- **可选特性开关**: `INPUTLEAP_BUILD_GUI`、`INPUTLEAP_BUILD_TESTS`、`INPUTLEAP_BUILD_X11`、`INPUTLEAP_BUILD_LIBEI`、`INPUTLEAP_BUILD_GULRAK_FILESYSTEM`、`INPUTLEAP_USE_EXTERNAL_GTEST` 等 CMake 选项控制功能裁剪。
- **资源复制宏**: `configure_files()` 递归拷贝 `*.in` 模板并按 `@VAR@` 替换后输出到构建目录，用于生成 bundle、RPM/WiX/Inno 模板。
- **版本注入**: `cmake/Version.cmake` 从 git log 提取 `git-%cs-%h` 作为 `-DESC` 后缀，同时写入 `INPUTLEAP_BUILD_DATE`/`_TIME` 等宏供运行时显示。
- **安装规则**: 非 Windows 下安装 man 页、desktop/appdata、SVG 图标；macOS 下通过自定义 target 调用 `build_dist.sh` 组装 `.app`；Windows 下生成 Inno/WiX 安装包。

## 4. 开发者应遵循的规则
- 新增平台/特性时，在顶层 `CMakeLists.txt` 的对应 `if(UNIX|APPLE|WIN32)` 分支中添加 `pkg_check_modules`/`find_package` 与编译宏，并在 `src/lib/platform/` 下实现条件编译代码。
- 所有可选功能必须通过 CMake 选项暴露，避免硬编码 `#ifdef`，以便用户按需裁剪。
- 修改版本号仅更新 `cmake/Version.cmake` 中的三元组，不要手动拼版本号字符串。
- 新增 GUI 翻译文件需在 `src/gui/res/lang/` 下添加 `gui_*.ts`，并确保 `src/gui/CMakeLists.txt` 已注册。
- 使用 `clean_build.sh` / `clean_build.ps1` 作为本地构建入口，它们会自动处理子模块、Ninja 选择与 macOS SDK 路径；如需自定义环境变量，可在仓库根创建 `build_env.sh`。
- 发布前在 `doc/newsfragments/` 添加 towncrier 碎片，运行 `towncrier` 生成变更日志。
- 仅在 UNIX 下使用 CPack 生成源码包；二进制分发由各平台专属流程（Inno/WiX/macOS bundle）完成。

**置信度: high** — 仓库存在完整的 CMake 顶层工程、明确的版本/打包模块、跨平台构建脚本与多目标分层结构，证据充分且模式一致。