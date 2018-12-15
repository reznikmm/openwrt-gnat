# openwrt-gnat
Ada cross compiler for OpenWRT

Run it like this:
```
docker run --user openwrt --tty --interactive --volume \
      /tmp/src:/tmp/src reznik/openwrt-gnat
```

Then setup environment:
```
export STAGING_DIR=/home/openwrt/openwrt/staging_dir/
export PATH=$STAGING_DIR/toolchain-arm_cortex-a9+vfpv3_gcc-6.3.0_musl-1.1.16_eabi/bin:$PATH
```

Compile "hello world":
```
$ cat >  /tmp/hello.adb << EOF
with Ada.Text_IO;
procedure Hello is
begin
   Ada.Text_IO.Put_Line ("Hello world");
end Hello;
EOF
$ openwrt@445ccbd6e443:/tmp$ arm-openwrt-linux-gnatmake hello.adb -largs -lgcc_s
arm-openwrt-linux-gcc -c hello.adb
arm-openwrt-linux-gnatbind -x hello.ali
arm-openwrt-linux-gnatlink hello.ali -lgcc_s
$ file ./hello
./hello: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-musl-armhf.so.1, not stripped
```

Install gprbuild, patch gprconfig database then compile your project:
```
sudo apt-get install gprbuild
sudo sed -i -e 's/arm-linux-gnueabihf-/arm-.*/g' /usr/share/gprconfig/compilers.xml
gprbuild --target=arm-openwrt-linux-muslgnueabi -p -P prj.gpr
```

Read Dockerfile or fill issue on github:

https://github.com/reznikmm/openwrt-gnat
