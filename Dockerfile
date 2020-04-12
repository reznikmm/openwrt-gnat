FROM ubuntu:18.04
ENV STAGING_DIR=/home/openwrt/openwrt/staging_dir
ENV TOOLCHAIN="${STAGING_DIR}/toolchain-arm_cortex-a9+vfpv3_gcc-7.5.0_musl_eabi"
ENV PATH="${TOOLCHAIN}/bin:${PATH}"
COPY *.patch diffconfig /tmp/
RUN apt-get update && \
  apt install -y --no-install-recommends \
  build-essential \
  libncurses5-dev \
  gawk \
  git \
  subversion \
  libssl-dev \
  gettext \
  zlib1g-dev \
  swig \
  unzip \
  time \
  python \
  gnat-7 \
  sudo \
  file \
  gprbuild \
  wget \
  curl && \
  useradd -s /bin/bash -m openwrt && \
  echo 'openwrt ALL=NOPASSWD: ALL' > /etc/sudoers.d/openwrt && \
  su - openwrt -c " \
    set -e ;\
    git config --global http.sslVerify false ;\
    git clone --depth 1 -b openwrt-19.07 https://github.com/openwrt/openwrt.git ;\
    cd openwrt ;\
    patch -p1 < /tmp/openwrt-enable_ada.patch ;\
    cp /tmp/955-gnat_on_musl.patch toolchain/gcc/patches/7.5.0/ ;\
    cp /tmp/diffconfig .config ;\
    ./scripts/feeds update -a ;\
    make defconfig ;\
    make -j1 toolchain/install V=w ;\
    make clean ;\
    ln $TOOLCHAIN/bin/arm-openwrt-linux-muslgnueabi-gcc \
       $TOOLCHAIN/bin/arm-openwrt-linux-muslgnueabi-gnatgcc ; \
    rm -rf dl tmp build_dir ;\
    rm $TOOLCHAIN/lib/lib ;\
  " && \
  sed -i -e 's/arm-linux-gnueabihf-/arm-.*/g' /usr/share/gprconfig/compilers.xml && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
