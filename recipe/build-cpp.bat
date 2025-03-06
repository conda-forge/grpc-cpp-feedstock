@echo on

echo %CFLAGS%
echo %CXXFLAGS%

:: copy a necessary helper to source directory
copy %RECIPE_DIR%\generate_def.py %SRC_DIR%\generate_def.py

mkdir build-cpp
pushd build-cpp

:: we need to modify upb/port/def.inc, because that's the only header getting included in all
:: the src/core/ext/upb-gen/* files; save the original so we don't get issues with clobbering
copy %LIBRARY_INC%\upb\port\def.inc .\upb_port_def_orig.inc
echo #if defined(GRPC_UPBGEN_DLL_EXPORTS)           >> %LIBRARY_INC%\upb\port\def.inc
echo #define GRPC_UPBGEN_DLL __declspec(dllexport)  >> %LIBRARY_INC%\upb\port\def.inc
echo #elif defined(GRPC_UPBGEN_DLL_IMPORTS)         >> %LIBRARY_INC%\upb\port\def.inc
echo #define GRPC_UPBGEN_DLL __declspec(dllimport)  >> %LIBRARY_INC%\upb\port\def.inc
echo #else                                          >> %LIBRARY_INC%\upb\port\def.inc
echo #define GRPC_UPBGEN_DLL                        >> %LIBRARY_INC%\upb\port\def.inc
echo #endif // defined(GRPC_UPBGEN_DLL_EXPORTS)     >> %LIBRARY_INC%\upb\port\def.inc

cmake -GNinja ^
      -DBUILD_SHARED_LIBS=ON ^
      -DCMAKE_CXX_STANDARD=17 ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH=%CONDA_PREFIX% ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DgRPC_MSVC_STATIC_RUNTIME=OFF ^
      -DgRPC_ABSL_PROVIDER="package" ^
      -DgRPC_CARES_PROVIDER="package" ^
      -DgRPC_PROTOBUF_PROVIDER="package" ^
      -DgRPC_SSL_PROVIDER="package" ^
      -DgRPC_RE2_PROVIDER="package" ^
      -DgRPC_ZLIB_PROVIDER="package" ^
      -DProtobuf_PROTOC_EXECUTABLE=%LIBRARY_BIN%\protoc.exe ^
      ..
if %ERRORLEVEL% neq 0 exit 1

cmake --build . --config Release --target install
if %ERRORLEVEL% neq 0 exit 1

:: restore original
move .\upb_port_def_orig.inc %LIBRARY_INC%\upb\port\def.inc

:: check number of symbols in grpc.dll on windows
python -c "import os, lief; print(len(lief.parse(os.environ['LIBRARY_BIN'] + r'\grpc.dll').exported_functions))"

popd
