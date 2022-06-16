if "%ARCH%" == "32" (set PLATFORM=x86) else (set PLATFORM=x64)

set "GRPC_PYTHON_BUILD_SYSTEM_ZLIB=True"
set "GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=True"
set "GRPC_PYTHON_CFLAGS=/DPB_FIELD_16BIT"
:: set "GRPC_PYTHON_BUILD_SYSTEM_GRPC_CORE=True"

:: clearing this regenerates it with cython and fixes phtread usage
del src\python\grpcio\grpc\_cython\cygrpc.cpp

"%PYTHON%" -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
if errorlevel 1 exit 1
