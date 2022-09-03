@echo on

@rem The `vs2015_win-64` compiler activate package sets CFLAGS and CXXFLAGS
@rem to "-MD -GL".  Unfortunately that causes a huge ballooning in static
@rem library size (more than 100MB per .lib file).  Unsetting those flags
@rem simply works.

set CFLAGS=
set CXXFLAGS=

mkdir build-cpp
cd build-cpp

cmake ..  ^
      -GNinja ^
      -DBUILD_SHARED_LIBS=ON ^
      -DCMAKE_CXX_STANDARD=11 ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH=%CONDA_PREFIX% ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
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
