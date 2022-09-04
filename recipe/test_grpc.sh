#!/bin/bash
set -ex

# Compile a trivial service definition to C++
if [[ "${build_platform}" == "${target_platform}" ]]; then
  protoc -I. --plugin=protoc-gen-grpc=$PREFIX/bin/grpc_cpp_plugin --grpc_out=. hello.proto
  test -f hello.grpc.pb.h
  test -f hello.grpc.pb.cc
fi

# disabled on unix until libprotobuf-feedstock#127 & 128 are merged
if [[ 0 == 1 ]]; then
# taken from cd examples/cpp/helloworld
cd examples/cpp/helloworld

# folder already contains a file called BUILD
mkdir build-cpp
cd build-cpp

cmake -G "Ninja" \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_PREFIX_PATH="$PREFIX" \
    -DCMAKE_MODULE_PATH="$PREFIX/lib/cmake" \
    ..

cmake --build .
fi
