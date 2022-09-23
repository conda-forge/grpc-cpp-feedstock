@echo on

echo %CFLAGS%
echo %CXXFLAGS%

mkdir build-cpp
cd build-cpp

cmake ..  ^
      -GNinja ^
      -DBUILD_SHARED_LIBS=ON ^
      -DCMAKE_CXX_STANDARD=17 ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH=%CONDA_PREFIX% ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
      -DgRPC_MSVC_STATIC_RUNTIME=OFF ^
      -DgRPC_ABSL_PROVIDER="package" ^
      -DgRPC_CARES_PROVIDER="package" ^
      -DgRPC_GFLAGS_PROVIDER="package" ^
      -DgRPC_PROTOBUF_PROVIDER="package" ^
      -DgRPC_SSL_PROVIDER="package" ^
      -DgRPC_RE2_PROVIDER="package" ^
      -DgRPC_ZLIB_PROVIDER="package"
if %ERRORLEVEL% neq 0 exit 1

cmake --build . --config Release --target install
if %ERRORLEVEL% neq 0 exit 1
