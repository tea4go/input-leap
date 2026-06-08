# HarmonyOS NEXT 输入注入权限验证 PoC 工程骨架说明

## 1. 文档目的

本文档用于补充 `harmonyos-next-input-injection-poc-requirements.md`，提供一个可直接照着搭建的最小工程骨架。

目标是让另一台机器上的开发者不需要自己设计目录结构和职责划分，就能直接开始编码与真机调试。

## 2. 工程目标

本工程只服务于输入能力验证，不服务于产品化。

必须同时覆盖两条验证路径：

- **路径 A：系统级输入注入 API 验证**
- **路径 B：无障碍服务替代路径验证**

工程目标是：

1. 在 HarmonyOS NEXT 真机上安装运行
2. 通过最小页面触发路径 A 与路径 B 的测试动作
3. 输出可审计的日志
4. 导出验证结论所需证据

## 3. 建议工程名与包名

- **工程名：** `inputleap-harmony-poc`
- **包名：** `com.inputleap.poc`

## 4. 建议目录结构

建议采用如下结构：

```text
inputleap-harmony-poc/
├─ AppScope/
│  └─ app.json5
├─ entry/
│  ├─ src/main/
│  │  ├─ cpp/
│  │  │  ├─ CMakeLists.txt
│  │  │  ├─ napi_init.cpp
│  │  │  ├─ inject_test.h
│  │  │  ├─ inject_test.cpp
│  │  │  ├─ inject_types.h
│  │  │  ├─ inject_logger.h
│  │  │  ├─ inject_logger.cpp
│  │  │  ├─ accessibility_bridge.h
│  │  │  └─ accessibility_bridge.cpp
│  │  ├─ ets/
│  │  │  ├─ entryability/
│  │  │  │  └─ EntryAbility.ets
│  │  │  ├─ pages/
│  │  │  │  └─ Index.ets
│  │  │  ├─ model/
│  │  │  │  ├─ NativeApi.ets
│  │  │  │  ├─ TestActions.ets
│  │  │  │  ├─ ResultTypes.ets
│  │  │  │  └─ LogStore.ets
│  │  │  ├─ accessibility/
│  │  │  │  └─ InputLeapAccessibilityExtAbility.ets
│  │  │  └─ util/
│  │  │     ├─ PermissionUtil.ets
│  │  │     └─ ExportUtil.ets
│  │  ├─ module.json5
│  │  └─ resources/
│  │     ├─ base/element/string.json
│  │     └─ base/media/
│  ├─ oh-package.json5
│  └─ build-profile.json5
├─ hvigorfile.ts
├─ oh-package.json5
└─ README.md
```

## 5. 模块职责说明

## 5.1 ArkTS 层

### `EntryAbility.ets`

职责：

- 应用入口
- 初始化页面路由
- 启动时打印设备与版本信息

不负责：

- 测试逻辑
- 输入注入逻辑

### `Index.ets`

职责：

- 提供测试按钮
- 展示实时日志摘要
- 展示最近一次测试结果
- 触发导出日志

页面上建议最少包含以下按钮：

- 检查路径 A 能力
- 路径 A：发送按键 A
- 路径 A：发送方向键 Left
- 路径 A：发送单击
- 路径 A：发送双击
- 路径 A：发送移动
- 检查路径 B 状态
- 路径 B：查找并点击目标按钮
- 路径 B：向输入框写入文本
- 路径 B：滚动列表
- 导出日志

### `NativeApi.ets`

职责：

- 封装 ArkTS 到 Native 的调用
- 对外暴露统一接口
- 统一处理异常与返回值

建议接口：

```ts
export interface NativeApi {
  checkInjectionCapability(): Promise<string>
  injectKey(keyCode: number, action: number): Promise<number>
  injectClick(x: number, y: number): Promise<number>
  injectDoubleClick(x: number, y: number): Promise<number>
  injectMove(x: number, y: number): Promise<number>
  dumpNativeLog(): Promise<string>
}
```

### `TestActions.ets`

职责：

- 组合页面按钮的行为
- 记录测试前后的状态
- 将每次测试结果写入 `LogStore`

### `ResultTypes.ets`

职责：

- 定义统一结果类型

建议定义：

```ts
export interface TestResult {
  success: boolean
  code: number
  action: string
  message: string
  observation: string
  timestamp: string
}

export interface CapabilityMatrixRow {
  capability: string
  callable: string
  effective: string
  crossApp: string
  needSystemPrivilege: string
  notes: string
}
```

### `LogStore.ets`

职责：

- 缓存当前运行日志
- 提供导出文本
- 提供页面展示的最近日志

### `InputLeapAccessibilityExtAbility.ets`

职责：

- 实现路径 B 的无障碍验证
- 尝试获取节点树
- 尝试查找目标控件
- 尝试执行点击、输入、滚动动作
- 返回执行结果给 UI 层

不负责：

- 系统级注入逻辑
- Native 注入逻辑

### `PermissionUtil.ets`

职责：

- 检查应用权限
- 引导用户开启无障碍服务
- 引导用户进入必要系统设置

### `ExportUtil.ets`

职责：

- 导出日志文件
- 导出结果文件
- 生成可粘贴到 `RESULT.md` 的摘要

## 5.2 Native C++ 层

### `napi_init.cpp`

职责：

- 注册 NAPI 导出函数
- 绑定 ArkTS 与 C++ 层

建议至少导出以下函数：

```cpp
checkInjectionCapability
injectKey
injectClick
injectDoubleClick
injectMove
dumpNativeLog
```

### `inject_test.h` / `inject_test.cpp`

职责：

- 路径 A 的核心测试实现
- 统一封装所有系统级输入注入尝试
- 返回结构化错误码与诊断信息

建议提供以下接口：

```cpp
std::string checkInjectionCapability();
int injectKey(int keyCode, int action);
int injectClick(int x, int y);
int injectDoubleClick(int x, int y);
int injectMove(int x, int y);
```

### `inject_types.h`

职责：

- 定义 Native 层公共类型

建议内容：

```cpp
enum InjectActionResult {
    INJECT_OK = 0,
    INJECT_NOT_SUPPORTED = 1,
    INJECT_PERMISSION_DENIED = 2,
    INJECT_CALL_FAILED = 3,
    INJECT_NO_EFFECT = 4,
    INJECT_UNKNOWN = 99,
};
```

### `inject_logger.h` / `inject_logger.cpp`

职责：

- 统一 Native 层日志输出
- 缓存日志，供 ArkTS 导出

### `accessibility_bridge.h` / `accessibility_bridge.cpp`

职责：

- 如果需要，可作为路径 B 的 Native 预留桥接
- 当前阶段可以留空或只保留占位

## 6. 页面建议布局

建议首页布局采用单页垂直结构：

```text
[设备与系统信息]
[权限状态]
[路径 A：系统级输入注入]
  - 检查能力
  - 发送按键 A
  - 发送方向键 Left
  - 发送单击
  - 发送双击
  - 发送移动
[路径 B：无障碍替代]
  - 检查服务状态
  - 节点点击
  - 文本输入
  - 列表滚动
[最近一次结果]
[日志输出区]
[导出日志]
```

不要做复杂 UI。

只要满足：

- 一眼能知道当前在哪条路径测试
- 一眼能看到成功还是失败
- 能快速导出证据

## 7. 最小代码骨架示例

## 7.1 `NativeApi.ets`

```ts
import hilog from '@ohos.hilog'

const nativeModule = globalThis.requireNapi('inputleap_poc')

export class NativeApiImpl {
  async checkInjectionCapability(): Promise<string> {
    try {
      return nativeModule.checkInjectionCapability()
    } catch (err) {
      hilog.error(0x0000, 'InputLeapPoC', `checkInjectionCapability failed: ${JSON.stringify(err)}`)
      return 'ERROR'
    }
  }

  async injectKey(keyCode: number, action: number): Promise<number> {
    try {
      return nativeModule.injectKey(keyCode, action)
    } catch (_) {
      return -1
    }
  }

  async injectClick(x: number, y: number): Promise<number> {
    try {
      return nativeModule.injectClick(x, y)
    } catch (_) {
      return -1
    }
  }

  async injectDoubleClick(x: number, y: number): Promise<number> {
    try {
      return nativeModule.injectDoubleClick(x, y)
    } catch (_) {
      return -1
    }
  }

  async injectMove(x: number, y: number): Promise<number> {
    try {
      return nativeModule.injectMove(x, y)
    } catch (_) {
      return -1
    }
  }

  async dumpNativeLog(): Promise<string> {
    try {
      return nativeModule.dumpNativeLog()
    } catch (_) {
      return ''
    }
  }
}
```

## 7.2 `Index.ets`

```ts
import { NativeApiImpl } from '../model/NativeApi'

@Entry
@Component
struct Index {
  private api: NativeApiImpl = new NativeApiImpl()
  @State resultText: string = '等待测试'
  @State logText: string = ''

  build() {
    Column({ space: 12 }) {
      Text('HarmonyOS NEXT 输入注入权限验证 PoC')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      Button('检查路径 A 能力')
        .onClick(async () => {
          const result = await this.api.checkInjectionCapability()
          this.resultText = `路径 A 检查结果：${result}`
        })

      Button('路径 A：发送按键 A')
        .onClick(async () => {
          const code = await this.api.injectKey(29, 0)
          this.resultText = `injectKey result=${code}`
        })

      Button('路径 A：发送单击')
        .onClick(async () => {
          const code = await this.api.injectClick(300, 400)
          this.resultText = `injectClick result=${code}`
        })

      Button('导出 Native 日志')
        .onClick(async () => {
          this.logText = await this.api.dumpNativeLog()
        })

      Text(this.resultText)
      Scroll() {
        Text(this.logText)
          .fontSize(12)
      }
      .height('40%')
    }
    .padding(16)
    .width('100%')
    .height('100%')
  }
}
```

## 7.3 `napi_init.cpp`

```cpp
#include <napi/native_api.h>
#include <string>
#include "inject_test.h"

static napi_value CheckInjectionCapability(napi_env env, napi_callback_info info)
{
    napi_value result;
    auto text = checkInjectionCapability();
    napi_create_string_utf8(env, text.c_str(), text.size(), &result);
    return result;
}

static napi_value InjectKey(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t keyCode = 0;
    int32_t action = 0;
    napi_get_value_int32(env, args[0], &keyCode);
    napi_get_value_int32(env, args[1], &action);

    int code = injectKey(keyCode, action);
    napi_value result;
    napi_create_int32(env, code, &result);
    return result;
}
```

## 7.4 `inject_test.cpp`

```cpp
#include "inject_test.h"
#include "inject_logger.h"

std::string checkInjectionCapability()
{
    log_line("checkInjectionCapability start");

    // 这里替换成真实的 HarmonyOS 输入能力检查逻辑
    // 第一阶段允许先返回探测结果与错误信息

    log_line("input injection API not wired yet");
    return "NOT_IMPLEMENTED";
}

int injectKey(int keyCode, int action)
{
    log_line("injectKey called");
    log_line("keyCode=" + std::to_string(keyCode) + ", action=" + std::to_string(action));

    // 这里替换成真实注入逻辑
    return INJECT_NOT_SUPPORTED;
}

int injectClick(int x, int y)
{
    log_line("injectClick called");
    log_line("x=" + std::to_string(x) + ", y=" + std::to_string(y));
    return INJECT_NOT_SUPPORTED;
}

int injectDoubleClick(int x, int y)
{
    log_line("injectDoubleClick called");
    log_line("x=" + std::to_string(x) + ", y=" + std::to_string(y));
    return INJECT_NOT_SUPPORTED;
}

int injectMove(int x, int y)
{
    log_line("injectMove called");
    log_line("x=" + std::to_string(x) + ", y=" + std::to_string(y));
    return INJECT_NOT_SUPPORTED;
}
```

## 8. 权限与配置建议

`module.json5` 需要至少包含：

- 网络权限（如果后续要接桌面端调试服务）
- 无障碍扩展声明
- 如系统级注入接口需要额外权限，也要显式声明

注意：

- 如果声明了权限但仍然 `PERMISSION_DENIED`，要在结果中明确标注可能需要系统签名
- 不要把"权限已声明"误判为"能力可用"

## 9. 开发顺序建议

建议按如下顺序编码：

### 第 1 阶段

先完成 UI 壳和日志能力：

- `Index.ets`
- `NativeApi.ets`
- `inject_logger.*`

### 第 2 阶段

完成 Native 占位接口：

- `napi_init.cpp`
- `inject_test.*`

先让每个按钮都能打到日志。

### 第 3 阶段

接路径 A：

- 查真实 API
- 接真实权限
- 逐个动作验证

### 第 4 阶段

接路径 B：

- 建无障碍扩展
- 测试节点遍历
- 测试点击和输入

### 第 5 阶段

整理导出：

- 日志导出
- 结果矩阵导出
- 截图与录屏归档

## 10. 结果记录建议

建议在工程内准备一个结果记录模板，例如：

```text
/docs/
  RESULT.md
  EVIDENCE.md
  logs/
  videos/
  screenshots/
```

每做完一个测试动作，立即补一条记录，不要最后回忆。

## 11. 最低验收状态

如果时间有限，最低也要做到：

1. 页面可运行
2. 路径 A 的能力检查可返回明确结果
3. 路径 B 的无障碍服务可启动
4. 至少完成 1 个跨应用验证动作
5. 能输出明确的 go / no-go 判断

## 12. 不要做的事情

- 不要一开始接入完整 Input Leap 协议
- 不要做复杂页面路由
- 不要为了美观增加大量状态管理
- 不要在本应用页面里自测成功就下结论
- 不要跳过日志和录屏

---

## 13. 建议交接话术

把这份文档和需求文档一起交给另一台机器的开发者，并明确说明：

- 目标不是做产品，而是拿到权限边界结论
- 结论比实现量更重要
- 失败证据和成功证据同样重要
