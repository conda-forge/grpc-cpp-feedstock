@echo on

set GRPC_PYTHON_BUILD_WITH_CYTHON=true 
if exist src rmdir /s /q src
mklink /J src "%SRC_DIR%\grpc-source\src"
cd grpc-source
cd tools/distrib/python/grpcio_tools
REM del /f /q pyproject.toml
set CFLAGS=-I"%SRC_DIR%\grpc-source" %CFLAGS%
set CXXFLAGS=-I"%SRC_DIR%\grpc-source" %CXXFLAGS%
%PYTHON% -m pip install --no-deps --no-build-isolation . -vv