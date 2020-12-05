#!/bin/bash

set -ex

# Compile a trivial service definition to C++

protoc -Itests/include --plugin=protoc-gen-grpc=$PREFIX/bin/grpc_cpp_plugin --grpc_out=. hello.proto

test -f hello.grpc.pb.h
test -f hello.grpc.pb.cc

test -f $PREFIX/lib/libgrpc${SHLIB_EXT}
test -f $PREFIX/lib/libgrpc_unsecure${SHLIB_EXT}
test -f $PREFIX/lib/libgrpc++${SHLIB_EXT}
test -f $PREFIX/lib/libgrpc++_unsecure${SHLIB_EXT}
