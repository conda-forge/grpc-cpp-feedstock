#!/bin/bash
set -ex

export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_CXX_STANDARD=17"

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
  # use a separate scope here, so that changes to the compiler
  # configuration in this branch don't leak out to the main build
  (
    mkdir -p build-host
    pushd build-host

    # overwrite default compiler configuration to compile for architecture of
    # build agent, since that's where we'll need to execute grpc_cpp_plugin
    export CC=$CC_FOR_BUILD
    export CXX=$CXX_FOR_BUILD
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    export PKG_CONFIG_PATH=${PKG_CONFIG_PATH//$PREFIX/$BUILD_PREFIX}
    export CMAKE_ARGS=${CMAKE_ARGS//$PREFIX/$BUILD_PREFIX}

    # Unset them as we're ok with a build-confined version of
    # grpc_cpp_plugin that's either slow or non-portable
    unset CFLAGS
    unset CXXFLAGS

    cmake -GNinja \
          ${CMAKE_ARGS} \
          -DBUILD_SHARED_LIBS=OFF \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_PREFIX_PATH=$BUILD_PREFIX \
          -DCMAKE_INSTALL_PREFIX=$BUILD_PREFIX \
          -DgRPC_CARES_PROVIDER="package" \
          -DgRPC_PROTOBUF_PROVIDER="package" \
          -DgRPC_SSL_PROVIDER="package" \
          -DgRPC_ZLIB_PROVIDER="package" \
          -DgRPC_ABSL_PROVIDER="package" \
          -DgRPC_RE2_PROVIDER="package" \
          -DgRPC_BUILD_CODEGEN=ON \
          -DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF \
          -DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF \
          -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF \
          -DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF \
          -DgRPC_BUILD_GRPC_PYTHON_PLUGIN=OFF \
          -DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF \
          -DProtobuf_ROOT=$BUILD_PREFIX \
          -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc \
          ..
    ninja grpc_cpp_plugin
    cp grpc_cpp_plugin $BUILD_PREFIX/bin/grpc_cpp_plugin

    popd
  )
  # don't build tests in cross-compilation; cannot run them anyway
  export CMAKE_ARGS="${CMAKE_ARGS} -DgRPC_BUILD_TESTS=OFF"
else
  export CMAKE_ARGS="${CMAKE_ARGS} -DgRPC_CF_TESTS=ON"
fi

if [[ "${target_platform}" == osx-* ]]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
else
  # reduce very noisy compiler warnings
  CXXFLAGS="${CXXFLAGS} -w"
fi

mkdir -p build-cpp
pushd build-cpp

# sanity-check that encapsulation above worked
echo CC="${CC}"
echo CFLAGS="${CFLAGS}"

# our compilers set `-DNDEBUG` in CPPFLAGS, but grpc does not seem to respect
# this consistently; add it to CXXFLAGS as well to avoid any doubt, see
# https://github.com/abseil/abseil-cpp/issues/1624#issuecomment-1968073823
CXXFLAGS="${CXXFLAGS} -DNDEBUG"

# point to right protoc
if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
    export CMAKE_ARGS="${CMAKE_ARGS} -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc"
else
    export CMAKE_ARGS="${CMAKE_ARGS} -DProtobuf_PROTOC_EXECUTABLE=$PREFIX/bin/protoc"
fi

cmake -GNinja \
      ${CMAKE_ARGS} \
      -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DgRPC_CARES_PROVIDER="package" \
      -DgRPC_PROTOBUF_PROVIDER="package" \
      -DgRPC_SSL_PROVIDER="package" \
      -DgRPC_ZLIB_PROVIDER="package" \
      -DgRPC_ABSL_PROVIDER="package" \
      -DgRPC_RE2_PROVIDER="package" \
      -DProtobuf_ROOT=$PREFIX \
      ..

cmake --build . -j${CPU_COUNT}

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != 1 ]]; then
    ctest --progress --output-on-failure
fi

cmake --install .
popd
