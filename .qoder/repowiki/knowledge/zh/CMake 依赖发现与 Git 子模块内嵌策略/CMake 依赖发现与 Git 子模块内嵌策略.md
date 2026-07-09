---
kind: dependency_management
name: CMake 依赖发现与 Git 子模块内嵌策略
category: dependency_management
scope:
    - '**'
source_files:
    - CMakeLists.txt
    - src/CMakeLists.txt
    - src/lib/CMakeLists.txt
    - cmake/gtest.cmake
    - .gitmodules
    - .github/dependabot.yml
---

InputLeap 的依赖管理围绕 CMake 构建系统展开，采用“系统包 + 可选内嵌”混合模式：平台原生库通过 pkg-config / FindPackage 从宿主环境获取，测试框架与少量第三方头文件则通过 Git 子模块以源码形式内嵌到 ext/ 目录。

1. 系统级依赖（pkg-config / FindPackage）
- 顶层 CMakeLists.txt 在 UNIX 分支使用 FindPkgConfig 探测并链接 X11、ICE、libei、xkbcommon、glib、libportal 等；在 macOS 上直接 find_library 查找 IOKit、ApplicationServices、Carbon 等系统框架；Windows 下链接 Wtsapi32、Userenv、Wininet 等系统库。
- OpenSSL 通过 find_package(OpenSSL 1.1.1 REQUIRED COMPONENTS SSL Crypto) 声明最低版本 1.1.1，并在 Apple/Windows 上强制静态链接（OPENSSL_USE_STATIC_LIBS TRUE）。
- Qt 通过 find_package(Qt${QT_DEFAULT_MAJOR_VERSION} COMPONENTS Core REQUIRED) 动态选择 Qt5/Qt6，默认 QT_DEFAULT_MAJOR_VERSION=6，GUI 构建时额外定位 windeployqt/macdeployqt。
- 所有探测结果最终写入 src/lib/config.h.in → config.h，供源码按宏开关编译。

2. 内嵌依赖（Git 子模块）
- .gitmodules 定义两个子模块：ext/gtest（GoogleTest/GoogleMock）与 ext/gulrak-filesystem。
- GoogleTest 由 cmake/gtest.cmake 统一处理：当 INPUTLEAP_USE_EXTERNAL_GTEST=ON 时走外部安装路径（find_package(GTest) + pkg_check_modules(gmock)），否则直接使用 ext/gtest/googletest 源码并自建 gtest/gmock 静态目标。
- gulrak/filesystem 作为纯头文件库，仅在旧版 Qt（如 Qt5.15）或特定 CI 矩阵中通过 -DINPUTLEAP_BUILD_GULRAK_FILESYSTEM=1 启用，顶层 CMake 将其 include 目录加入 include_directories(SYSTEM ...)，源码侧用 #if INPUTLEAP_USE_GULRAK_FILESYSTEM 条件编译。

3. 版本锁定与更新
- 无 lockfile 或供应商目录；依赖版本由 CMake 脚本中的硬编码最小值（如 OpenSSL 1.1.1、libei >= 0.99.1、Qt5.9/Qt6.2）约束。
- GitHub Actions 工作流（.github/workflows/builds.yml）固定了各平台的编译器、Qt 版本及是否启用 gulrak/filesystem 的组合，形成可复现的构建矩阵。
- Dependabot 仅监控 GitHub Actions 自身依赖（package-ecosystem: github-actions），未配置对 CMake 依赖或子模块的自动升级。

4. 开发者约定
- 新增系统库：在顶层 CMakeLists.txt 对应平台分支添加 pkg_check_modules/find_package/find_library，并将结果追加到 libs 列表，同时为 config.h 生成相应宏。
- 新增第三方库：优先尝试系统包；若需内嵌，则通过 git submodule add 放入 ext/，在顶层 CMake 中提供 INPUTLEAP_BUILD_* 选项控制启用，并在源码中以宏隔离实现。
- 不要直接修改 ext/ 下的子模块内容；版本升级应通过更新 .gitmodules 指向的提交来实现。