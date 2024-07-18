#!/bin/bash 

command=$1
arg1=$2
rootdir=`pwd`
toolchain=$rootdir/toolchain/bin
uboot_src=$rootdir/uboot-2024.01
kernel_src=$rootdir/linux-5.15.4
buildroot=$rootdir/buildroot-2024.02.2

if [ ! -d $rootdir/output ];then
    mkdir $rootdir/output
fi

usage () {
    echo "eg:"
    echo "./build.sh uboot -j4"
    echo "./build.sh kernel -j4"
    echo "./build.sh rootfs -j4"
    echo "./build.sh clean"
}

build_uboot () {
    echo "build_uboot"
    echo "enter $uboot_src"
    cp $uboot_src/configs/sunxi_h6_deconfig $uboot_src/.config
    cd $uboot_src
    # make ARCH=arm CROSS_COMPILE=$toolchain/aarch64-H6-linux-gnu- $arg1
    make ARCH=arm CROSS_COMPILE=$toolchain/aarch64-H6-linux-gnu- SCP=/dev/null BL31=$rootdir/Trust_platform_fw/bl31.bin $arg1
    echo "exit $uboot_src"
    cd $rootdir
    cp $uboot_src/u-boot-sunxi-with-spl.bin ./output/

}

build_kernel () {
    echo "build_kernel"
    echo "enter $kernel_src"
    cp $kernel_src/arch/arm64/configs/sunxi_h6_deconfig $kernel_src/.config
    cd $kernel_src
    make ARCH=arm64  CROSS_COMPILE=$toolchain/aarch64-H6-linux-gnu- $arg1
    # make ARCH=arm64  CROSS_COMPILE=$toolchain/aarch64-H6-linux-gnu- dtbs
    echo "exit $kernel_src"
    cd $rootdir
    cp $kernel_src/arch/arm64/boot/Image ./output/
    cp $kernel_src/arch/arm64/boot/dts/allwinner/sun50i-h6-orangepi-3.dtb ./output/

}

build_rootfs () {
    echo "build_rootfs"
    # echo "enter $buildroot"
    # cp $uboot_src/configs/sunxi_v3s_nand_deconfig uboot-2021.10/.config
    # cd $buildroot
    # make ARCH=arm CROSS_COMPILE=$toolchain/arm-linux- -j
    # echo "exit $buildroot"
    # cd $rootdir

}

build_driver () {
    build_kernel

    if [ ! -d $rootdir/output/ko ];then
        mkdir $rootdir/output/ko
    fi

    find $kernel_src -type f -name "*.ko" -exec cp {} $rootdir/output/ko \;
    echo "build_driver"
}

clean_all () {
    echo "clean uboot"
    cd $uboot_src
    make distclean
    cd $rootdir

    echo "clean kernel"
    cd $kernel_src
    make distclean
    cd $rootdir

    # echo "clean builfroot"
    # cd $buildroot
    # make distclean
    # cd $rootdir
}

case $command in
    (uboot)
        build_uboot
        ;;
    (kernel)
        build_kernel
        ;;
    (rootfs)
        build_rootfs
        ;;
    (driver)
        build_driver
        ;;
    (all)
        build_uboot
        build_kernel
        build_rootfs
        ;;
    (clean)
        clean_all
        ;;
    (*)
        echo "Error command"
        usage
        ;;
esac