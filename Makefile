all : everything

DTC:=buildroot/output/host/bin/dtc

buildroot :
	git clone https://github.com/cnlohr/buildroot --recurse-submodules --depth 1

toolchain : buildroot
	cp -a configs/custom_kernel_config buildroot/kernel_config
	cp -a configs/buildroot_config buildroot/.config
	cp -a configs/busybox_config buildroot/busybox_config
	cp -a configs/uclibc_config buildroot/uclibc_config
	cp -a configs/uclibc_config buildroot/uclibc_config_extra
	true || cp -a configs/rootfsoverlay/* buildroot/output/target/
	make -C buildroot

everything : toolchain
	make -C hello_linux deploy
	#make -C packages/duktapetest deploy
	make -C packages/coremark deploy
	cp -a configs/rootfsoverlay/* buildroot/output/target/
	make -C buildroot
	make -C mini-rv32ima testkern

testdlimage :
	make -C mini-rv32ima testdlimage

testbare :
	make -C baremetal
	make -C mini-rv32ima testbare

test_with_qemu :
	cd buildroot && output/host/bin/qemu-system-riscv32 -cpu rv32,mmu=false -m 128M -machine virt -nographic -kernel output/images/Image -bios none #-machine dtb=../minimal.dtb 


##################################################################
# For Debugging 
####

# SBI doesn't work for some reason?
#opensbi_firmware : 
#	make -C opensbi PLATFORM=../../packages/this_opensbi/platform/riscv_emufun I=../packages/this_opensbi/install B=../packages/this_opensbi/build CROSS_COMPILE=riscv64-unknown-elf- PLATFORM_RISCV_ISA=rv32ima PLATFORM_RISCV_XLEN=32
#	# ./mini-rv32ima -i ../opensbi/this_opensbi/platform/riscv_emufun/firmware/fw_payload.bin
#	# ../buildroot/output/host/bin/riscv32-buildroot-linux-uclibc-objdump -S ../opensbi/this_opensbi/platform/riscv_emufun/firmware/fw_payload.elf > fw_payload.S

#toolchain_buildrootb : buildroot-2022.02.6
#	cp buildroot-2022.02.6-config buildroot-2022.02.6/.config
#	cp -a custom_kernel_config buildroot-2022.02.6/kernel_config
#	cp riscv_Kconfig buildroot-2022.02.6/output/build/linux-5.15.67/arch/riscv/
#	make -C buildroot-2022.02.6

configs/minimal.dtb : configs/minimal.dts $(DTC)
	$(DTC) -I dts -O dtb -o $@ $< -S 2048

# Trick for extracting the DTB from 
dtbextract : $(DTC)
	# Need 	sudo apt  install device-tree-compiler
	cd buildroot && output/host/bin/qemu-system-riscv32 -cpu rv32,mmu=false -m 128M -machine virt -nographic -kernel output/images/Image -bios none -drive file=output/images/rootfs.ext2,format=raw,id=hd0 -device virtio-blk-device,drive=hd0 -machine dumpdtb=../dtb.dtb && cd ..
	$(DTC) -I dtb -O dts -o dtb.dts dtb.dtb

tests :
	git clone https://github.com/riscv-software-src/riscv-tests
	./configure --prefix=
