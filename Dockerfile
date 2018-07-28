FROM debian:stretch
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
  gnat-6 \
  sudo \
  file \
  wget \
  curl && \
  useradd -s /bin/bash -m openwrt && \
  echo 'openwrt ALL=NOPASSWD: ALL' > /etc/sudoers.d/openwrt && \
  su - openwrt -c " \
    set -e ;\
    git config --global http.sslVerify false ;\
    git clone --depth 2  -b lede-17.01 https://github.com/openwrt/openwrt.git ;\
    cd openwrt ;\
    patch -p1 < /tmp/openwrt-enable_ada.patch ;\
    cp /tmp/955-gnat_on_musl.patch toolchain/gcc/patches/6.3.0/ ;\
    cp /tmp/diffconfig .config ;\
    ./scripts/feeds update -a ;\
    make defconfig ;\
    make -j1 toolchain/install V=w ;\
    make clean ;\
    rm -rf dl tmp ;\
    rm staging_dir/toolchain-arm_cortex-a9+vfpv3_gcc-6.3.0_musl-1.1.16_eabi/lib/lib ;\
  "
