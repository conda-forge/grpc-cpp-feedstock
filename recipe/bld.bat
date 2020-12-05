@echo on

@rem The `vs2015_win-64` compiler activate package sets CFLAGS and CXXFLAGS
@rem to "-MD -GL".  Unfortunately that causes a huge ballooning in static
@rem library size (more than 100MB per .lib file).  Unsetting those flags
@rem simply works.

set CFLAGS=
set CXXFLAGS=

mkdir build-cpp
if errorlevel 1 exit 1

cd build-cpp

if "%STATIC_BUILD%"=="yes" (
  set BUILD_SHARED_LIBS=OFF
) else (
  set BUILD_SHARED_LIBS=ON
)

cmake ..  ^
      -GNinja ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DBUILD_SHARED_LIBS=%BUILD_SHARED_LIBS% ^
      -DCMAKE_PREFIX_PATH=%CONDA_PREFIX% ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DgRPC_ABSL_PROVIDER="package" ^
      -DgRPC_CARES_PROVIDER="package" ^
      -DgRPC_GFLAGS_PROVIDER="package" ^
      -DgRPC_PROTOBUF_PROVIDER="package" ^
      -DgRPC_SSL_PROVIDER="package" ^
      -DgRPC_RE2_PROVIDER="package" ^
      -DgRPC_ZLIB_PROVIDER="package" ^
      -DCMAKE_VERBOSE_MAKEFILE=ON

ninja install -v

if errorlevel 1 exit 1
