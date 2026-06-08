# HarmonyOS NEXT 输入注入相关 API 速查表

> **说明：** 本文档基于 OpenHarmony 公开文档和社区资料整理，实际 API 可用性需在真机上验证。标记为"待确认"的接口需要在开发环境中实际查找。

---

## 1. 多模输入子系统 API

### 1.1 输入事件客户端（系统级注入）

**模块名：** `@ohos.multimodalInput.inputEventClient`

**权限要求：** 可能需要 `ohos.permission.INJECT_INPUT_EVENT`（系统权限）

**关键接口（待确认）：**

```typescript
import inputEventClient from '@ohos.multimodalInput.inputEventClient';

// 注入按键事件
inputEventClient.injectKeyEvent(keyEvent: KeyEvent): Promise<void>

// 注入指针事件
inputEventClient.injectPointerEvent(pointerEvent: PointerEvent): Promise<void>

// 注入触摸事件
inputEventClient.injectTouchEvent(touchEvent: TouchEvent): Promise<void>
```

**KeyEvent 结构（待确认）：**

```typescript
interface KeyEvent {
  keyCode: number;        // 按键码
  keyAction: KeyAction;   // DOWN / UP
  keyDownDuration?: number;
  timestamp?: number;
}

enum KeyAction {
  DOWN = 0,
  UP = 1
}
```

**PointerEvent 结构（待确认）：**

```typescript
interface PointerEvent {
  action: PointerAction;  // DOWN / UP / MOVE
  pointerId: number;
  x: number;
  y: number;
  timestamp?: number;
}

enum PointerAction {
  DOWN = 0,
  UP = 1,
  MOVE = 2
}
```

**验证方法：**

```typescript
// 检查模块是否存在
try {
  const client = inputEventClient;
  console.log('inputEventClient 模块存在');
} catch (err) {
  console.error('inputEventClient 模块不存在或无权限');
}

// 尝试调用
try {
  await inputEventClient.injectKeyEvent({
    keyCode: 29, // A
    keyAction: KeyAction.DOWN
  });
  console.log('注入成功');
} catch (err) {
  console.error('注入失败:', err.code, err.message);
}
```

---

### 1.2 输入监控（仅监听，不注入）

**模块名：** `@ohos.multimodalInput.inputMonitor`

**用途：** 监听输入事件，不能注入

**关键接口：**

```typescript
import inputMonitor from '@ohos.multimodalInput.inputMonitor';

// 监听触摸事件
inputMonitor.on('touch', (touchEvent: TouchEvent) => {
  console.log('触摸事件:', touchEvent);
});

// 监听鼠标事件
inputMonitor.on('mouse', (mouseEvent: MouseEvent) => {
  console.log('鼠标事件:', mouseEvent);
});
```

**注意：** 此模块仅用于监听，不能用于注入。

---

### 1.3 输入设备管理

**模块名：** `@ohos.multimodalInput.inputDevice`

**用途：** 查询输入设备信息

**关键接口：**

```typescript
import inputDevice from '@ohos.multimodalInput.inputDevice';

// 获取输入设备列表
inputDevice.getDeviceList((error, ids) => {
  if (error) {
    console.error('获取设备列表失败');
    return;
  }
  console.log('输入设备 ID 列表:', ids);
});

// 获取设备信息
inputDevice.getDevice(deviceId, (error, device) => {
  console.log('设备信息:', device);
});
```

---

## 2. 无障碍服务 API

### 2.1 无障碍扩展能力

**模块名：** `@ohos.application.AccessibilityExtensionAbility`

**权限要求：** 需要用户手动开启无障碍服务

**基础结构：**

```typescript
import AccessibilityExtensionAbility from '@ohos.application.AccessibilityExtensionAbility';

export default class MyAccessibility extends AccessibilityExtensionAbility {
  onConnect(): void {
    console.log('无障碍服务已连接');
  }

  onDisconnect(): void {
    console.log('无障碍服务已断开');
  }

  onAccessibilityEvent(event: AccessibilityEvent): void {
    console.log('无障碍事件:', event);
  }
}
```

---

### 2.2 节点操作

**模块名：** `@ohos.application.AccessibilityExtensionContext`

**关键接口：**

```typescript
// 获取根节点
let rootElement = this.context.getWindowRootElement();

// 查找节点
let targetNode = rootElement.findElement('button', 'text', '确定');

// 执行动作
targetNode.performAction('click');
targetNode.performAction('longClick');
targetNode.performAction('scrollForward');
targetNode.performAction('scrollBackward');

// 获取节点属性
let text = targetNode.attributeValue('text');
let bounds = targetNode.attributeValue('bounds');
```

**支持的动作类型：**

- `click`：点击
- `longClick`：长按
- `scrollForward`：向前滚动
- `scrollBackward`：向后滚动
- `focus`：获取焦点
- `clearFocus`：清除焦点
- `select`：选中
- `clearSelection`：清除选中
- `copy`：复制
- `paste`：粘贴
- `cut`：剪切

---

### 2.3 文本输入

**关键接口：**

```typescript
// 查找输入框
let inputNode = rootElement.findElement('textField', 'type', 'input');

// 设置文本
inputNode.performAction('setText', { text: 'Hello World' });

// 追加文本
inputNode.performAction('appendText', { text: ' Append' });

// 清除文本
inputNode.performAction('clearText');
```

---

## 3. 输入法框架 API

### 3.1 输入法扩展能力

**模块名：** `@ohos.InputMethodExtensionAbility`

**用途：** 创建输入法应用，不适合通用输入注入

**关键接口：**

```typescript
import InputMethodExtensionAbility from '@ohos.InputMethodExtensionAbility';

export default class MyIME extends InputMethodExtensionAbility {
  onCreate(want): void {
    console.log('输入法已创建');
  }

  onDestroy(): void {
    console.log('输入法已销毁');
  }
}
```

---

### 3.2 输入法控制器

**模块名：** `@ohos.inputMethod`

**用途：** 控制输入法显示/隐藏，不能注入任意按键

**关键接口：**

```typescript
import inputMethod from '@ohos.inputMethod';

// 显示输入法
let controller = inputMethod.getController();
controller.showSoftKeyboard();

// 隐藏输入法
controller.hideSoftKeyboard();

// 插入文本（仅在输入法上下文中有效）
let inputMethodEngine = inputMethod.getInputMethodEngine();
inputMethodEngine.insertText('Hello');
```

**注意：** 输入法框架仅适用于文本输入场景，不能模拟功能键、组合键或鼠标事件。

---

## 4. 剪贴板 API

### 4.1 系统剪贴板

**模块名：** `@ohos.pasteboard`

**权限要求：** 读取剪贴板可能需要用户授权

**关键接口：**

```typescript
import pasteboard from '@ohos.pasteboard';

// 获取系统剪贴板
let systemPasteboard = pasteboard.getSystemPasteboard();

// 写入文本
let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, 'Hello');
systemPasteboard.setData(pasteData);

// 读取文本
systemPasteboard.getData((err, data) => {
  if (err) {
    console.error('读取剪贴板失败');
    return;
  }
  let text = data.getPrimaryText();
  console.log('剪贴板内容:', text);
});

// 监听剪贴板变化
systemPasteboard.on('update', () => {
  console.log('剪贴板已更新');
});
```

---

## 5. 按键码参考

### 5.1 常用按键码（待确认）

基于 OpenHarmony 输入子系统，按键码可能遵循以下规范：

| 按键 | 键码 | 说明 |
|------|------|------|
| A-Z | 29-54 | 字母键 |
| 0-9 | 7-16 | 数字键 |
| Space | 62 | 空格 |
| Enter | 66 | 回车 |
| Backspace | 67 | 退格 |
| Tab | 61 | 制表符 |
| Esc | 111 | 退出 |
| Left | 21 | 左方向键 |
| Right | 22 | 右方向键 |
| Up | 19 | 上方向键 |
| Down | 20 | 下方向键 |
| Ctrl | 113 | 控制键 |
| Shift | 59 | 上档键 |
| Alt | 57 | 替换键 |

**注意：** 实际键码需要查阅 HarmonyOS NEXT 官方文档或头文件 `KeyCode.h`。

---

### 5.2 键码查找方法

**方法 1：查阅官方文档**

```text
https://developer.huawei.com/consumer/cn/doc/harmonyos-references/
```

**方法 2：监听输入事件**

```typescript
import inputMonitor from '@ohos.multimodalInput.inputMonitor';

inputMonitor.on('key', (keyEvent) => {
  console.log('按键码:', keyEvent.keyCode);
  console.log('按键动作:', keyEvent.keyAction);
});
```

**方法 3：查看 Native 头文件**

```bash
# 在 HarmonyOS SDK 中查找
find $OHOS_SDK_NATIVE -name "KeyCode.h"
grep -r "KEY_A" $OHOS_SDK_NATIVE/include
```

---

## 6. 权限声明参考

### 6.1 module.json5 权限配置

```json5
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET",
        "reason": "$string:internet_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "always"
        }
      },
      {
        "name": "ohos.permission.INJECT_INPUT_EVENT",
        "reason": "$string:inject_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "always"
        }
      }
    ],
    "extensionAbilities": [
      {
        "name": "InputLeapAccessibility",
        "srcEntry": "./ets/accessibility/InputLeapAccessibilityExtAbility.ets",
        "type": "accessibility",
        "metadata": [
          {
            "name": "ohos.accessibleability",
            "resource": "$profile:accessibility_config"
          }
        ]
      }
    ]
  }
}
```

---

### 6.2 无障碍服务配置

**文件路径：** `src/main/resources/base/profile/accessibility_config.json`

```json
{
  "accessibilityCapabilities": [
    "retrieve",
    "touchGuide",
    "keyEventObserver",
    "gesture"
  ],
  "accessibilityEventTypes": [
    "click",
    "longClick",
    "focus",
    "select",
    "textUpdate",
    "pageStateUpdate"
  ],
  "notificationTimeout": 0,
  "uiNoninteractiveTimeout": 0
}
```

---

## 7. 错误码参考

### 7.1 常见错误码

| 错误码 | 含义 | 可能原因 |
|--------|------|----------|
| 201 | 权限拒绝 | 未声明权限或需要系统签名 |
| 202 | 非系统应用 | 接口仅供系统应用使用 |
| 401 | 参数错误 | 传入参数类型或值不正确 |
| 801 | 能力不支持 | 设备或系统版本不支持该能力 |
| 17700001 | 输入设备不存在 | 设备 ID 无效 |
| 17700002 | 输入事件注入失败 | 系统拒绝注入或权限不足 |

---

### 7.2 错误处理示例

```typescript
try {
  await inputEventClient.injectKeyEvent(keyEvent);
  console.log('注入成功');
} catch (err) {
  switch (err.code) {
    case 201:
      console.error('权限拒绝，可能需要系统签名');
      break;
    case 202:
      console.error('非系统应用，无法调用此接口');
      break;
    case 17700002:
      console.error('输入事件注入失败');
      break;
    default:
      console.error('未知错误:', err.code, err.message);
  }
}
```

---

## 8. Native API 参考

### 8.1 输入管理器（C++ 层）

**头文件：** `<input_manager.h>`（待确认）

```cpp
#include <input_manager.h>

// 获取输入管理器实例
InputManager* manager = InputManager::GetInstance();

// 注入按键事件
KeyEvent keyEvent;
keyEvent.SetKeyCode(KeyCode::KEY_A);
keyEvent.SetKeyAction(KeyAction::DOWN);
int ret = manager->InjectKeyEvent(keyEvent);

// 注入指针事件
PointerEvent pointerEvent;
pointerEvent.SetPointerAction(PointerAction::DOWN);
pointerEvent.SetDisplayX(100);
pointerEvent.SetDisplayY(200);
ret = manager->InjectPointerEvent(pointerEvent);
```

---

### 8.2 NAPI 桥接示例

```cpp
#include <napi/native_api.h>

static napi_value InjectKey(napi_env env, napi_callback_info info) {
    // 解析参数
    size_t argc = 2;
    napi_value args[2];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    int32_t keyCode, action;
    napi_get_value_int32(env, args[0], &keyCode);
    napi_get_value_int32(env, args[1], &action);
    
    // 调用 Native 输入注入
    // int ret = inject_key_native(keyCode, action);
    
    // 返回结果
    napi_value result;
    napi_create_int32(env, 0, &result);
    return result;
}
```

---

## 9. API 验证流程

### 9.1 验证步骤

1. **检查模块是否存在**
   ```typescript
   try {
     const module = require('@ohos.multimodalInput.inputEventClient');
     console.log('模块存在');
   } catch (err) {
     console.error('模块不存在');
   }
   ```

2. **检查接口是否可调用**
   ```typescript
   if (typeof module.injectKeyEvent === 'function') {
     console.log('接口存在');
   } else {
     console.error('接口不存在');
   }
   ```

3. **尝试调用并捕获错误**
   ```typescript
   try {
     await module.injectKeyEvent(event);
   } catch (err) {
     console.error('调用失败:', err.code, err.message);
   }
   ```

4. **验证实际效果**
   - 切换到第三方应用
   - 观察是否有输入效果
   - 记录日志和录屏

---

### 9.2 验证清单

- [ ] 模块是否存在
- [ ] 接口是否存在
- [ ] 权限是否可声明
- [ ] 权限是否可获得
- [ ] 调用是否成功
- [ ] 是否在本应用内生效
- [ ] 是否在第三方应用生效
- [ ] 是否需要系统签名

---

## 10. 参考资料

### 10.1 官方文档

- [HarmonyOS NEXT 开发者文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides)
- [OpenHarmony 多模输入子系统](https://gitee.com/openharmony/multimodalinput_input)
- [OpenHarmony 无障碍子系统](https://gitee.com/openharmony/accessibility)

### 10.2 社区资源

- [HarmonyOS 开发者论坛](https://developer.huawei.com/consumer/cn/forum/home)
- [OpenHarmony 文档仓库](https://gitee.com/openharmony/docs)

---

**注意事项：**

1. 本速查表基于公开资料整理，实际 API 可能因版本差异而不同
2. 标记为"待确认"的接口需要在真机开发环境中验证
3. 系统级 API 通常需要系统签名，普通开发者可能无法获得
4. 优先使用官方文档中明确说明的 API
5. 如果 API 不存在或无权限，必须在结果报告中明确标注
