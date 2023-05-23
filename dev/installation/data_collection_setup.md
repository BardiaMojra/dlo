# DLO Data Collection System Setup

## Notes

### Important Links

- [Franka ROS2 Wrapper](https://github.com/frankaemika/franka_ros2)
- [How to Update Linux Kernel In Ubuntu](https://phoenixnap.com/kb/how-to-update-kernel-ubuntu)
- [Kernel.org](https://www.kernel.org/)
- [Build Your Own Kernel Tutorial](https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel).

### Keep in Mind

#### Fixing Installation issues

It's because of a dependency issue, running a force install will fix it:

```bash
sudo apt -f install
```

#### Install Kernel 5.16

This is an example of installing a specific kernel version.

```bash
cd ~/Downloads

wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.16/amd64/linux-headers-5.16.0-051600_5.16.0-051600.202201092355_all.deb
wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.16/amd64/linux-headers-5.16.0-051600-generic_5.16.0-051600.202201092355_amd64.deb
wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.16/amd64/linux-image-unsigned-5.16.0-051600-generic_5.16.0-051600.202201092355_amd64.deb
wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.16/amd64/linux-modules-5.16.0-051600-generic_5.16.0-051600.202201092355_amd64.deb

sudo dpkg -i *.deb
sudo apt -f install
```

#### Install the Latest Mainline Kernel (Latest LTS Release)

Use an automated bash script to install the latest mainline kernel.

1. Download and install the shell script.

```bash
wget https://raw.githubusercontent.com/pimlie/ubuntu-mainline-kernel.sh/master/ubuntu-mainline-kernel.sh
sudo install ubuntu-mainline-kernel.sh /usr/local/bin/
```

2. Run the script with c option.

```bash
sudo ubuntu-mainline-kernel.sh -c
```

3. Install the latest stable Kernel.

```bash
sudo ubuntu-mainline-kernel.sh -i
```

4. Reboot

```bash
sudo reboot
```

- For the future, if you'd like to recheck and reinstall the latest stable kernel, you can simply run:

```bash
sudo ubuntu-mainline-kernel.sh -i
```

- Note: You can check the kernel you are using, using the following command:

```bash
uname -r
```

## Environment Setup

- Ubuntu 20.04: Linux 5.15.0-72-generic x86_64
- Install Nvidia GPU drivers
- Install Real Time Kernel with a fully preemptible feature
- Install Franka-Panda library
- Install RealSense library
- Install ROS Noetic
- Create ROS workspace
- Install Franka-ROS library
- Install RealSense-ROS library

### Install RT Kernel, Franka-Panda, and RS Libraries

#### Update Kernel to the Latest Supported Version

This section is based on Ubuntu Wiki's [Build Your Own Kernel Tutorial](https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel).

##### Install Dependencies

Make sure to enable all 'source code' repositories in Software & Updates.

Install dependencies.

```bash
sudo apt-get build-dep linux linux-image-$(uname -r)
sudo apt-get install libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf llvm
sudo apt-get install git
```

We are using Ubuntu 20.04 distribution so the release code is "focal".

```bash
git clone git://kernel.ubuntu.com/ubuntu/ubuntu-focal.git
```

Set up the correct Debian source code repository.

```bash
deb-src http://archive.ubuntu.com/ubuntu/ubuntu focal main
deb-src http://archive.ubuntu.com/ubuntu/ubuntu focal-updates main
```

#### Download The Latest RT Kernel

This section is based on [Franka-Emika's Panda arm setup tutorial](https://frankaemika.github.io/docs/installation_linux.html#setting-up-the-real-time-kernel).

This section is based on [PBVS with Panda Tutorial by Visual Servoing Platform](https://visp-doc.inria.fr/doxygen/visp-daily/tutorial-franka-pbvs.html).

Check the kernel version and install the Real-Time Kernel with the closest version number.

```bash
$ uname -mrs
Linux 5.15.0-72-generic x86_64
```

```bash
cd ~/git
mkdir rt-linux; cd rt-linux
curl -SLO https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.15.111.tar.gz
curl -SLO https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/5.15/patch-5.15.111-rt63.patch.gz
```

Decompress the files.

```bash
tar xvzf linux-5.15.111.tar.gz
gunzip patch-5.15.111-rt63.patch.gz
```

Extract the source code and apply the patch.

```bash
cd linux-5.15.111
patch -p1 < ../patch-5.15.111-rt63.patch
```

#### Configure RT Kernel and Build it

Install dependencies.

```bash
sudo apt-get install build-essential bc curl ca-certificates fakeroot gnupg2 libssl-dev lsb-release libelf-dev bison flex
```

Configure. Choose Fully Preemptible Kernel. Select default settings, it would
be printed first and in CAPITAL, i.e. (N/m/y/?).

```bash
make oldconfig
```

Compile RT kernel.

```bash
fakeroot make -j4 deb-pkg
```

## Hardware

The following hardware setup was used for the development of this application.

```bash
H/W path         Device        Class          Description
=========================================================
                               system         Computer
/0                             bus            Motherboard
/0/0                           memory         16GiB System memory
/0/1                           processor      Intel(R) Core(TM) i7-9750H CPU @ 2.60GHz
/0/100                         bridge         8th Gen Core Processor Host Bridge/DRAM Registers
/0/100/1                       bridge         Xeon E3-1200 v5/E3-1500 v5/6th Gen Core Processor PCIe
/0/100/1/0                     display        TU106M [GeForce RTX 2060 Mobile]
/0/100/1/0.1                   multimedia     TU106 High Definition Audio Controller
/0/100/1/0.2                   bus            TU106 USB 3.1 Host Controller
/0/100/1/0.3                   bus            TU106 USB Type-C UCSI Controller
/0/100/2                       display        UHD Graphics 630 (Mobile)
/0/100/4                       generic        Xeon E3-1200 v5/E3-1500 v5/6th Gen Core Processor Therm
/0/100/8                       generic        Xeon E3-1200 v5/v6 / E3-1500 v5 / 6th/7th/8th Gen Core
/0/100/12                      generic        Cannon Lake PCH Thermal Controller
/0/100/14                      bus            Cannon Lake PCH USB 3.1 xHCI Host Controller
/0/100/14.2                    memory         RAM memory
/0/100/14.3      wlo1          network        Wireless-AC 9560 [Jefferson Peak]
/0/100/15                      bus            Cannon Lake PCH Serial IO I2C Controller #0
/0/100/15.1                    bus            Cannon Lake PCH Serial IO I2C Controller #1
/0/100/16                      communication  Cannon Lake PCH HECI Controller
/0/100/17                      storage        Cannon Lake Mobile PCH SATA AHCI Controller
/0/100/1d                      bridge         Cannon Lake PCH PCI Express Root Port #9
/0/100/1d/0                    storage        NVMe SSD Controller SM981/PM981/PM983
/0/100/1d/0/0    /dev/nvme0    storage        Samsung SSD 970 EVO Plus 2TB
/0/100/1d/0/0/1  /dev/nvme0n1  disk           NVMe namespace
/0/100/1d.6                    bridge         Cannon Lake PCH PCI Express Root Port #15
/0/100/1d.6/0    eno2          network        RTL8111/8168/8411 PCI Express Gigabit Ethernet Controll
/0/100/1f                      bridge         HM470 Chipset LPC/eSPI Controller
/0/100/1f.3                    multimedia     Cannon Lake PCH cAVS
/0/100/1f.4                    bus            Cannon Lake PCH SMBus Controller
/0/100/1f.5                    bus            Cannon Lake PCH SPI Controller
/0/2                           system         PnP device PNP0c02
/0/3                           system         PnP device PNP0c02
/0/4                           generic        PnP device INT3f0d
/0/5                           generic        PnP device ATK3001
/0/6                           system         PnP device PNP0c02
/0/7                           system         PnP device PNP0c02
/0/8                           system         PnP device PNP0c02
/0/9                           system         PnP device PNP0c02
```
