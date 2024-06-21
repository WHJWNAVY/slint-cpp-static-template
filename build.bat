@echo off

set target=slint_hello

set cur_path=%cd%
set cmake_exe=cmake.exe
set upx_exe="D:/Program Files/upx/upx.exe"

rem gcc or llvm
set cc_type=llvm
set slint_ver=1.6.0

if "%cc_type%" == "gcc" (
	rem gcc:WinLibs
	set cc_dir=C:/WinLibs/ucrt/bin
	set strip_name=strip.exe
	set cxx_name=g++.exe
	set cc_name=gcc.exe
	set link_name=ld.exe
	set make_name=mingw32-make.exe
) else (
	rem llvm:LLVM-MinGW
	set cc_dir=C:/LLVM-MinGW/ucrt/bin
	set strip_name=llvm-strip.exe
	set cxx_name=clang++.exe
	set cc_name=clang.exe
	set link_name=ld.lld.exe
	set make_name=mingw32-make.exe
)
set strip_exe=%cc_dir%/%strip_name%
set cxx_compiler=%cc_dir%/%cxx_name%
set cc_compiler=%cc_dir%/%cc_name%
set link_executable=%cc_dir%/%link_name%
set make_program=%cc_dir%/%make_name%
echo "cc_dir = [%cc_dir%]"
echo "cc_compiler = [%cc_compiler%]"

set slint_dir=%cur_path%/../slint-cpp-release/%slint_ver%/%cc_type%
echo "slint_dir = [%slint_dir%]"

set build_dir=build
set install_dir=install

set cflags=-Os -DNDEBUG -ffunction-sections -fdata-sections -static
set ldlibrary=-lkernel32 -luser32 -lgdi32 -lwinspool -lshell32 -lole32 -loleaut32 -luuid -lcomdlg32 -ladvapi32 -lcomctl32 -liphlpapi -lws2_32 -lntoskrnl -lbcrypt -lopengl32 -luiautomationcore -lpropsys -ldwmapi -limm32 -luxtheme -luserenv -static

echo "cflags = [%cflags%]"
echo "ldlibrary = [%ldlibrary%]"

set ldflags=-Os -DNDEBUG -Wl,-subsystem,windows -Wl,--gc-sections -static

echo "Del build cache"
rmdir /s /q %build_dir%
mkdir %build_dir%
call :my_sleep

echo "Run cmake generator"
%cmake_exe% -G "MinGW Makefiles" -B "%build_dir%" ^
	-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON ^
	-DCMAKE_BUILD_TYPE:STRING=MinSizeRel ^
	-DCMAKE_CXX_COMPILER:STRING="%cxx_compiler%" ^
	-DCMAKE_C_COMPILER:STRING="%cc_compiler%" ^
	-DCMAKE_LINKER:STRING="%link_executable%" ^
	-DCMAKE_CXX_LINK_EXECUTABLE:STRING="%link_executable%" ^
	-DCMAKE_C_LINK_EXECUTABLE:STRING="%link_executable%" ^
	-DCMAKE_MAKE_PROGRAM:FILEPATH="%make_program%" ^
	-DCMAKE_CXX_FLAGS:STRING="%cflags%" ^
	-DCMAKE_C_FLAGS:STRING="%cflags%" ^
	-DCMAKE_CXX_STANDARD_LIBRARIES:STRING="%ldlibrary%" ^
	-DCMAKE_C_STANDARD_LIBRARIES:STRING="%ldlibrary%" ^
	-DCMAKE_STATIC_LINKER_FLAGS:STRING="%ldflags%" ^
	-DCMAKE_EXE_LINKER_FLAGS:STRING="%ldflags%" ^
	-DSLINT_COMPILER:FILEPATH="%slint_dir%/bin/slint-compiler.exe" ^
	-DSlint_DIR:PATH="%slint_dir%/lib/cmake/Slint" ^
	-DCMAKE_INSTALL_PREFIX:PATH="%install_dir%"
if %errorlevel% neq 0 goto my_error
call :my_sleep

echo "Run cmake build [%cmake_exe% --build %build_dir%]"
%cmake_exe% --build %build_dir%
if %errorlevel% neq 0 goto my_error
call :my_sleep

if exist %strip_exe% (
	echo "Run strip [%strip_exe% --strip-all %build_dir%/%target%.exe]"
	%strip_exe% --strip-all %build_dir%/%target%.exe
	if %errorlevel% neq 0 goto my_error
	call :my_sleep
) else (
	echo "Skip strip"
)

if exist %upx_exe% (
	echo "Run upx [%upx_exe% %build_dir%/%target%.exe]"
	rem %upx_exe% -9 --ultra-brute %build_dir%/%target%.exe
	%upx_exe% %build_dir%/%target%.exe
	if %errorlevel% neq 0 goto my_error
	call :my_sleep
) else (
	echo "Skip upx"
)

echo "Run [%build_dir%/%target%.exe]"
%build_dir%\%target%.exe
if %errorlevel% neq 0 goto my_error
goto my_success

:my_sleep
rem echo "wait 1s ..."
ping 127.0.0.1 -n 2 > nul
goto :eof

:my_success
echo "Build success!"
goto :eof

:my_error
echo "Build failed!"
goto :eof