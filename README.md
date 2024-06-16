# riscv_emufun (mini-rv32ima)

Click below for the YouTube video introducing this project:

[![Writing a Really Tiny RISC-V Emulator](https://img.youtube.com/vi/YT5vB3UqU_E/0.jpg)](https://www.youtube.com/watch?v=YT5vB3UqU_E) [![But Will It Run Doom?](https://img.youtube.com/vi/uZMNK17VCMU/0.jpg)](https://www.youtube.com/watch?v=uZMNK17VCMU) 

## What

mini-rv32ima is a single-file-header, [mini-rv32ima.h](https://github.com/cnlohr/riscv_emufun/blob/master/mini-rv32ima/mini-rv32ima.h), in the [STB Style library](https://github.com/nothings/stb) that:
 * Implements a RISC-V **rv32ima/Zifencei?+Zicsr** (and partial su), with CLINT and MMIO.
 * Is about **400 lines** of actual code.
 * Has **no dependencies**, not even libc.
 * Is **easily extensible**.  So you can easily add CSRs, instructions, MMIO, etc!
 * Is pretty **performant**. (~450 coremark on my laptop, about 1/2 the speed of QEMU)
 * Is human-readable and in **basic C** code.
 * Is "**incomplete**" in that it didn't implement the tons of the spec that Linux doesn't (and you shouldn't) use.
 * Is trivially **embeddable** in applications.

It has a [demo wrapper](https://github.com/cnlohr/riscv_emufun/blob/master/mini-rv32ima/mini-rv32ima.c) that:
 * Implements a CLI, SYSCON, UART, DTB and Kernel image loading.
 * And it only around **250 lines** of code, itself.
 * Compiles down to a **~18kB executable** and only relies on libc.

?: Zifence+RV32A are stubbed.  So, tweaks will need to be made if you want to emulate a multiprocessor system with this emulator.

Just see the `mini-rv32ima` folder.

It's "fully functional" now in that I can run Linux, apps, etc.  Compile flat binaries and drop them in an image.

## Why

I'm working on a really really simple C Risc-V emulator. So simple it doesn't even have an MMU (Memory Management Unit). I have a few goals, they include:
 * Furthering RV32-NOMMU work to improve Linux support for RV32-NOMMU.  (Imagine if we could run Linux on the $1 ESP32-C3)
 * Learning more about RV32 and writing emulators.
 * Being further inspired by @pimaker's amazing work on [Running Linux in a Pixel Shader](https://blog.pimaker.at/texts/rvc1/) and having the sneaking suspicion performance could be even better!
 * Hoping to port it to some weird places.
 * Understand the *most simplistic* system you can run Linux on and trying to push that boundary.
 * Continue to include my [education of people about assembly language](https://www.youtube.com/watch?v=Gelf0AyVGy4).

## How

Windows instructions (Just playing with the image)
 * Clone this repo.
 * Install or have TinyCC.  [Powershell Installer](https://github.com/cntools/Install-TCC) or [Regular Windows Installer](https://github.com/cnlohr/tinycc-win64-installer/releases/tag/v0_0.9.27)
 * Run `winrun.ps` in the `windows` folder.

WSL (For full toolchain and image build:
 * You will need to remove all spaces from your path i.e. `export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/mnt/c/Windows/system32:/snap/bin` and continue the instructions.  P.S. What in the world was Windows thinking, putting a space between "Program" and "Files"??!?

Linux instructions (both): 
 * Clone this repo.
 * Install `git build-essential` and/or whatever other requirements are in place for [buildroot](https://buildroot.org/).
 * `make testdlimage`
 * It automatically downloads the image (~1MB) and runs the emulator.
 * Should be up and running in about 2.5s depending on internet speed.

You can do in-depth work on Linux by:
 * `make everything`

If you want to play with the bare metal system, see below, or if you have the toolchain installed, just:
 * `make testbare`

If you just want to play emdoom, and use the prebuilt image:
 * On Windows, run `windows\winrundoom.ps1`
 * On Linux, `cd mini-rv32ima`, and type `make testdoom`

## Questions?
 * Why not rv64?
   * Because then I can't run it as easily in a pixel shader if I ever hope to.
 * Can I add an MMU?
   * Yes.  It actually probably wouldn't be too difficult.
 * Should I add an MMU?
   * No.  It is important to further support for nommu systems to empower minimal Risc-V designs!

Everything else: Contact us on my Discord: https://discord.com/invite/CCeyWyZ

## Hopeful goals?
 * Further drive down needed features to run Linux.
   * Remove need for RV32A extension on systems with only one CPU.
   * Support for relocatable ELF executables.
   * Add support for an unreal UART.  One that's **much** simpler than the current 8250 driver.
 * Maybe run this in a pixelshader too!
 * Get opensbi working with this.
 * Be able to "embed" rv32 emulators in random projects.
 * Can I use early console to be a full system console?
 * Can I increase the maximum contiguous memory allocatable?

## Special Thanks
 * For @regymm and their [patches to buildroot](https://github.com/regymm/buildroot) and help!
   * callout: Regymm's [quazisoc project](https://github.com/regymm/quasiSoC/).
 * Buildroot (For being so helpful).
 * @vowstar and their team working on [k210-linux-nommu](https://github.com/vowstar/k210-linux-nommu).
 * This [guide](https://jborza.com/emulation/2020/04/09/riscv-environment.html)
 * [rvcodecjs](https://luplab.gitlab.io/rvcodecjs/) I probably went through over 1,000 codes here.
 * @splinedrive from the [KianV RISC-V noMMU SoC](https://github.com/splinedrive/kianRiscV/tree/master/linux_socs/kianv_harris_mcycle_edition?s=09) project.
 
## More details

If you want to build the kernel yourself:
 * `make everything`
 * About 20 minutes.  (Or 4+ hours if you're on [Windows Subsytem for Linux 2](https://github.com/microsoft/WSL/issues/4197))
 * And you should be dropped into a Linux busybox shell with some little tools that were compiled here.

## Emdoom notes
 * Emdoom building is in the `experiments/emdoom` folder
 * You *MUST* build your kernel with `MAX_ORDER` set to >12 in `buildroot/output/build/linux-5.19/include/linux/mmzone.h` if you are building your own image.
 * You CAN use the pre-existing image that is described above.
 * On Windows, it will be very slow.  Not sure why.

If you want to use bare metal to build your binaries so you don't need buildroot, you can use the rv64 gcc in 32-bit mode built into Ubuntu 20.04 and up.
```
sudo apt-get install gcc-multilib gcc-riscv64-unknown-elf make
```

## Links
 * "Hackaday Supercon 2022: Charles Lohr - Assembly in 2022: Yes! We Still Use it and Here's Why" : https://www.youtube.com/watch?v=Gelf0AyVGy4
 
## Attic


## General notes:
 * https://github.com/cnlohr/riscv_emufun/commit/2f09cdeb378dc0215c07eb63f5a6fb43dbbf1871#diff-b48ccd795ae9aced07d022bf010bf9376232c4d78210c3113d90a8d349c59b3dL440


(These things don't currently work)

### Building Tests

(This does not work, now)
```
cd riscv-tests
export CROSS_COMPILE=riscv64-linux-gnu-
export PLATFORM_RISCV_XLEN=32
CC=riscv64-linux-gnu-gcc ./configure
make XLEN=32 RISCV_PREFIX=riscv64-unknown-elf- RISCV_GCC_OPTS="-g -O1 -march=rv32imaf -mabi=ilp32f -I/usr/include"
```

### Building OpenSBI

(This does not currently work!)
```
cd opensbi
export CROSS_COMPILE=riscv64-unknown-elf-
export PLATFORM_RISCV_XLEN=32
make
```

### Extra links
 * Clear outline of CSRs: https://five-embeddev.com/riscv-isa-manual/latest/priv-csrs.html
 * Fonts used in videos: https://audiolink.dev/

### Using custom build

Where yminpatch is the patch from the mailing list.
```
rm -rf buildroot
git clone git://git.buildroot.net/buildroot
cd buildroot
git am < ../yminpatch.txt
make qemu_riscv32_nommu_virt_defconfig
make
# Or use our configs.
```

Note: For emdoom you will need to modify include/linux/mmzone.h and change MAX_ORDER to 13.

### Buildroot Notes

Add this:
https://github.com/cnlohr/buildroot/pull/1/commits/bc890f74354e7e2f2b1cf7715f6ef334ff6ed1b2

Use this:
https://github.com/cnlohr/buildroot/commit/e97714621bfae535d947817e98956b112eb80a75

## original from https://github.com/cnlohr/mini-rv32ima  
* https://github.com/cnlohr/mini-rv32ima  
* https://github.com/tvlad1234/linux-ch32v003  
* work_m68k  
* linux-ch32v003_v4_good_no_systick.7z  
* mini-rv32ima-master_mingw_cd_mini-rv32ima_make_testdlimage.7z  

## How to run  
```
(under MINGW!!!)  
cd mini-rv32ima
make testdlimage
```

## Removed files  
* mini-rv32ima/.exe

## Study in weibo
```
目前risc-v rv32和m68k都可以找到轻量级模拟器运行linux或uclinux：
mini-rv32ima+linux+mingw和68katy-musashi+uclinux+mingw。
现在还差我最喜欢的mips和arm的轻量级模拟器就齐全了（其实还可以加上x86）。
arm比较少，例如skyeye。mips则可能较多，例如virtualmips。
我要研究一段时间找找看
```
```
如果深究下去，发现gh上有很多类似tvlad1234/linux-ch32v00的项目（基于mini-rv32ima），
例如TinyEMU是另一个比较出名的RISC-V模拟器（作者就是qemu的作者bellard），
又例如ElectroBoy404NotFound/uARM和uMIPS，也就是说早就有人研究MIPS和ARM的
小型模拟器——虽然我还没试验过能否跑起来
```
```
我可能暂时不研究tvlad1234/linux-ch32v003和cnlohr/mini-rv32ima，
因为我大概已经跑通了，就除了systick没正确算出来
（我是强行间隔5微秒而不是实际systick的间隔，但模拟器依然可以工作）。
我转去研究别的，例如AG32。当然以后会做特定架构指令模拟器相关的研究和开发，
因为我比较喜欢这方面
```
```
据我所知已经有至少三个开源（JuiceVm闭源）项目研究rv32ima linux模拟器的了，
cnlohr/mini-rv32ima和Low-Speed-Linux-Experimental-Platform/temu还有juiceRv/JuiceVm。
我也想研究，但目前没有头绪，虽然没什么用，但似乎可以节省买开发板的钱
```
```
修改linux-ch32v003源代码，可以在riscv_emu（mini-rv32ima）的for循环中输出一下pc值
（代码段地址），可以看到在获取命令行提示符波浪线井号之前，pc值大概是800D前缀
（最后是800C），有时候会跳到8011，而获取波浪线提示符之后，pc值大概是8000和8003前缀
（例如8000 xxxx）。我打算晚上试试，看跑单片机时是否进入错误的pc值而导致无法输出Linux日志？
增加的代码例如这样：printf( "\rcore.pc == %04X", core.pc);
```
```
我决定重新换一个cpu和重新自己写一个MounRiver Studio工程去跑tvlad1234/linux-ch32v003，
因为我发现我怎么都没办法共用SPI去分时读写PSRAM和TF卡，原因不明。我之前已经用mingw
验证过是可以跑的。所以这个问题还需要一些时间，相当于换一个CPU再移植一遍
tvlad1234/linux-ch32v003和mini-rv32ima
```
```
我试过用linux和mingw都可以编译cnlohr/mini-rv32ima，方法很简单，只需要
cd mini-rv32ima; make testdlimage即可（其实就是单文件编译，顺便会wget内核镜像）。
不过要注意一个问题，这个开源项目似乎不兼容tvlad1234/linux-ch32v003的内核镜像
```
```
其实有可能mini-rv32ima的出现就是因为（可能）较早出现的linux模拟器juiceVm不开源。
不过其实mini-rv32ima也比较麻烦，虽然我试过可以移植linux-ch32v003到mingw（基于mini-rv32ima），
但其实mini-rv32ima本身也有PC移植，我还没研究，估计mini-rv32ima本身也不容易使用
```
```
用mingw移植tvlad1234/linux-ch32v003成功（基于mini-rv32ima），效果如下。有几个移植的重点，
其中最关键是ticks（系统嘀嗒）的问题，如果MICROSECOND_TICKS这个地方移植不对，
会无法实现键盘输入中断。有点类似LVGL那样。有机会我会把我的移植放到gh上
```
```
运行tvlad1234/linux-ch32v003失败，我再焊一次ESP-PSRAM，依旧失败，原因不明。
我可能找时间研究原理，这个开源项目实际可能是基于mini-rv32ima的，
也就是可以模拟器运行，所以我可能会尝试用PC方式编译运行，
或者想办法模拟这个linux-ch32v003的效果在PC上测试
```

## TODO  
* How to build DownloadedImage and some linux device tree data file embeded in the sources  
