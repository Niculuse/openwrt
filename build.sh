#!/usr/bin/env bash

set -e

BASE_PATH=$(cd $(dirname $0) && pwd)

Dev=$1
Build_Mod=$2

CONFIG_FILE="$BASE_PATH/deconfig/$Dev.config"
INI_FILE="$BASE_PATH/compilecfg/$Dev.ini"

if [[ ! -f $CONFIG_FILE ]]; then
    echo "Config not found: $CONFIG_FILE"
    exit 1
fi

if [[ ! -f $INI_FILE ]]; then
    echo "INI file not found: $INI_FILE"
    exit 1
fi

read_ini_by_key() {
    local key=$1
    awk -F"=" -v key="$key" '$1 == key {print $2}' "$INI_FILE"
}

# 移除 uhttpd 依赖
# 当启用luci-app-quickfile插件时，表示启动nginx，所以移除luci对uhttp(luci-light)的依赖
remove_uhttpd_dependency() {
    local config_path="$BASE_PATH/$BUILD_DIR/.config"
    local luci_makefile_path="$BASE_PATH/$BUILD_DIR/feeds/luci/collections/luci/Makefile"

    if grep -q "CONFIG_PACKAGE_luci-app-quickfile=y" "$config_path"; then
        if [ -f "$luci_makefile_path" ]; then
            sed -i '/luci-light/d' "$luci_makefile_path"
            echo "Removed uhttpd (luci-light) dependency as luci-app-quickfile (nginx) is enabled."
        fi
    fi
}

# 应用配置文件
apply_config() {
    # 复制基础配置文件
    \cp -f "$CONFIG_FILE" "$BASE_PATH/$BUILD_DIR/.config"
    
    # 如果是 ipq60xx 或 ipq807x 平台，则追加 NSS 配置
    if grep -qE "(ipq60xx|ipq807x)" "$BASE_PATH/$BUILD_DIR/.config"; then
        cat "$BASE_PATH/deconfig/nss.config" >> "$BASE_PATH/$BUILD_DIR/.config"
    fi

    # 追加代理配置
    cat "$BASE_PATH/deconfig/proxy.config" >> "$BASE_PATH/$BUILD_DIR/.config"
}

REPO_URL=$(read_ini_by_key "REPO_URL")
REPO_BRANCH=$(read_ini_by_key "REPO_BRANCH")
REPO_BRANCH=${REPO_BRANCH:-main}
BUILD_DIR=$(read_ini_by_key "BUILD_DIR")
COMMIT_HASH=$(read_ini_by_key "COMMIT_HASH")
COMMIT_HASH=${COMMIT_HASH:-none}

if [[ -d $BASE_PATH/action_build ]]; then
    BUILD_DIR="action_build"
fi

$BASE_PATH/update.sh "$REPO_URL" "$REPO_BRANCH" "$BASE_PATH/$BUILD_DIR" "$COMMIT_HASH"

apply_config
remove_uhttpd_dependency

cd "$BASE_PATH/$BUILD_DIR"
make defconfig

if grep -qE "^CONFIG_TARGET_x86_64=y" "$CONFIG_FILE"; then
    DISTFEEDS_PATH="$BASE_PATH/$BUILD_DIR/package/emortal/default-settings/files/99-distfeeds.conf"
    if [ -d "${DISTFEEDS_PATH%/*}" ] && [ -f "$DISTFEEDS_PATH" ]; then
        sed -i 's/aarch64_cortex-a53/x86_64/g' "$DISTFEEDS_PATH"
    fi
fi

if [[ $Build_Mod == "debug" ]]; then
    exit 0
fi

TARGET_DIR="$BASE_PATH/$BUILD_DIR/bin/targets"
if [[ -d $TARGET_DIR ]]; then
    find "$TARGET_DIR" -type f \( -name "*.bin" -o -name "*.manifest" -o -name "*efi.img.gz" -o -name "*.itb" -o -name "*.fip" -o -name "*.ubi" -o -name "*rootfs.tar.gz" \) -exec rm -f {} +
fi

sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_VI_UNDO is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_VI_UNDO=y/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_VI_UNDO_QUEUE is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_VI_UNDO_QUEUE=0/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_XARGS_SUPPORT_REPL_STR is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_XARGS_SUPPORT_REPL_STR=y/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_XARGS_SUPPORT_PARALLEL is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_XARGS_SUPPORT_PARALLEL=y/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_XARGS_SUPPORT_ARGS_FILE is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_XARGS_SUPPORT_ARGS_FILE=y/' .config
sed -i 's/# CONFIG_BUSYBOX_CONFIG_FEATURE_XARGS_SUPPORT_REPL_STR is not set/CONFIG_BUSYBOX_CONFIG_FEATURE_XARGS_SUPPORT_REPL_STR=y/' .config
sed -i 's/# CONFIG_BUSYBOX_CONFIG_FEATURE_XARGS_SUPPORT_PARALLEL is not set/CONFIG_BUSYBOX_CONFIG_FEATURE_XARGS_SUPPORT_PARALLEL=y/' .config
sed -i 's/# CONFIG_BUSYBOX_CONFIG_FEATURE_XARGS_SUPPORT_ARGS_FILE is not set/CONFIG_BUSYBOX_CONFIG_FEATURE_XARGS_SUPPORT_ARGS_FILE=y/' .config
sed -i 's/# CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_AMIN is not set/CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_AMIN=y/' .config
sed -i 's/# CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_ATIME is not set/CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_ATIME=y/' .config
sed -i 's/# CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_CMIN is not set/CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_CMIN=y/' .config
sed -i 's/# CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_CTIME is not set/CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_CTIME=y/' .config
sed -i 's/# CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_DELETE is not set/CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_DELETE=y/' .config
sed -i 's/# CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_EMPTY is not set/CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_EMPTY=y/' .config
sed -i 's/# CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_EXECUTABLE is not set/CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_EXECUTABLE=y/' .config
sed -i 's/# CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_EXEC_OK is not set/CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_EXEC_OK=y/' .config
sed -i 's/# CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_EXEC_PLUS is not set/CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_EXEC_PLUS=y/' .config
sed -i 's/# CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_INUM is not set/CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_INUM=y/' .config
sed -i 's/# CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_LINKS is not set/CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_LINKS=y/' .config
sed -i 's/# CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_QUIT is not set/CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_QUIT=y/' .config
sed -i 's/# CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_SAMEFILE is not set/CONFIG_BUSYBOX_CONFIG_FEATURE_FIND_SAMEFILE=y/' .config
sed -i 's/# CONFIG_BUSYBOX_CONFIG_FINDFS is not set/CONFIG_BUSYBOX_CONFIG_FINDFS=y/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_AMIN is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_AMIN=y/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_ATIME is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_ATIME=y/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_CMIN is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_CMIN=y/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_CONTEXT is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_CONTEXT=y/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_CTIME is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_CTIME=y/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_DELETE is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_DELETE=y/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_EMPTY is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_EMPTY=y/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_EXECUTABLE is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_EXECUTABLE=y/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_EXEC_OK is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_EXEC_OK=y/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_EXEC_PLUS is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_EXEC_PLUS=y/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_INUM is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_INUM=y/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_LINKS is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_LINKS=y/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_QUIT is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_QUIT=y/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_SAMEFILE is not set/CONFIG_BUSYBOX_DEFAULT_FEATURE_FIND_SAMEFILE=y/' .config
sed -i 's/# CONFIG_BUSYBOX_DEFAULT_FINDFS is not set/CONFIG_BUSYBOX_DEFAULT_FINDFS=y/' .config

make defconfig


make download -j$(($(nproc) * 2))
make -j$(($(nproc) + 1)) || make -j1 V=s

FIRMWARE_DIR="$BASE_PATH/firmware"
\rm -rf "$FIRMWARE_DIR"
mkdir -p "$FIRMWARE_DIR"
find "$TARGET_DIR" -type f \( -name "*.bin" -o -name "*.manifest" -o -name "*efi.img.gz" -o -name "*.itb" -o -name "*.fip" -o -name "*.ubi" -o -name "*rootfs.tar.gz" \) -exec cp -f {} "$FIRMWARE_DIR/" \;
\rm -f "$BASE_PATH/firmware/Packages.manifest" 2>/dev/null

if [[ -d $BASE_PATH/action_build ]]; then
    make clean
fi
