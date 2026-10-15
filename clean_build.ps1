<#
.SYNOPSIS
    InputLeap Windows 构建脚本（GUI 版：Qt 界面 + Bonjour 服务发现 + Inno Setup 安装包）

.DESCRIPTION
    在 Windows 上从零构建 InputLeap，并生成 Inno Setup 安装包。

    重要：本项目现已改为“只构建命令行程序”，CMakeLists.txt 中 INPUTLEAP_BUILD_GUI
    默认为 OFF，不再编译 Qt 界面。本脚本仍按旧的 GUI 方式构建，因此强依赖 Qt 与
    Bonjour SDK，仅在确实需要 GUI 时使用。
    若只需命令行程序（input-leapc / input-leaps），可参考 .github/workflows/win-release.yml：
        cmake -S . -B build -G "Visual Studio 17 2022" -A x64 `
              -DINPUTLEAP_BUILD_GUI=OFF -DINPUTLEAP_BUILD_TESTS=OFF
        cmake --build build --config Release --target install

.PREREQUISITES
    以下依赖需先通过 Chocolatey 安装：cmake, openssl, aqt (3.1.17), InnoSetup
    Qt 需手动安装，或用 aqt 安装，例如：
        aqt install-qt windows desktop 6.4.2 win64_msvc2019_64 -O C:\Qt
        aqt install-qt windows desktop 5.15.2 win64_msvc2019_64 -O C:\Qt
    安装后可能需要重启 PowerShell 使环境变量生效。

.ENVIRONMENT
    B_BUILD_TYPE        构建类型，默认 Release
    B_QT_MAJOR_VERSION  Qt 主版本号，默认 6
    B_QT_ROOT           Qt 根目录；未设置时自动在 C:\Qt\<主版本>* 下探测

.NOTES
    脚本会删除并重建 ./build 目录，请勿在其中存放需保留的内容。
#>

# ---- 1. 下载并解压 Bonjour SDK ----------------------------------------------
# GUI 版通过 Bonjour(mDNS / DNS-SD) 做局域网服务自动发现，需要 dns_sd.h 与 dnssd.lib。
# 命令行版不依赖 Bonjour，故 CLI-only 构建可跳过本节。
$bonjour_path = '.\deps\BonjourSDKLike'

New-Item -Force -ItemType Directory -Path .\deps | Out-Null
# 从 nelsonjchen/mDNSResponder 发布页下载预编译的 Bonjour SDK（头文件 + 导入库）
Invoke-WebRequest 'https://github.com/nelsonjchen/mDNSResponder/releases/download/v2019.05.08.1/x64_RelWithDebInfo.zip' -OutFile 'deps\BonjourSDKLike.zip' ;
# 若上次残留解压目录，先清掉，保证干净解压
if (Test-Path -LiteralPath $bonjour_path) {
    Remove-Item -LiteralPath $bonjour_path -Recurse
}

# CMake 的 DNSSD_LIB 参数要求绝对路径，这里把相对路径拼成绝对路径
$bonjour_path = -join((Get-Location).Path, '\', $bonjour_path);

Expand-Archive .\deps\BonjourSDKLike.zip -DestinationPath .\deps\BonjourSDKLike
Remove-Item deps\BonjourSDKLike.zip

# ---- 2. 探测可用的 Visual Studio --------------------------------------------
# 按优先级依次尝试常见安装路径，命中第一个可用的即采用其生成器名（如 "Visual Studio 17 2022"）。
# 这里只覆盖 Enterprise/Community 版；若装的是 BuildTools/Professional，需自行补充路径。
$vs_locations = @(
    @{version='Visual Studio 17 2022';
      path='C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat'},
    @{version='Visual Studio 17 2022';
      path='C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat'},
    @{version='Visual Studio 16 2019';
      path='C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\Tools\VsDevCmd.bat'},
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

# ---- 3. 读取构建参数（构建类型 / Qt 版本 / Qt 路径）--------------------------
# 优先读取环境变量，未设置时使用默认值。
$build_type = 'Release';
if ($env:B_BUILD_TYPE -ne $null) {
    $build_type = $env:B_BUILD_TYPE;
}
$qt_major_version = '6';
if ($env:B_QT_MAJOR_VERSION -ne $null) {
    $qt_major_version = $env:B_QT_MAJOR_VERSION;
}
# 未显式提供 B_QT_ROOT 时，自动探测 C:\Qt\<主版本>* 下的安装目录
$qt_root = (Resolve-Path C:\Qt\$qt_major_version*\* 2>$null).Path;
if ($env:B_QT_ROOT -ne $null) {
    $qt_root = $env:B_QT_ROOT;
} elseif ($qt_root -eq $null) {
    Write-Output "Could not find Qt and B_QT_ROOT is not provided";
    break;
}

Write-Output "Using Qt at $qt_root";

# ---- 4. 清空并重建 build 目录 ----------------------------------------------
if (Test-Path -LiteralPath build) {
    Remove-Item -LiteralPath build -Recurse;
}
New-Item -Force -ItemType Directory -Path .\build | Out-Null
pushd build

# ---- 5. 配置、编译并打包 ----------------------------------------------------
try {
    # 让 CMake 找到 Bonjour SDK 的头文件目录
    $env:BONJOUR_SDK_HOME="$bonjour_path"
    # 生成 Visual Studio 解决方案：生成器、x64 架构、构建类型、Qt 路径与 Bonjour 导入库
    cmake .. -G "$vs_version" -A x64 `
        "-DCMAKE_BUILD_TYPE=$build_type" `
        "-DCMAKE_PREFIX_PATH=$qt_root" `
        "-DQT_DEFAULT_MAJOR_VERSION=$qt_major_version" `
        -DDNSSD_LIB="$bonjour_path\Lib\x64\dnssd.lib" `
        -DCMAKE_INSTALL_PREFIX=input-leap-install

    # 并行编译并执行 install 目标，产物落到 input-leap-install
    cmake --build . --parallel --config $build_type --target install
    # 调用 Inno Setup 编译器（ISCC），依据配置阶段生成的脚本打出安装包
    ISCC /Qp installer-inno\input-leap.iss
} finally {
    popd
}
