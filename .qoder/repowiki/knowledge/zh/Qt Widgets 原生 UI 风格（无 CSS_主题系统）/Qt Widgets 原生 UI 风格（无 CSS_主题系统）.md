---
kind: frontend_style
name: Qt Widgets 原生 UI 风格（无 CSS/主题系统）
category: frontend_style
scope:
    - '**'
source_files:
    - src/gui/CMakeLists.txt
    - src/gui/res/InputLeap.qrc
    - src/gui/src/MainWindow.cpp
    - src/gui/src/AboutDialog.cpp
    - src/gui/src/main.cpp
---

InputLeap 的前端界面完全基于 Qt Widgets 构建，采用纯 C++ + Qt Designer (.ui) 的声明式布局方式，**不存在任何 CSS、SCSS、Tailwind 或样式表机制**。整个 GUI 子系统位于 `src/gui/` 下，遵循以下约定：

1. **UI 定义与代码分离**：每个对话框/窗口对应一个 `.ui` 文件（如 `MainWindow.ui`、`AboutDialog.ui`、`SettingsDialog.ui` 等），由 `CMAKE_AUTOUIC ON` 自动生成 `ui_*.h`，C++ 侧通过 `ui_->setupUi(this)` 加载并访问控件。
2. **资源管理**：图标、图片、多语言 `.qm` 打包进 `res/InputLeap.qrc`，运行时通过 `:/res/...` 路径引用；平台差异图标在 `MainWindow.cpp` 中按 `Q_OS_MAC` / 其他平台分支选择不同 PNG。
3. **样式策略**：未使用 `setStyleSheet()`、`QPalette` 或自定义 `QStyle`，所有视觉外观依赖操作系统原生 Qt 主题；仅对个别控件做最小化程序化调整（如 `QPixmap::scaledToHeight`、`setAttribute(Qt::WA_X11NetWmWindowTypeDialog, true)`）。
4. **国际化**：通过 Qt Linguist 的 `.ts` 源文件（40+ 语言）配合 `qt_add_translation` 生成 `.qm`，并在 `.qrc` 中注册。
5. **构建集成**：`src/gui/CMakeLists.txt` 启用 `AUTOMOC/AUTORCC/AUTOUIC`，将 `.ui`、`.qrc`、`.ts` 纳入统一编译管线。

由于项目未引入任何前端样式框架或主题引擎，本仓库**不适用**通用的“CSS 方法论 / 设计令牌 / 响应式策略”等前端风格概念。若需统一视觉风格，应集中在 Qt 主题层（全局 `QPalette` 或应用级 `QStyle`）进行改造。