#!/bin/bash
set -eu

#CONFIG=exynos5433-base_defconfig
CONFIG=exynos5433-trelte_defconfig

MAKE_ARGS=(ARCH=arm)
# CROSS_COMPILE="$HOME"/work/extern/android/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.7/bin/arm-eabi-

MAKE_THREADS=$(($(nproc)*5))

BOOT=/home/vladimir/work/extern/android/my/boot

do_configure() {
	make "${MAKE_ARGS[@]}" $CONFIG
}

do_build() {
	make "${MAKE_ARGS[@]}" -j$MAKE_THREADS
}

# do_tar() {
# 	cd arch/arm/boot
# 	tar cvf SM-N910C_EUR_LL_XX.tar zImage
# }

mkbootimg_zimage() {
	# mkbootimg \
	# 	--kernel "$1" \
	# 	--ramdisk $BOOT/boot.img-ramdisk.gz \
	# 	--base "$(cat $BOOT/boot.img-base)" \
	# 	--output $BOOT/boot.img

	/home/vladimir/work/extern/android/my/boot/patcher/patch_bootimg \
		$BOOT/boot-old.img \
		$BOOT/boot.img \
		--kernel "$1"

	# stat $BOOT/boot.img
}

do_bootimg_old() {
	mkbootimg_zimage /home/vladimir/tmp/2016-05-19/boot.img-zImage
}

do_bootimg() {
	mkbootimg_zimage arch/arm/boot/zImage
}

flash_bootimg() {
	heimdall flash --BOOT "$1" --verbose
}

do_flash() {
	flash_bootimg $BOOT/boot.img
}

do_flash_old() {
	flash_bootimg $BOOT/boot-old.img
}

for ACTION in "$@"
do
	do_"$ACTION"
done

if [ "$#" -eq 0 ]
then
	do_configure
	do_build
	do_bootimg
	do_flash
fi
