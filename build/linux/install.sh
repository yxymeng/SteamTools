#!/bin/bash
base_path="$HOME/WattToolkit"
mkdir -p "$base_path"
cd "$base_path" || exit 1
appVer_path="$base_path/WattToolkit.AppVer"
exec_name="Steam++"
tar_name="WattToolkit.tgz"
tar_path="$base_path/$tar_name"
base_url="https://steampp.mossimo.net:8800"
architecture=1
app_name="Watt Toolkit"
PROCESS_NAMES=("$exec_name" "$app_name")
Install_certutil() {
    # 判断发行版类型
    if command -v certutil &>/dev/null; then
        echo "certutil 工具已安装。"
    else
        echo "证书导入以及验证需要使用 certutil 工具。"
        # 判断包管理器
        if command -v apt &>/dev/null; then
            # 使用 apt (Debian/Ubuntu)
            sudo apt update
            sudo apt install -y libnss3-tools
        elif command -v dnf &>/dev/null; then
            # 使用 dnf (Fedora)
            sudo dnf install -y nss-tools
        elif command -v yum &>/dev/null; then
            # 使用 yum (CentOS/Red Hat)
            sudo yum install -y nss-tools
        elif command -v pacman &>/dev/null; then
            # 使用 pacman (Arch Linux)
            # sudo pacman -S nss
            echo "请手动安装 certutil 工具。"
            exit 1
        else
            echo "请手动安装 certutil 工具。"
            exit 1
        fi
        echo "certutil 工具已安装。"
    fi
}

Show_Run() {
    local param1=$1
    # 显示提示框，询问是否运行程序
    zenity --question --text="$1" --width=400

    # 获取上一个命令的退出码
    response=$?

    if [ $response -eq 0 ]; then
        # 用户点击了 "运行" 按钮，启动程序
        /bin/sh -c "$base_path/$exec_name"
        echo "程序已启动。"
    else
        # 用户点击了 "关闭" 按钮，退出脚本
        exit 0
    fi
}
Get_NewVer() {
    #获取系统架构
    arch=$(uname -m)
    case $arch in
    x86_64)
        architecture=1
        ;;
    i?86)
        architecture=0
        ;;
    arm*)
        architecture=2
        ;;
    aarch64)
        architecture=3
        ;;
    *)
        zenity --info --text="未知的设备架构:$arch!" --width=300
        exit 500
        ;;
    esac

    # 获取发行版信息
    read -r os_version <<<"$(cat /etc/os-release | grep -E 'VERSION=' | awk -F'=' '{ print $2 }' | tr -d '"')"

    # 如果 VERSION 为空，则使用 BUILD_ID 填充
    if [ -z "$os_version" ]; then
        os_version=$(cat /etc/os-release | grep -E 'BUILD_ID=' | awk -F'=' '{ print $2 }' | tr -d '"')
    fi

    # 分割版本号
    IFS='.' read -ra version_parts <<<"$os_version"

    # 提取主版本号和次版本号
    major_version=${version_parts[0]}
    minor_version=${version_parts[1]}
    if [ -z "$minor_version" ]; then
        minor_version=0
    fi
    # 通过 SHA384 文件来判断是否需要更新
    wget "$base_url/basic/versions/8/16/$architecture/$major_version/$minor_version/-1/0/" -O "$appVer_path" 2>&1
    n_sha384=$(jq -r '.["\uD83E\uDD93"].Downloads[0].SHA384' "$appVer_path")

    downloads_url=$(jq -r '.["\uD83E\uDD93"].Downloads[0].DownloadUrl' "$appVer_path")

    # 检查 SHA384 值是否为空
    if [ "$n_sha384" = "" ]; then
        zenity --info --text="未知的最新版本 Hash:$n_sha384!" --width=300
        exit 500
    fi

    sleep 1
    #本地版本 Hash
    o_sha384=$(cat "AppVer")
    if [ -e "AppVer" ]; then
        if [ "${o_sha384,,}" = "${n_sha384,,}" ]; then
            Show_Run "已是最新版本，是否启动程序？"
        fi
    fi
}

Download_File() {
    # 删除旧的文件
    rm -rf $tar_path
    title="安装"
    # 检查 o_sha384 是否为空
    if [ -z "$o_sha384" ]; then
        title="安装"
    else
        title="更新"
    fi
    for i in {1..3}; do
        #下载文件到目标目录
        wget "$downloads_url" -O "$tar_path" 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# 下载中 \2\/s, 剩余时间： \3/' | zenity --progress --title="$title Watt Toolkit" --auto-close --width=500

        RUNNING=0
        while [ $RUNNING -eq 0 ]; do
            if [ -z "$(pidof zenity)" ]; then
                pkill wget
                RUNNING=1
            fi
            sleep 0.1
        done

        sleep 1
        # 校验下载文件 Hash
        actual_hash=$(sha384sum "$tar_name" | awk '{ print $1 }')
        if [ "${actual_hash,,}" = "${n_sha384,,}" ]; then
            rm "AppVer"
            echo "${actual_hash,,}" >>"$base_path/AppVer"
            break 2
        fi

        if [ "$i" -ge "3" ]; then
            zenity --error --text="下载错误。" --width=500
            exit 1
        fi
    done
}

Kill_Process() {
    # 尝试的次数
    MAX_RETRIES=3

    # 循环尝试终止进程
    for process_name in "${PROCESS_NAMES[@]}"; do
        retry=1
        while [ $retry -le $MAX_RETRIES ]; do
            pid=$(pgrep "$process_name")
            if [ -n "$pid" ]; then
                echo "尝试 $retry: 进程 $process_name 正在运行中。正在终止..."
                kill $pid
                sleep 2
            else
                break
            fi
            retry=$((retry + 1))
        done
    done

    for process_name in "${PROCESS_NAMES[@]}"; do
        # 检查是否成功终止进程
        if pgrep -x "$process_name" >/dev/null; then
            echo "无法终止程序 $process_name。尝试次数已达上限。"
            exit 1
        else
            echo "程序 $process_name 已成功终止。"
        fi
    done

}

Decompression() {
    echo "开始解压更新。"

    # 使用 zenity 显示进度条对话框，并将解压命令输出重定向到文件
    tar -xzvf "$tar_name" 2>&1 |
        zenity --progress \
            --title="安装中" \
            --text="正在解压 $tar_name..." \
            --percentage=20 \
            --auto-close \
            --width=500

    chmod +x "$exec_name"
    # 删除本地版本缓存
    rm -f "$appVer_path" &>/dev/null
}


#先安装依赖;
Install_certutil
# SteamDeck 可能出现升级系统 语言被重置成 c
echo "如果出现 类似 \"Using the fallback 'C Locale.\" 的提示,请手动执行 export LC_ALL=en_US.UTF-8"
#版本检查更新;
Get_NewVer

# 使用条件判断来检查文件是否存在
if [ -f "$tar_path" ]; then
    #如果本地存在文件与新版本计算 Hash 避免重复下载;
    temp_hash=$(sha384sum "$tar_path" | awk '{ print $1 }')
    if [ "${temp_hash,,}" != "${n_sha384,,}" ]; then
        #下载文件
        Download_File
    else
        #版本号是最新缓存 输出到文件
        echo "${temp_hash,,}" >>"$base_path/AppVer"
        zenity --question --text="本地已有最新安装包是否继续解压?" --width=400

        # 获取上一个命令的退出码
        response=$?

        if [ $response -eq 0 ]; then
            echo "继续解压"
        else
            # 用户点击了 "关闭" 按钮，退出脚本
            exit 0
        fi
    fi
else
    #下载文件
    Download_File
fi
#解压前尝试杀死旧版本进程
Kill_Process
#解压
Decompression
# xdg-icon-resource install "$base_path/Icons/Watt-Toolkit.png" --size 128 Watt-Toolkit
#添加桌面文件
rm -rf "$HOME/Desktop/Watt Toolkit.desktop" 2>/dev/null
echo "#!/usr/bin/env xdg-open
[Desktop Entry]
Name=Watt Toolkit
Exec=$base_path/$exec_name
Icon=$base_path/Icons/Watt-Toolkit.png
Terminal=false
Type=Application
StartupNotify=false" >"$HOME/Desktop/Watt Toolkit.desktop"
chmod +x "$HOME/Desktop/Watt Toolkit.desktop"
# update-desktop-database ~/.local/share/applications
#运行程序
Show_Run "下载安装完成，是否启动程序？"
