#!/bin/bash
set -ex

export GRPC_BUILD_WITH_BORING_SSL_ASM=""
export GRPC_PYTHON_DISABLE_ABSL_INIT_LOG="1"  # does not support "True"
export GRPC_PYTHON_BUILD_SYSTEM_ABSL="True"
export GRPC_PYTHON_BUILD_SYSTEM_CARES="True"
export GRPC_PYTHON_BUILD_SYSTEM_GRPC_CORE="True"
export GRPC_PYTHON_BUILD_SYSTEM_OPENSSL="True"
export GRPC_PYTHON_BUILD_SYSTEM_RE2="True"
export GRPC_PYTHON_BUILD_SYSTEM_ZLIB="True"
export GRPC_PYTHON_BUILD_WITH_CYTHON="True"
export GRPC_PYTHON_USE_PREBUILT_GRPC_CORE=""

if [[ "${target_platform}" == linux-* ]]; then
    # set these so the default in setup.py are not used
    # it seems that we need to link to pthread on linux or osx.
    export GRPC_PYTHON_LDFLAGS="-lpthread"
elif [[ "$target_platform" == osx-* ]]; then
    export GRPC_PYTHON_LDFLAGS=" -framework CoreFoundation"
fi

if [[ "$target_platform" == osx-64 ]]; then
    export CFLAGS="$CFLAGS -DTARGET_OS_OSX=1"
fi

ln -sf "$(which $CC)" "$SRC_DIR/cc"
export PATH="$SRC_DIR:$PATH"

# our compilers set `-DNDEBUG` in CPPFLAGS, but grpc does not seem to respect
# this consistently; add it to CXXFLAGS as well to avoid any doubt, see
# https://github.com/abseil/abseil-cpp/issues/1624#issuecomment-1968073823
CXXFLAGS="${CXXFLAGS} -DNDEBUG"

$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -v
