# Input Leap

Input Leap 是一个开源的键盘鼠标共享工具，允许你用一套键盘和鼠标控制多台电脑。它通过网络连接，让多台机器像使用一个 KVM 切换器一样协同工作——只需将鼠标移动到屏幕边缘即可切换到另一台电脑。

- 版本：3.0.3-release（2025 年 6 月）
- 许可证：GPL-2.0
- 项目地址：https://github.com/input-leap/input-leap

## 目录结构

```
/opt/input-leap/
├── bin/
│   ├── input-leap          # GUI 图形界面
│   ├── input-leapc         # 客户端（连接到服务器）
│   └── input-leaps         # 服务器（共享键鼠给客户端）
├── lib/
│   ├── libei.so.1          # Event Interception 库
│   └── libportal.so.1      # XDG Desktop Portal 库
├── share/
│   ├── applications/       # .desktop 桌面入口
│   ├── icons/              # 应用图标
│   ├── man/man1/           # man 手册
│   └── metainfo/           # AppStream 元数据
├── run-client.sh           # 客户端启动脚本
├── install-service.sh      # systemd 服务安装脚本
└── README.md
```

## 核心概念

- **服务器（Server）**：运行 `input-leaps` 的那台电脑，它的键盘和鼠标将被共享给其他电脑。
- **客户端（Client）**：运行 `input-leapc` 的电脑，接收来自服务器的键鼠输入。
- 一台服务器可以连接多台客户端。鼠标移到屏幕边缘时，控制权自动切换到相邻的客户端屏幕。

## 快速开始

### 1. 启动服务器

在主控电脑上（你的键鼠所在的机器）：

```bash
# 需要先准备配置文件，见下方「服务器配置文件」章节
export LD_LIBRARY_PATH=/opt/input-leap/lib

# 前台运行（便于调试）
/opt/input-leap/bin/input-leaps -f --config /path/to/input-leap.conf --debug NOTE

# 后台守护进程运行
/opt/input-leap/bin/input-leaps --config /path/to/input-leap.conf
```

### 2. 启动客户端

在被控电脑上：

```bash
export LD_LIBRARY_PATH=/opt/input-leap/lib

# 前台运行，连接到服务器
/opt/input-leap/bin/input-leapc -f --name MyPC --debug NOTE <服务器IP>:24800

# 禁用加密（内网环境可选）
/opt/input-leap/bin/input-leapc -f --name MyPC --disable-crypto <服务器IP>:24800
```

### 3. 使用 GUI

```bash
export LD_LIBRARY_PATH=/opt/input-leap/lib
/opt/input-leap/bin/input-leap
```

GUI 提供可视化的屏幕布局配置和服务管理。

## 服务器配置文件

配置文件查找顺序：

1. `$HOME/.config/InputLeap/input-leap.conf`
2. `/etc/input-leap.conf`
3. 通过 `--config` 参数指定

示例配置（两台电脑，左右排列）：

```
section: screens
    ServerPC:
    ClientPC:
end

section: links
    ServerPC:
        right = ClientPC
    ClientPC:
        left = ServerPC
end

section: options
    screenSaverSync = true
    clipboardSharing = true
end
```

- `screens` 段声明所有参与的屏幕名称（需与 `--name` 参数匹配）。
- `links` 段定义屏幕之间的拓扑关系（left/right/up/down）。
- `options` 段设置全局选项，如剪贴板同步、屏保同步等。

## 当前部署配置

本机已预配置为客户端，连接参数：

| 参数       | 值                  |
|------------|---------------------|
| 服务器地址 | `10.68.8.73:24800`  |
| 屏幕名称   | `WhitePC`           |
| 日志级别   | `NOTE`              |
| 加密       | 禁用                |

快速启动：

```bash
/opt/input-leap/run-client.sh
```

## 设为开机自启（systemd 用户服务）

运行安装脚本（以普通用户身份，不要用 sudo）：

```bash
bash /opt/input-leap/install-service.sh
```

该脚本会：
- 创建 `~/.config/systemd/user/input-leap-client.service`
- 注册为用户级 systemd 服务，跟随图形会话自动启动
- 连接失败时每 5 秒自动重试

常用服务管理命令：

```bash
# 查看状态
systemctl --user status input-leap-client

# 停止服务
systemctl --user stop input-leap-client

# 重启服务
systemctl --user restart input-leap-client

# 禁用自启
systemctl --user disable input-leap-client

# 查看日志
journalctl --user -u input-leap-client -f
```

## 命令行参数

### input-leapc（客户端）

```
input-leapc [选项] <服务器地址>
```

| 参数                      | 说明                                     |
|---------------------------|------------------------------------------|
| `-f, --no-daemon`         | 前台运行                                 |
| `-n, --name <名称>`       | 屏幕名称（默认使用主机名）               |
| `-d, --debug <级别>`      | 日志级别：FATAL/ERROR/WARNING/NOTE/INFO/DEBUG |
| `-l, --log <文件>`        | 日志输出到文件                           |
| `--enable-crypto`         | 启用 SSL 加密（默认）                    |
| `--disable-crypto`        | 禁用 SSL 加密                            |
| `--use-x11`              | 使用 X11 后端                            |
| `--use-ei`               | 使用 EI（Event Interception）后端        |
| `--yscroll <delta>`      | 垂直滚动增量（默认 120）                 |
| `--enable-drag-drop`     | 启用文件拖放                             |
| `-1, --no-restart`       | 失败后不自动重启                         |
| `--restart`              | 失败后自动重启（默认）                   |

### input-leaps（服务器）

```
input-leaps [选项]
```

| 参数                              | 说明                                     |
|-----------------------------------|------------------------------------------|
| `-a, --address <地址>`            | 监听地址（默认 `0.0.0.0:24800`）         |
| `-c, --config <路径>`             | 指定配置文件路径                         |
| `-f, --no-daemon`                 | 前台运行                                 |
| `-n, --name <名称>`               | 屏幕名称（默认使用主机名）               |
| `-d, --debug <级别>`              | 日志级别                                 |
| `-l, --log <文件>`                | 日志输出到文件                           |
| `--enable-crypto`                 | 启用 SSL 加密（默认）                    |
| `--disable-crypto`                | 禁用 SSL 加密                            |
| `--screen-change-script <路径>`   | 屏幕切换时执行的脚本                     |
| `--use-x11`                      | 使用 X11 后端                            |
| `--use-ei`                       | 使用 EI 后端                             |
| `--enable-drag-drop`             | 启用文件拖放                             |

## 网络要求

- 默认端口：**24800/TCP**
- 确保防火墙允许客户端访问服务器的 24800 端口
- 服务器地址格式：`<主机名或IP>[:<端口>]`，IPv6 需加方括号如 `[::1]:24800`

## 故障排查

**客户端连不上服务器**
```bash
# 测试网络连通性
ping <服务器IP>
nc -zv <服务器IP> 24800

# 以 DEBUG 级别运行查看详细日志
LD_LIBRARY_PATH=/opt/input-leap/lib /opt/input-leap/bin/input-leapc -f \
    --name MyPC --debug DEBUG <服务器IP>:24800
```

**服务启动失败**
```bash
# 查看 systemd 日志
journalctl --user -u input-leap-client -n 50 --no-pager

# 检查进程是否在运行
pgrep -a input-leap
```

**屏幕名称不匹配**

客户端的 `--name` 参数必须与服务器配置文件中 `screens` 段里声明的名称完全一致（区分大小写）。

**加密不匹配**

服务器和客户端的加密设置必须一致，要么都启用，要么都禁用。

## 系统依赖

运行环境需要以下系统库（大部分 Linux 桌面发行版已预装）：

- X11 相关：libX11, libXext, libXrandr, libXinerama, libXtst, libXi
- libxkbcommon（键盘布局）
- GLib / GObject
- OpenSSL 3（加密支持）
- libstdc++6, libgcc_s

libei 和 libportal 已随本分发包提供在 `lib/` 目录下。
