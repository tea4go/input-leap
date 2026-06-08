# HarmonyOS NEXT 输入注入 PoC 快速参考

## 核心目标

验证第三方应用能否在 HarmonyOS NEXT 平板上实现全局输入注入。

## 验证路径

- **路径 A：** 系统级输入注入 API（主路径）
- **路径 B：** 无障碍服务替代方案（降级路径）

## 快速开始

### 1. 环境准备

```bash
# 确认 DevEco Studio 已安装
# 确认 HarmonyOS NEXT 真机已连接
# 确认可部署最小示例应用
```

### 2. 创建最小工程

```bash
# 创建 Stage 应用
# 项目名：inputleap-harmony-poc
# 包名：com.inputleap.poc
# 最低 API：HarmonyOS NEXT
```

### 3. 路径 A 验证清单

- [ ] 查找输入注入相关 API
- [ ] 申请必要权限
- [ ] 测试键盘注入
- [ ] 测试点击注入
- [ ] 测试移动注入
- [ ] 验证跨应用生效
- [ ] 记录权限要求

### 4. 路径 B 验证清单

- [ ] 创建 AccessibilityExtensionAbility
- [ ] 启用无障碍服务
- [ ] 测试节点遍历
- [ ] 测试点击动作
- [ ] 测试文本输入
- [ ] 测试滚动动作
- [ ] 评估限制边界

## 关键 API 参考

### 系统级注入（路径 A）

```typescript
// 伪代码示例
import inputEventClient from '@ohos.multimodalInput.inputEventClient';

// 注入按键
inputEventClient.injectKeyEvent({
  keyCode: KeyCode.KEY_A,
  keyAction: KeyAction.DOWN
});

// 注入点击
inputEventClient.injectPointerEvent({
  action: PointerAction.DOWN,
  x: 100,
  y: 200
});
```

### 无障碍服务（路径 B）

```typescript
// 伪代码示例
import accessibility from '@ohos.accessibility';

export default class MyAccessibility extends AccessibilityExtensionAbility {
  onConnect() {
    // 获取根节点
    let rootNode = this.context.getWindowRootElement();
    
    // 查找按钮
    let button = rootNode.findElement('button', 'text', '确定');
    
    // 执行点击
    button.performAction('click');
  }
}
```

## 测试矩阵

### 路径 A 测试项

| 能力 | 接口可调用 | 实际生效 | 跨应用 | 需系统权限 |
|------|-----------|---------|--------|-----------|
| 键盘字符 | ? | ? | ? | ? |
| 方向键 | ? | ? | ? | ? |
| 单击 | ? | ? | ? | ? |
| 双击 | ? | ? | ? | ? |
| 移动 | ? | ? | ? | ? |

### 路径 B 测试项

| 能力 | 可实现 | 跨应用 | 稳定性 | 限制 |
|------|--------|--------|--------|------|
| 节点点击 | ? | ? | ? | ? |
| 文本输入 | ? | ? | ? | ? |
| 列表滚动 | ? | ? | ? | ? |
| 按键模拟 | ? | ? | ? | ? |

## 必须记录的信息

- 设备型号
- HarmonyOS NEXT 版本
- API 版本
- 应用签名类型
- 权限申请结果
- 接口调用返回值
- 错误码与错误信息
- 实际观察结果

## 交付物清单

- [ ] PoC 工程代码
- [ ] README.md（构建部署说明）
- [ ] RESULT.md（验证结果）
- [ ] EVIDENCE.md（证据索引）
- [ ] 测试录屏（至少 2 份）
- [ ] 完整日志（至少 1 份）
- [ ] 失败截图（如有）

## 最终结论模板

```markdown
## 结论摘要

- 路径 A：成功 / 失败 / 部分成功
- 路径 B：成功 / 失败 / 部分成功
- 建议：继续 / 降级继续 / 暂停

## 关键发现

- 系统级注入是否可用：
- 是否需要系统签名：
- 是否需要厂商支持：
- 无障碍方案是否可用：
- 能否支撑 Input Leap 最小需求：

## 项目建议

三选一：
1. 继续实现主路径
2. 仅考虑降级版
3. 终止适配
```

## 常见问题

### Q: 如何判断是否需要系统签名？

A: 如果接口调用返回 `PERMISSION_DENIED` 且权限已在 `module.json5` 中声明，通常意味着需要系统签名。

### Q: 无障碍方案算不算全局输入注入？

A: 不算。无障碍方案依赖节点树，无法模拟任意按键和精确鼠标轨迹，只能作为降级方案。

### Q: 如何验证跨应用生效？

A: 必须在 PoC 应用之外的第三方应用中观察到注入效果，例如在备忘录中看到字符输入。

### Q: 如果路径 A 和路径 B 都失败怎么办？

A: 明确在结论中标注"不建议继续 HarmonyOS NEXT 适配"，并说明原因。

## 参考资料

- [OpenHarmony 多模输入子系统](https://gitee.com/openharmony/multimodalinput_input)
- [OpenHarmony 无障碍子系统](https://gitee.com/openharmony/accessibility)
- [HarmonyOS NEXT 开发者文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides)
- [Android Synergy 参考实现](https://github.com/mo3rfan/synergy-android-cyanogen)

## 联系方式

如遇到文档中未覆盖的问题，请记录在 `RESULT.md` 的"未预期问题"章节中。
