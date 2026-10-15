<#
.SYNOPSIS
    InputLeap Windows 构建脚本（仅命令行程序，不含 Qt 界面）

.DESCRIPTION
    在 Windows 上从零构建 InputLeap 的命令行程序：
        input-leapc.exe   客户端
        input-leaps.exe   服务端
        input-leapd.exe   后台守护进程
    通过 INPUTLEAP_BUILD_GUI=OFF 关闭 Qt 界面，因此不需要 Qt、Bonjour SDK 与
    Inno Setup；OpenSSL 使用仓库内 third_party/openssl，无需外部安装。

.PREREQUISITES
    仅需 Visual Studio 2022/2019（含 C++ 生成工具）与 CMake，其余依赖随仓库提供。

.ENVIRONMENT
    B_BUILD_TYPE   构建类型，默认 Release

.NOTES
    脚本会删除并重建 ./build 目录，请勿在其中存放需保留的内容。
#>

# ---- 1. 探测可用的 Visual Studio --------------------------------------------
# 按优先级依次尝试常见安装路径，命中第一个可用的即采用其生成器名（如 "Visual Studio 17 2022"）。
# 覆盖 Enterprise/Professional/Community/BuildTools 四种版本，并兼顾装在 Program Files (x86) 的情况。
$vs_locations = @(
    @{version='Visual Studio 17 2022';
      path='C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat'},
    @{version='Visual Studio 17 2022';
      path='C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\VsDevCmd.bat'},
    @{version='Visual Studio 17 2022';
      path='C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat'},
    @{version='Visual Studio 17 2022';
      path='C:\Program Files\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat'},
    @{version='Visual Studio 17 2022';
      path='C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat'},
    @{version='Visual Studio 16 2019';
      path='C:\Program Files\Microsoft Visual Studio\2019\Enterprise\Common7\Tools\VsDevCmd.bat'},
    @{version='Visual Studio 16 2019';
      path='C:\Program Files\Microsoft Visual Studio\2019\Professional\Common7\Tools\VsDevCmd.bat'},
    @{version='Visual Studio 16 2019';
      path='C:\Program Files\Microsoft Visual Studio\2019\Community\Common7\Tools\VsDevCmd.bat'},
    @{version='Visual Studio 16 2019';
      path='C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\Tools\VsDevCmd.bat'},
    @{version='Visual Studio 16 2019';
      path='C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\Tools\VsDevCmd.bat'},
    @{version='Visual Studio 16 2019';
      path='C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\VsDevCmd.bat'}
);

$vs_version = '';
$vs_path = '';

Foreach ($location in $vs_locations) {
    if (Test-Path -LiteralPath $location.path) {
        $vs_version = $location.version;
        $vs_path = $location.path;
        break;
    }
}

if ($vs_version -eq '') {
    Write-Output "Could not find Visual studio version";
    break;
}

Write-Output "Using Visual Studio version $vs_version at $vs_path";

# ---- 2. 读取构建参数 --------------------------------------------------------
# 优先读取环境变量，未设置时使用默认值。
$build_type = 'Release';
if ($env:B_BUILD_TYPE -ne $null) {
    $build_type = $env:B_BUILD_TYPE;
}

# ---- 3. 清空并重建 build 目录 ----------------------------------------------
if (Test-Path -LiteralPath build) {
    Remove-Item -LiteralPath build -Recurse;
}
New-Item -Force -ItemType Directory -Path .\build | Out-Null
pushd build

# ---- 4. 配置、编译并安装 ----------------------------------------------------
try {
    # 仅构建命令行程序：关闭 GUI（省去 Qt/Bonjour 依赖）与单元测试（省去 ext/gtest 子模块）
    cmake .. -G "$vs_version" -A x64 `
        "-DCMAKE_BUILD_TYPE=$build_type" `
        -DINPUTLEAP_BUILD_GUI=OFF `
        -DINPUTLEAP_BUILD_TESTS=OFF `
        -DCMAKE_INSTALL_PREFIX=input-leap-install

    # 并行编译并执行 install 目标，产物落到 input-leap-install
    cmake --build . --parallel --config $build_type --target install
} finally {
    popd
}
