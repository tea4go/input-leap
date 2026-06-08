# HarmonyOS NEXT 输入注入权限验证 PoC 证据文件索引

> **填写说明：** 本文档用于索引所有验证证据文件，便于审核和复现。所有标记为 `[待填写]` 的地方都必须替换为实际内容。

---

## 1. 证据文件目录结构

建议在 PoC 工程根目录下创建以下结构：

```text
inputleap-harmony-poc/
├─ evidence/
│  ├─ logs/
│  │  ├─ full_log.txt
│  │  ├─ path_a_test.log
│  │  └─ path_b_test.log
│  ├─ videos/
│  │  ├─ path_a_inject_key.mp4
│  │  ├─ path_a_inject_click.mp4
│  │  ├─ path_b_accessibility.mp4
│  │  └─ cross_app_test.mp4
│  ├─ screenshots/
│  │  ├─ device_info.png
│  │  ├─ permission_status.png
│  │  ├─ path_a_success.png
│  │  ├─ path_a_failure.png
│  │  ├─ path_b_node_tree.png
│  │  └─ error_message.png
│  └─ exports/
│     ├─ capability_matrix.csv
│     └─ test_results.json
```

---

## 2. 日志文件清单

### 2.1 完整日志

| 文件名 | 大小 | 生成时间 | 说明 |
|--------|------|---------|------|
| `logs/full_log.txt` | [待填写] | [待填写] | 完整运行日志，包含所有测试动作 |

**关键内容摘要：**

```text
[待填写：粘贴日志中最关键的 10-20 行]
```

### 2.2 路径 A 日志

| 文件名 | 大小 | 生成时间 | 说明 |
|--------|------|---------|------|
| `logs/path_a_test.log` | [待填写] | [待填写] | 系统级输入注入测试日志 |

**关键内容摘要：**

```text
[待填写：粘贴路径 A 的关键日志片段]
```

### 2.3 路径 B 日志

| 文件名 | 大小 | 生成时间 | 说明 |
|--------|------|---------|------|
| `logs/path_b_test.log` | [待填写] | [待填写] | 无障碍服务测试日志 |

**关键内容摘要：**

```text
[待填写：粘贴路径 B 的关键日志片段]
```

---

## 3. 视频证据清单

### 3.1 路径 A 视频

| 文件名 | 时长 | 大小 | 说明 |
|--------|------|------|------|
| `videos/path_a_inject_key.mp4` | [待填写] | [待填写] | 演示键盘注入测试过程 |
| `videos/path_a_inject_click.mp4` | [待填写] | [待填写] | 演示点击注入测试过程 |
| `videos/path_a_inject_move.mp4` | [待填写] | [待填写] | 演示移动注入测试过程 |

**视频内容要求：**

每个视频必须包含：

1. 开始时展示设备信息和系统版本
2. 展示 PoC 应用界面
3. 点击测试按钮
4. 切换到目标第三方应用
5. 观察注入效果
6. 返回 PoC 应用查看日志

### 3.2 路径 B 视频

| 文件名 | 时长 | 大小 | 说明 |
|--------|------|------|------|
| `videos/path_b_accessibility.mp4` | [待填写] | [待填写] | 演示无障碍服务测试过程 |
| `videos/path_b_node_click.mp4` | [待填写] | [待填写] | 演示节点点击测试 |
| `videos/path_b_text_input.mp4` | [待填写] | [待填写] | 演示文本输入测试 |

### 3.3 跨应用验证视频

| 文件名 | 时长 | 大小 | 说明 |
|--------|------|------|------|
| `videos/cross_app_test_notepad.mp4` | [待填写] | [待填写] | 在备忘录应用中的验证 |
| `videos/cross_app_test_browser.mp4` | [待填写] | [待填写] | 在浏览器应用中的验证 |
| `videos/cross_app_test_settings.mp4` | [待填写] | [待填写] | 在系统设置中的验证 |

---

## 4. 截图证据清单

### 4.1 环境信息截图

| 文件名 | 说明 |
|--------|------|
| `screenshots/device_info.png` | 设备型号、HarmonyOS 版本、API Level |
| `screenshots/app_signature.png` | 应用签名类型 |
| `screenshots/permission_list.png` | 应用权限列表 |

### 4.2 路径 A 截图

| 文件名 | 说明 |
|--------|------|
| `screenshots/path_a_capability_check.png` | 能力检查结果 |
| `screenshots/path_a_inject_success.png` | 注入成功的界面 |
| `screenshots/path_a_inject_failure.png` | 注入失败的界面 |
| `screenshots/path_a_error_message.png` | 错误信息截图 |
| `screenshots/path_a_permission_denied.png` | 权限拒绝截图（如有） |

### 4.3 路径 B 截图

| 文件名 | 说明 |
|--------|------|
| `screenshots/path_b_service_status.png` | 无障碍服务状态 |
| `screenshots/path_b_node_tree.png` | 节点树遍历结果 |
| `screenshots/path_b_click_success.png` | 点击成功的界面 |
| `screenshots/path_b_text_input_success.png` | 文本输入成功的界面 |

### 4.4 跨应用验证截图

| 文件名 | 说明 |
|--------|------|
| `screenshots/target_app_before.png` | 目标应用注入前状态 |
| `screenshots/target_app_after.png` | 目标应用注入后状态 |
| `screenshots/target_app_effect.png` | 注入效果展示 |

---

## 5. 导出数据文件

### 5.1 能力矩阵

| 文件名 | 格式 | 说明 |
|--------|------|------|
| `exports/capability_matrix.csv` | CSV | 路径 A 和路径 B 的能力验证矩阵 |

**CSV 内容示例：**

```csv
路径,能力项,接口可调用,实际生效,跨应用生效,需系统权限,备注
A,键盘字符键,是,否,否,是,返回 PERMISSION_DENIED
A,单击,是,是,是,是,需要系统签名
B,节点点击,是,是,是,否,依赖节点树
```

### 5.2 测试结果

| 文件名 | 格式 | 说明 |
|--------|------|------|
| `exports/test_results.json` | JSON | 结构化测试结果 |

**JSON 内容示例：**

```json
{
  "device": {
    "model": "MatePad Pro 13.2",
    "os_version": "HarmonyOS NEXT 5.0.0.25",
    "api_level": 12
  },
  "path_a": {
    "result": "failure",
    "reason": "PERMISSION_DENIED",
    "tests": [
      {
        "action": "injectKey",
        "success": false,
        "code": 2,
        "message": "Permission denied"
      }
    ]
  },
  "path_b": {
    "result": "partial_success",
    "tests": [
      {
        "action": "nodeClick",
        "success": true,
        "target_app": "Notepad"
      }
    ]
  }
}
```

---

## 6. 证据完整性检查清单

在提交前，请确认以下证据已齐全：

### 6.1 必需证据

- [ ] 完整日志文件（`logs/full_log.txt`）
- [ ] 至少 1 份路径 A 测试录屏
- [ ] 至少 1 份路径 B 测试录屏
- [ ] 至少 1 份跨应用验证录屏
- [ ] 设备信息截图
- [ ] 权限状态截图
- [ ] 能力矩阵导出文件

### 6.2 失败场景必需证据

如果路径 A 或路径 B 失败，必须提供：

- [ ] 错误信息截图
- [ ] 失败时的完整日志
- [ ] 权限申请失败的截图（如适用）
- [ ] 接口调用返回值截图

### 6.3 成功场景必需证据

如果路径 A 或路径 B 成功，必须提供：

- [ ] 跨应用生效的录屏
- [ ] 目标应用注入前后对比截图
- [ ] 成功调用的日志片段

---

## 7. 证据文件命名规范

为便于审核，请遵循以下命名规范：

### 7.1 日志文件

- 格式：`{路径}_{测试项}_{时间戳}.log`
- 示例：`path_a_inject_key_20260528_101230.log`

### 7.2 视频文件

- 格式：`{路径}_{测试项}_{目标应用}_{结果}.mp4`
- 示例：`path_a_inject_click_notepad_success.mp4`

### 7.3 截图文件

- 格式：`{类别}_{内容描述}.png`
- 示例：`path_a_error_permission_denied.png`

---

## 8. 证据提交方式

### 8.1 文件大小限制

- 单个视频文件不超过 100 MB
- 如超过，请压缩或分段
- 截图文件建议使用 PNG 格式

### 8.2 压缩包结构

如需打包提交，建议使用以下结构：

```text
inputleap-harmony-poc-evidence.zip
├─ README.md（本文档）
├─ RESULT.md（结果报告）
├─ logs/
├─ videos/
├─ screenshots/
└─ exports/
```

---

## 9. 证据审核要点

审核人员将重点检查：

1. **日志完整性**
   - 是否包含设备信息
   - 是否包含接口调用入参和返回值
   - 是否包含错误码和错误信息

2. **视频真实性**
   - 是否在真机上录制
   - 是否展示了完整测试流程
   - 是否展示了跨应用效果

3. **截图清晰度**
   - 关键信息是否清晰可读
   - 是否包含时间戳或版本信息

4. **结果一致性**
   - 日志、视频、截图是否相互印证
   - 结论是否与证据匹配

---

## 10. 常见问题

### Q: 如果某个测试项没有对应证据怎么办？

A: 必须在 `RESULT.md` 中明确说明原因，例如"该测试项因 XXX 原因未执行"。

### Q: 如果视频文件过大怎么办？

A: 可以：
1. 降低分辨率（建议 720p）
2. 缩短录制时长（只保留关键部分）
3. 使用视频压缩工具
4. 分段录制

### Q: 如果没有录屏工具怎么办？

A: HarmonyOS NEXT 系统自带录屏功能，可通过下拉控制中心启用。

### Q: 日志文件应该包含哪些信息？

A: 至少包含：
- 时间戳
- 设备信息
- 接口名称
- 入参
- 返回值
- 错误码
- 错误信息
- 实际观察结果

---

## 11. 证据文件检查脚本

建议在提交前运行以下检查：

```bash
#!/bin/bash
# evidence_check.sh

echo "检查证据文件完整性..."

# 检查必需目录
for dir in logs videos screenshots exports; do
  if [ ! -d "evidence/$dir" ]; then
    echo "❌ 缺少目录: evidence/$dir"
  else
    echo "✅ 目录存在: evidence/$dir"
  fi
done

# 检查必需文件
required_files=(
  "logs/full_log.txt"
  "screenshots/device_info.png"
  "exports/capability_matrix.csv"
)

for file in "${required_files[@]}"; do
  if [ ! -f "evidence/$file" ]; then
    echo "❌ 缺少文件: evidence/$file"
  else
    echo "✅ 文件存在: evidence/$file"
  fi
done

# 检查视频文件数量
video_count=$(ls evidence/videos/*.mp4 2>/dev/null | wc -l)
if [ $video_count -lt 2 ]; then
  echo "❌ 视频文件不足 2 个（当前 $video_count 个）"
else
  echo "✅ 视频文件数量: $video_count"
fi

echo "检查完成"
```

---

## 12. 联系方式

如对证据文件要求有疑问，请在 `RESULT.md` 的"未预期问题"章节中说明。

---

**备注：** 所有证据文件必须基于真机验证生成，不得使用模拟器或伪造数据。
