#/bin/bash

log() {	echo -e "\e[32m$1 \e[0m"; }
warn() { echo -e "\e[31m$1 \e[0m"; }

warn "------------------编译内核以及openwrt脚本------------------"
# pre.下载工具
log "------------------下载工具------------------"
apt update -y
apt full-upgrade -y
apt install -y ack antlr3 aria2 asciidoc autoconf automake autopoint binutils bison build-essential \
bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib \
git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev \
libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libreadline-dev libssl-dev libtool lrzsz \
mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 python3-pip libpython3-dev qemu-utils \
rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev \
gcc-aarch64-linux-gnu ncurses-dev qemu u-boot-tools
# 安装qemu
log "安装qemu"
if [ ! -e qemu-aarch64-static.tar.gz ]; then
  wget https://github.com/multiarch/qemu-user-static/releases/download/v5.1.0-5/qemu-aarch64-static.tar.gz
fi
tar xzvf qemu-aarch64-static.tar.gz
cp qemu-aarch64-static /usr/bin/
chmod +x /usr/bin/qemu-aarch64-static
#安装gcc-aarch64-linux-gnu
log "安装gcc-aarch64-linux-gnu"
if [ ! -e gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz ]; then
  wget https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
fi
tar -xf gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
cp gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/* /usr/bin/
chmod +x /usr/bin/aarch64-linux-gnu-*

# 1.下载环境
log "------------------下载环境开始------------------"
if [ ! -d linux-6.0.y ]; then
  git clone https://ghproxy.com/https://github.com/unifreq/linux-6.0.y.git
else
  cd linux-6.0.y
  git pull
  cd ..
fi

if [ ! -d arm64-kernel-configs ]; then
  git clone https://ghproxy.com/https://github.com/unifreq/arm64-kernel-configs.git
else
  cd arm64-kernel-configs
  git pull
  cd ..
fi

if [ ! -d openwrt_packit ]; then
  git clone https://ghproxy.com/https://github.com/unifreq/openwrt_packit.git
else
  cd openwrt_packit
  git pull
  cd ..
fi

if [ ! -d openwrt ]; then
  git clone https://ghproxy.com/https://github.com/openwrt/openwrt.git
else
  cd openwrt
  git pull
  cd ..
fi

if [ ! -d lede ]; then
  git clone https://ghproxy.com/https://github.com/coolsnowwolf/lede.git
else
  cd lede
  git pull
  cd ..
fi

if [ ! -e ubuntu-base-22.04-base-arm64.tar.gz ]; then
  wget https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-arm64.tar.gz
fi


# 2.编译内核
log "------------------编译内核开始------------------"
cd linux-6.0.y/
cp ../arm64-kernel-configs/config-6.0.2-flippy-78+  ./.config
#make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- menuconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- prepare
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j12


# 3.编译生成需要的根文件系统
log "------------------编译生成需要的根文件系统------------------"
mkdir modules
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=modules modules_install
#后续使用的modules版本在此处决定
module=`ls modules/lib/modules`
mkdir rootfs
cd rootfs
cp ../../ubuntu-base-22.04-base-arm64.tar.gz  ./
tar -xf ubuntu-base-22.04-base-arm64.tar.gz
rm -f ubuntu-base-22.04-base-arm64.tar.gz
cd ..
mkdir rootfs/lib/modules
cp -a modules/lib/modules/${module} rootfs/lib/modules/
mkdir rootfs/host
cp /usr/bin/qemu-aarch64-static rootfs/usr/bin/
######################################
# 进入子系统部分
log "进入子系统"
warn "以下命令请手动执行...."
exit
chmod +x .././chmout.sh
bash ../chmout.sh -m ./rootfs/
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
bash ../chmout.sh -u ./rootfs/
######################################
# 打包根文件系统 boot,header,modules,dtb
log "打包根文件系统 boot,header,modules,dtb"
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


# 4.编译openwrt根文件系统
log "------------------openwrt根文件系统------------------"
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
#二次编译：
# cd lede
# git pull
# ./scripts/feeds update -a
# ./scripts/feeds install -a
# make defconfig
# make download -j8
# export FORCE_UNSAFE_CONFIGURE=1
# make V=s -j$(nproc)
#如果需要重新配置：
# rm -rf ./tmp && rm -rf .config
# make menuconfig
# export FORCE_UNSAFE_CONFIGURE=1
# make V=s -j$(nproc)


# 5.开始编译openwrt
#编译前需要修改配置文件
# sudo cp -a openwrt_packit /opt/openwrt_packit
# sudo cp lede/bin/targets/armvirt/64/openwrt-armvirt-64-default-rootfs.tar.gz /opt/openwrt_packit/
# sudo mkdir /opt/kernel
# sudo cp linux-6.0.y/output/dtb-allwinner-6.0.3-flippy-78+.tar.gz /opt/kernel/
#注意，这一步的dtb-allwinner-6.0.3-flippy-78+.tar.gz是准备工作中生成的
# sudo cp linux-6.0.y/output/boot-6.0.3-flippy-78+.tar.gz /opt/kernel/
# sudo cp linux-6.0.y/output/header-6.0.3-flippy-78+.tar.gz /opt/kernel/
# sudo cp linux-6.0.y/output/modules-6.0.3-flippy-78+.tar.gz /opt/kernel/
# cd /opt/openwrt_packit/
# sudo cp mk_h6_vplus.sh mk_orangepi3lts.sh
# sudo ./mk_orangepi3lts.sh
#执行完就生成了可用的openwrt镜像


# sudo vim mk_orangepi3lts.sh
  # BOARD=orangepi3lts
  # FDT=/dtb/allwinner/sun50i-h6-orangepi-3-lts.dtb
# sudo vim make.env
  # KERNEL_VERSION="${module}"

# 如果出现tar报错误，修改public_funcs文件，添加--no-same-owner参数
# vim public_funcs
  # function extract_allwinner_boot_files() {
    # echo -n "释放 Kernel zImage、uInitrd 及 dtbs 压缩包 ... "
    # (
        # cd ${TGT_BOOT} && \
            # cp "${BOOTFILES_HOME}"/* . && \
            # tar xzf  "${BOOT_TGZ}" --no-same-owner && \
            # rm -f initrd.img-${KERNEL_VERSION} && \
            # cp vmlinuz-${KERNEL_VERSION} zImage && \
            # cp uInitrd-${KERNEL_VERSION} uInitrd && \
            # mkdir -p dtb/allwinner && \
            # cd dtb/allwinner && \
            # tar xzf "${DTBS_TGZ}" && \
            # sync
    # )
    # if [ $? -ne 0 ];then
        # echo "失败！"
        # detach_loopdev
        # exit 1
    # else
        # echo "完成"
    # fi
# }

