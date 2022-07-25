@echo on

echo %CFLAGS%
echo %CXXFLAGS%

mkdir build-cpp
if errorlevel 1 exit 1

cd build-cpp

cmake ..  ^
      -GNinja ^
      -DCMAKE_VERBOSE_MAKEFILE=ON ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH=%CONDA_PREFIX% ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DgRPC_ABSL_PROVIDER="package" ^
      -DgRPC_CARES_PROVIDER="package" ^
      -DgRPC_GFLAGS_PROVIDER="package" ^
      -DgRPC_PROTOBUF_PROVIDER="package" ^
      -DgRPC_SSL_PROVIDER="package" ^
      -DgRPC_RE2_PROVIDER="package" ^
      -DgRPC_ZLIB_PROVIDER="package"

cmake --build . --config Release --target install

if errorlevel 1 exit 1
