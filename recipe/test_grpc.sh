#!/bin/bash
set -ex

# Compile a trivial service definition to C++
if [[ "${build_platform}" == "${target_platform}" ]]; then
  protoc -I. --plugin=protoc-gen-grpc=$PREFIX/bin/grpc_cpp_plugin --grpc_out=. hello.proto
  test -f hello.grpc.pb.h
  test -f hello.grpc.pb.cc
fi

# taken from cd examples/cpp/helloworld
cd examples/cpp/helloworld

# folder already contains a file called BUILD
mkdir build-cpp
cd build-cpp

cmake -G "Ninja" \
    ${CMAKE_ARGS} \
    -DProtobuf_INCLUDE_DIR=$PREFIX/include \
    -DProtobuf_LIBRARY=$PREFIX/lib/libprotobuf.so \
    -DProtobuf_LITE_LIBRARY=$PREFIX/lib/libprotobuf-lite.so \
    -DProtobuf_PROTOC_LIBRARY=$PREFIX/lib/libprotoc.so \
    -DProtobuf_PROTOC_EXECUTABLE=$PREFIX/bin/protoc \
    -DCMAKE_CXX_STANDARD=17 \
    ..

cmake --build .
