#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cargo             \
    cmake             \
    glslang           \
    meson             \
    python-mako       \
    python-numpy      \
	libxslt			  \
    glu               \
    libcaca           \
    libxkbcommon      \
    ocl-icd           \
    opencl-headers    \
    vulkan-icd-loader \
    vulkan-headers    \
    wayland-protocols

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Building waffle..."
echo "---------------------------------------------------------------"
REPO="https://gitlab.freedesktop.org/mesa/waffle"
git clone --depth 1 "$REPO" ./waffle

arch-meson ./waffle build --buildtype release -D build-manpages=false -D build-htmldocs=false -D build-examples=false
meson compile -C build
meson install -C build
rm -rf ./build

echo "Building Vkrunner..."
echo "---------------------------------------------------------------"
REPO="https://gitlab.freedesktop.org/mesa/vkrunner"
git clone --depth 1 "$REPO" ./vkrunner

cd ./vkrunner
export RUSTUP_TOOLCHAIN=stable
export RUSTUP_TOOLCHAIN=stable
export CARGO_TARGET_DIR=target
cargo fetch --target host-tuple
cargo build --offline --release --all-features
mv -v target/release/vkrunner /usr/bin/vkrunner
cd ../

echo "Building Piglit..."
echo "---------------------------------------------------------------"
REPO="https://gitlab.freedesktop.org/mesa/piglit"
VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
git clone --depth 1 "$REPO" ./piglit
echo "$VERSION" > ~/version

cmake -S ./piglit -B build \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_INSTALL_LIBDIR=lib \
	-DPIGLIT_BUILD_CL_TESTS=1 \
    -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
cmake --install build

