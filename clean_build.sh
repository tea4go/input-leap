#!/bin/sh
# InputLeap 构建脚本（仅命令行程序，不含 Qt 界面）
#
# 构建产物：input-leapc（客户端）、input-leaps（服务端）
# 通过 INPUTLEAP_BUILD_GUI=OFF 关闭 Qt 界面，因此不需要 Qt / avahi；
# 通过 INPUTLEAP_BUILD_TESTS=OFF 关闭单元测试，因此不需要 ext/ 下的子模块。
#
# 可用环境变量：
#   B_CMAKE        指定 cmake 可执行文件
#   B_BUILD_DIR    构建目录，默认 build
#   B_BUILD_TYPE   构建类型，默认 Debug
#   B_CMAKE_FLAGS  附加的 CMake 参数

cd "$(dirname "$0")" || exit 1

# some environments have cmake v2 as 'cmake' and v3 as 'cmake3'
# check for cmake3 first then fallback to just cmake
[ -n "$B_CMAKE" ] || B_CMAKE=$(command -v cmake3)
[ -n "$B_CMAKE" ] || B_CMAKE=$(command -v cmake)
if [ -z "$B_CMAKE" ]; then
    echo "ERROR: CMake not in $PATH, cannot build! Please install CMake, or if this persists, file a bug report."
    exit 1
fi

B_BUILD_DIR="${B_BUILD_DIR:-build}"
B_BUILD_TYPE="${B_BUILD_TYPE:-Debug}"
# 仅构建命令行程序：关闭 GUI（省去 Qt/avahi 依赖）与单元测试（省去 ext/ 子模块）
B_CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=${B_BUILD_TYPE} -DINPUTLEAP_BUILD_GUI=OFF -DINPUTLEAP_BUILD_TESTS=OFF ${B_CMAKE_FLAGS:-}"

if [ "$(uname)" = "Darwin" ]; then
    # macOS needs a little help, so we source this environment script to fix paths.
    [ -e ./macos_environment.sh ] && . ./macos_environment.sh
    B_CMAKE_FLAGS="${B_CMAKE_FLAGS} -DCMAKE_OSX_SYSROOT=$(xcrun --sdk macosx --show-sdk-path) -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9"
fi

# Prefer ninja if available
if command -v ninja 2>/dev/null; then
    B_CMAKE_FLAGS="-GNinja ${B_CMAKE_FLAGS}"
fi

# allow local customizations to build environment
[ -r ./build_env.sh ] && . ./build_env.sh

set -e

rm -rf ${B_BUILD_DIR}
mkdir ${B_BUILD_DIR}
cd ${B_BUILD_DIR}
echo "Starting Input Leap $B_BUILD_TYPE build in '${B_BUILD_DIR}'..."
"$B_CMAKE" $B_CMAKE_FLAGS ..
"$B_CMAKE" --build . --parallel
echo "Build completed successfully"
