#!/usr/bin/env bash

show_help() {
  echo "usage: $0 [--enviroment | --kernel 1 | 2 | 3 | 4 ]"
  echo '  -e, --enviroment  下载环境'
  echo '  -k, --kernel      编译kernel'
  echo '  -o, --openwrt     编译openwrt'
  exit 0
}

judgment_parameters() {
  [[ "$#" -eq '0' ]] && show_help
  while [[ "$#" -gt '0' ]]; do
    case "$1" in
      '-h' | '--help')
        show_help
        ;;
      '-e' | '--enviroment')
        enviroment='1'
        ;;
      '-o' | '--openwrt')
        openwrt='1'
        ;;
      '-k' | '--kernel')
        kernel='1'
        if [[ -z "${2:?error: Please specify thecomplie kernel part.}" ]]; then
          exit 1
        fi
        kernel_PART="$2"
        shift
        ;;
      *)
        echo "$0: unknown option -- -"
        exit 1
        ;;
    esac
    shift
  done
}

check_if_running_as_root() {
   if [[ "$UID" -ne '0' ]]; then
     echo "${red}当前非root用户,建议使用root用户执行${reset}"
     read -r -p "${red}是否使用非root用户进编译? [y/n] ${reset}" cont_without_been_root
     if [[ x"${cont_without_been_root:0:1}" = x'y' ]]; then
       echo "继续编译..."
      else
        echo "请使用root用户进行编译..."
        exit 1
      fi
    fi
}


complie_openwrt() {
    # 4.编译openwrt根文件系统
    echo "${red}------------------编译openwrt根文件系统开始------------------${reset}"
    cd ../lede/
    export FORCE_UNSAFE_CONFIGURE=1
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    #此处需要手动配置
    #make -j1  V=s menuconfig
    make -j1  V=s defconfig
    make -j8  V=s download
    make -j1  V=s
    cd ../
    echo "${red}------------------编译openwrt根文件系统结束------------------${reset}"
}

######################################
# 编译 kernel
complie_kernel() {
    echo "${red}------------------编译kernel内核开始------------------${reset}"
    echo "${green}编译kernel内核第 $1 部分${reset}"
    case "$1" in
      '1')
        complie_kernel_1
        ;;
      '2')
        complie_kernel_2
        ;;
      '3')
        complie_kernel_3
        ;;
      '4')
        complie_kernel_4
        ;;
    esac
    echo "${red}------------------编译kernel内核结束------------------${reset}"
}

######################################
# 编译 kernel内核
complie_kernel_1() {
    echo "${green}开始编译kernel内核${reset}"
    cd linux-6.0.y/
    cp ../arm64-kernel-configs/config-6.0.2-flippy-78+  ./.config
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- prepare
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
}

######################################
# 编译 kernel 根文件系统
complie_kernel_2() {
    echo "${green}开始编译kernel根文件系统${reset}"
    cd linux-6.0.y/
	mkdir -p modules
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=modules modules_install
    #后续使用的modules版本在此处决定
    module=`ls modules/lib/modules`
    mkdir -p rootfs
    cd rootfs
    cp ../../ubuntu-base-22.04-base-arm64.tar.gz  ./
    tar -xf ubuntu-base-22.04-base-arm64.tar.gz
    rm -f ubuntu-base-22.04-base-arm64.tar.gz
    cd ..
    mkdir -p rootfs/lib/modules
    cp -a modules/lib/modules/${module} rootfs/lib/modules/
    mkdir -p rootfs/host
    cp /usr/bin/qemu-aarch64-static rootfs/usr/bin/
    # 进入子系统部分
    echo "${red}进入子系统${reset}"
    echo "${red}以下命令请手动执行....${reset}"
	chmod +x .././chmout.sh
    bash ../chmout.sh -m ./rootfs/
}

######################################
# 编译 kernel boot
complie_kernel_3() {
    echo "${green}开始编译kernel boot${reset}"
    cd linux-6.0.y/
    echo "185.125.190.36 ports.ubuntu.com">/etc/hosts
    chmod 777 /tmp
    apt update -y
    apt install u-boot-tools -y
    apt install ifupdown net-tools -y
    apt install udev -y
    apt install initramfs-tools -y
    apt install vim -y
    apt install xz-utils -y
    module=`ls /lib/modules`
    mkinitramfs -k -c xz -o /boot/initrd.img-${module} ${module}
    mkimage -A arm64 -O linux -T ramdisk -C none -a 0 -e 0 -n uInitrd -d /boot/initrd.img-${module} /boot/uInitrd-${module}
    exit
}

######################################
# 打包根文件系统 boot,header,modules,dtb
complie_kernel_4() {
    echo "${green}打包根文件系统 boot,header,modules,dtb${reset}"
    cd linux-6.0.y/
	bash ../chmout.sh -u ./rootfs/
    mkdir -p output/{boot,header,modules,dtb}
    cp -a rootfs/lib/modules/${module} output/modules
    cp -a rootfs/boot/{initrd.img-${module},uInitrd-${module}} output/boot/
    bash arch/arm64/boot/install.sh ${module} arch/arm64/boot/Image.gz System.map output/boot/
    cp .config output/boot/config-${module}
    cd output/boot/
    tar -zcf ../boot-${module}.tar.gz *
    cd ../modules/
    tar -zcf ../modules-${module}.tar.gz *
    cd ../../
    mkdir -p output/header/arch/arm64/
    cp -a arch/arm64/include/ output/header/arch/arm64/include/
    cp -a arch/arm64/kvm/ output/header/arch/arm64/kvm/
    cp -a arch/arm64/Makefile output/header/arch/arm64/
    cp -a include/ output/header/include/
    cp -a scripts/ output/header/scripts/
    cp -a .config output/header/
    cp -a Makefile output/header/
    cp -a Module.symvers output/header/
    cd output/header/
    tar -zcf ../header-${module}.tar.gz *
    cd ../../
}

######################################
# 下载环境
get_enviroment() {
    echo "${red}------------------下载环境开始------------------${reset}"
    
    echo "${green}开始下载必要软件包${reset}"
    apt update -y
    apt upgrade -y
    apt install -y ack antlr3 aria2 asciidoc autoconf automake autopoint binutils bison build-essential \
    bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib \
    git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev \
    libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libreadline-dev libssl-dev libtool lrzsz \
    mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 python3-pip libpython3-dev qemu-utils \
    rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev
    apt install -y ncurses-dev qemu u-boot-tools gcc-aarch64-linux-gnu
    
	echo "${green}开始拉取GitHub仓库${reset}"
    github 'arm64-kernel-configs' 'https://ghproxy.com/https://github.com/unifreq/arm64-kernel-configs.git'
    github 'linux-6.0.y' 'https://ghproxy.com/https://github.com/unifreq/linux-6.0.y.git'
    github 'lede' 'https://ghproxy.com/https://github.com/coolsnowwolf/lede.git'
    github 'openwrt' 'https://ghproxy.com/https://github.com/openwrt/openwrt.git'
    github 'openwrt_packit' 'https://ghproxy.com/https://github.com/unifreq/openwrt_packit.git'

    echo "${green}开始下载编译工具${reset}"
    download 'ubuntu-base-22.04-base-arm64.tar.gz' 'https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-arm64.tar.gz'
    download 'qemu-aarch64-static.tar.gz' 'https://github.com/multiarch/qemu-user-static/releases/download/v5.1.0-5/qemu-aarch64-static.tar.gz'
    download 'gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz' 'https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz'
    
	exit
    echo "${green}解压软件包${reset}"
    tar xzvf qemu-aarch64-static.tar.gz -C .
    cp qemu-aarch64-static rootfs/usr/bin/
    chmod +x rootfs/usr/bin/qemu-aarch64-static

    tar -xf gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz -C .
    cp gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/* /usr/bin/
    chmod +x /usr/bin/aarch64-linux-gnu-*
	
	
    echo "${red}------------------下载环境结束------------------${reset}"
}

github() {
    if [ ! -d $1 ]; then
      echo "${green}拉取$1...${reset}"
      git clone $2
    else
      echo "${green}更新$1...${reset}"
      cd $1 && git pull
	  cd ..
    fi
}

download() {
    if [ ! -e $1 ]; then
      echo "${green}下载$1...${reset}"
      wget $2 -o $1
    else
      echo "${green}$1已经存在${reset}"
	fi
}

main() {

  red=$(tput setaf 1)
  green=$(tput setaf 2)
  aoi=$(tput setaf 6)
  reset=$(tput sgr0)
  #TMP_DIRECTORY="$(mktemp -d)/temp"
  TMP_DIRECTORY="/tmp/openwrt"
  mkdir -p $TMP_DIRECTORY


  echo "${red}------------------编译内核以及openwrt脚本------------------${reset}"
  
  check_if_running_as_root
  judgment_parameters "$@"
  
  [[ "$enviroment" -eq '1' ]] && get_enviroment
  [[ "$kernel" -eq '1' ]] && complie_kernel $kernel_PART
  [[ "$openwrt" -eq '1' ]] && complie_openwrt

}

main "$@"
