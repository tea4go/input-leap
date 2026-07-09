---
kind: error_handling
name: 错误处理：C++ 异常与 Qt 日志体系
category: error_handling
scope:
    - '**'
source_files:
    - src/lib/base/Exception.h
    - src/lib/base/Exception.cpp
    - src/client/input-leapc.cpp
    - src/server/input-leaps.cpp
    - src/gui/src/main.cpp
    - src/gui/src/LogWindow.cpp
---

InputLeap 是一个多平台 C++/Qt 工程，未采用 Go/Rust 风格的显式错误码或 sentinel error 模式，而是遵循 C++ 社区常见实践：**以异常（std::exception 及其派生类）作为主要错误传播机制**，并在 GUI 层通过 Qt 的日志系统统一输出。核心特征如下：

1. **异常类型与抛出点**
   - 自定义异常集中在 `src/lib/base/Exception.h`、`src/lib/base/Exception.cpp` 中定义，提供带上下文消息的基类，供各子系统抛出自描述异常。
   - 网络层（`src/lib/net/`）、IPC 层（`src/lib/ipc/`）、平台抽象层（`src/lib/platform/`）在 I/O 失败、握手失败、权限不足等场景均 throw 具体异常子类，而非返回错误码。

2. **顶层捕获与用户可见错误**
   - 进程入口（`src/client/input-leapc.cpp`、`src/server/input-leaps.cpp`、`src/gui/src/main.cpp`）在 main 函数最外层 try/catch `std::exception`，将异常转换为可打印的错误信息并通过 Qt 日志输出，避免崩溃。
   - GUI 对话框中的异步操作（如证书生成、网络请求）使用信号槽 + 错误回调，将底层异常封装为 Qt 事件再在 UI 线程弹出提示。

3. **日志与诊断**
   - 所有错误路径最终汇聚到 Qt 日志框架（`qDebug()` / `qWarning()` / `qCritical()`），由 `src/gui/src/LogWindow.cpp` 提供实时日志窗口，便于调试。
   - 服务端/客户端守护进程通过命令行参数控制日志级别，支持写入文件。

4. **测试中的断言风格**
   - 单元测试使用 GoogleTest（`ext/gtest`），以 `EXPECT_THROW` / `ASSERT_THROW` 验证异常行为；集成测试则直接调用 API 并检查返回值，不依赖异常。

5. **约定与建议**
   - 公共库接口优先抛出自定义异常，上层业务逻辑负责 catch 并转换为用户可读消息。
   - 禁止裸 `throw std::runtime_error("...")`，应使用 `base::Exception` 派生类以便区分来源。
   - 跨进程边界（IPC、网络）的异常需序列化为结构化错误码，接收端反序列化为本地异常。
   - 资源清理使用 RAII，不在析构函数中抛异常；若必须记录错误，仅写入日志而不向上冒泡。