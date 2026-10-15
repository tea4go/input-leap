#!/bin/sh
# InputLeap 构建脚本（仅命令行程序，不含 Qt 界面）
#
# 构建产物：input-leapc（客户端）、input-leaps（服务端）
# 通过 INPUTLEAP_BUILD_GUI=OFF 关闭 Qt 界面，因此不需要 Qt / avahi；
# 通过 INPUTLEAP_BUILD_TESTS=OFF 关闭单元测试，因此不需要 ext/ 下的子模块。
# 构建完成后安装到仓库根的 bin/linux：
#   bin/linux/bin/    可执行文件（input-leapc、input-leaps）
#   bin/linux/share/  man 手册、desktop、metainfo、图标
#
# 用法：
#   ./clean_build.sh            清理并构建
#   ./clean_build.sh --clean    只清理 build 目录，不构建
#   ./clean_build.sh --help     显示本帮助
#
# 可用环境变量：
#   B_CMAKE        指定 cmake 可执行文件
#   B_BUILD_DIR    构建目录，默认 build
#   B_BUILD_TYPE   构建类型，默认 Debug
#   B_CMAKE_FLAGS  附加的 CMake 参数

cd "$(dirname "$0")" || exit 1
B_ROOT=$(pwd)                 # 仓库根 = 脚本所在目录

usage() {
    cat <<'USAGE_EOF'
InputLeap 构建脚本（仅命令行程序，不含 Qt 界面）

用法:
  ./clean_build.sh            清理并构建，并安装到 bin/linux
  ./clean_build.sh --clean    只清理 build 目录，不构建
  ./clean_build.sh --help     显示本帮助

环境变量:
  B_CMAKE        指定 cmake 可执行文件
  B_BUILD_DIR    构建目录，默认 build
  B_BUILD_TYPE   构建类型，默认 Debug
  B_CMAKE_FLAGS  附加的 CMake 参数
USAGE_EOF
}

# allow local customizations to build environment
[ -r ./build_env.sh ] && . ./build_env.sh

B_BUILD_DIR="${B_BUILD_DIR:-build}"
B_BUILD_TYPE="${B_BUILD_TYPE:-Debug}"
B_INSTALL_DIR="${B_ROOT}/bin/linux"

# ---- 提前退出：--help 显示帮助、--clean 只清理不构建 --------------------------
# 放在最前，这样即使没装 CMake 也能使用。
B_CLEAN=
B_HELP=
for arg in "$@"; do
    case "$arg" in
        --clean) B_CLEAN=1 ;;
        --help)  B_HELP=1 ;;
        *) echo "ERROR: unknown argument: '$arg' (use --help for usage)"; exit 1 ;;
    esac
done

if [ -n "$B_HELP" ]; then
    usage
    exit 0
fi

if [ -n "$B_CLEAN" ]; then
    if [ -d "$B_BUILD_DIR" ]; then
        rm -rf "$B_BUILD_DIR"
        echo "Cleaned: $B_BUILD_DIR"
    else
        echo "Nothing to clean: $B_BUILD_DIR not found"
    fi
    exit 0
fi

# some environments have cmake v2 as 'cmake' and v3 as 'cmake3'
# check for cmake3 first then fallback to just cmake
[ -n "$B_CMAKE" ] || B_CMAKE=$(command -v cmake3)
[ -n "$B_CMAKE" ] || B_CMAKE=$(command -v cmake)
if [ -z "$B_CMAKE" ]; then
    echo "ERROR: CMake not in $PATH, cannot build! Please install CMake, or if this persists, file a bug report."
    exit 1
fi

# 仅构建命令行程序：关闭 GUI（省去 Qt/avahi 依赖）与单元测试（省去 ext/ 子模块）
# 安装前缀指向仓库根的 bin/linux，与既有布局（bin/linux/bin、bin/linux/share）一致
B_CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=${B_BUILD_TYPE} -DINPUTLEAP_BUILD_GUI=OFF -DINPUTLEAP_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=${B_INSTALL_DIR} ${B_CMAKE_FLAGS:-}"

if [ "$(uname)" = "Darwin" ]; then
    # macOS needs a little help, so we source this environment script to fix paths.
    [ -e ./macos_environment.sh ] && . ./macos_environment.sh
    B_CMAKE_FLAGS="${B_CMAKE_FLAGS} -DCMAKE_OSX_SYSROOT=$(xcrun --sdk macosx --show-sdk-path) -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9"
fi

# Prefer ninja if available
if command -v ninja 2>/dev/null; then
    B_CMAKE_FLAGS="-GNinja ${B_CMAKE_FLAGS}"
fi

set -e

rm -rf ${B_BUILD_DIR}
mkdir ${B_BUILD_DIR}
cd ${B_BUILD_DIR}
echo "Starting Input Leap $B_BUILD_TYPE build in '${B_BUILD_DIR}'..."
"$B_CMAKE" $B_CMAKE_FLAGS ..
"$B_CMAKE" --build . --parallel
echo "Installing to ${B_INSTALL_DIR} ..."
"$B_CMAKE" --install .
echo "Build completed successfully"
