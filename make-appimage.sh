#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q piglit-git | awk '{print $2; exit}')
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DEPLOY_PYTHON=1
export USE_HOST_DRIVERS_EXPERIMENTAL=1

# Deploy dependencies
quick-sharun /usr/bin/piglit /usr/lib/piglit

# Turn AppDir into AppImage
quick-sharun --make-appimage
