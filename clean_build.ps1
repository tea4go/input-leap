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
    构建产物安装到项目根的 bin\windows（与 bin\windows\run-server.bat 同级）。

    前置要求：仅需 Visual Studio 2022/2019（含 C++ 生成工具）与 CMake，其余依赖
    随仓库提供。CMake 优先取 PATH 中的 cmake；若未安装，会自动回退到 Visual Studio
    自带的 CMake（BuildTools 版通常自带，但不加入 PATH）。

    环境变量：B_BUILD_TYPE 指定构建类型，默认 Release。
.PARAMETER Clean
    只清理 build 目录后退出，不做任何构建。也可写成 --clean。
.PARAMETER Help
    显示本帮助后退出。也可写成 --help。
.EXAMPLE
    .\clean_build.ps1    清理并构建（默认行为）。
.EXAMPLE
    .\clean_build.ps1 --clean    只清理 build 目录，不构建。
.EXAMPLE
    .\clean_build.ps1 --help    显示帮助。
.NOTES
    脚本会删除并重建 ./build 目录，请勿在其中存放需保留的内容。
#>

param(
    [switch]$Clean,
    [switch]$Help
)

# ---- 提前退出：--help 显示帮助、--clean 只清理不构建 --------------------------
# 置于最前，这样即使没装 Visual Studio / CMake 也能使用。
if ($Help) {
    Get-Help $PSCommandPath -Detailed;
    exit 0;
}

if ($Clean) {
    if (Test-Path -LiteralPath build) {
        Remove-Item -LiteralPath build -Recurse;
        Write-Output "Cleaned: build";
    } else {
        Write-Output "Nothing to clean: build not found";
    }
    exit 0;
}

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

# ---- 2. 定位 CMake ----------------------------------------------------------
# 优先使用 PATH 中的 cmake；找不到时回退到 Visual Studio 自带的 CMake
# （BuildTools 通常自带，但不会加入 PATH，故裸调 cmake 会失败）。
$cmake = $null;
$cmake_cmd = Get-Command cmake -CommandType Application -ErrorAction SilentlyContinue;
if ($cmake_cmd) {
    $cmake = $cmake_cmd.Source;
}
if (-not $cmake) {
    # 由 VsDevCmd.bat 路径反推 VS 安装根目录：...\<VSROOT>\Common7\Tools\VsDevCmd.bat
    $vs_root = Split-Path (Split-Path (Split-Path $vs_path -Parent) -Parent) -Parent;
    $bundled_cmake = Join-Path $vs_root 'Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe';
    if (Test-Path -LiteralPath $bundled_cmake) {
        $cmake = $bundled_cmake;
    }
}
if (-not $cmake) {
    Write-Output "Could not find cmake in PATH nor in Visual Studio. Please install CMake.";
    break;
}

Write-Output "Using CMake at $cmake";

# ---- 3. 读取构建参数 --------------------------------------------------------
# 优先读取环境变量，未设置时使用默认值。
$build_type = 'Release';
if ($env:B_BUILD_TYPE -ne $null) {
    $build_type = $env:B_BUILD_TYPE;
}

# ---- 4. 清空并重建 build 目录 ----------------------------------------------
if (Test-Path -LiteralPath build) {
    Remove-Item -LiteralPath build -Recurse;
}
New-Item -Force -ItemType Directory -Path .\build | Out-Null
pushd build

# ---- 5. 配置、编译并安装 ----------------------------------------------------
try {
    # 安装到项目根的 bin\windows（$PSScriptRoot 即脚本所在目录，也就是仓库根）
    $install_dir = Join-Path $PSScriptRoot 'bin\windows'

    # 仅构建命令行程序：关闭 GUI（省去 Qt/Bonjour 依赖）与单元测试（省去 ext/gtest 子模块）
    & $cmake .. -G "$vs_version" -A x64 `
        "-DCMAKE_BUILD_TYPE=$build_type" `
        -DINPUTLEAP_BUILD_GUI=OFF `
        -DINPUTLEAP_BUILD_TESTS=OFF `
        "-DCMAKE_INSTALL_PREFIX=$install_dir"

    # 并行编译并执行 install 目标，产物落到 input-leap-install
    & $cmake --build . --parallel --config $build_type --target install
} finally {
    popd
}
