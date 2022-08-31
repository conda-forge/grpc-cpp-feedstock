#!/bin/bash
set -ex

# Compile a trivial service definition to C++
if [[ "${build_platform}" == "${target_platform}" ]]; then
  protoc -I$RECIPE_DIR --plugin=protoc-gen-grpc=$PREFIX/bin/grpc_cpp_plugin --grpc_out=. hello.proto
  test -f hello.grpc.pb.h
  test -f hello.grpc.pb.cc
fi

# taken from cd examples/cpp/helloworld
cd examples/cpp/helloworld

mkdir build
cd build

cmake -G "Ninja" \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_PREFIX_PATH="$PREFIX" \
    -DCMAKE_MODULE_PATH="$PREFIX/lib/cmake" \
    ..

cmake --build .
