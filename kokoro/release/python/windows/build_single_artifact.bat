setlocal

if %PYTHON%==C:\python35 set generator=Visual Studio 14
if %PYTHON%==C:\python35 set vcplatform=Win32

if %PYTHON%==C:\python35-x64 set generator=Visual Studio 14 Win64
if %PYTHON%==C:\python35-x64 set vcplatform=x64

if %PYTHON%==C:\python36 set generator=Visual Studio 14
if %PYTHON%==C:\python36 set vcplatform=Win32

if %PYTHON%==C:\python36-x64 set generator=Visual Studio 14 Win64
if %PYTHON%==C:\python36-x64 set vcplatform=x64

if %PYTHON%==C:\python37 set generator=Visual Studio 14
if %PYTHON%==C:\python37 set vcplatform=Win32

if %PYTHON%==C:\python37-x64 set generator=Visual Studio 14 Win64
if %PYTHON%==C:\python37-x64 set vcplatform=x64

if %PYTHON%==C:\python38 set generator=Visual Studio 14
if %PYTHON%==C:\python38 set vcplatform=Win32

if %PYTHON%==C:\python38-x64 set generator=Visual Studio 14 Win64
if %PYTHON%==C:\python38-x64 set vcplatform=x64

REM set python version
echo %PYTHON_VERSION%
CALL pyenv install %PYTHON_VERSION%
echo "installed python"
CALL pyenv global %PYTHON_VERSION%
echo "set global python"
CALL pyenv version
echo "python version"


REM Prepend newly installed Python to the PATH of this build (this cannot be
REM done from inside the powershell script as it would require to restart
REM the parent CMD process).
@REM SET PATH=%PYTHON%;%PYTHON%\Scripts;%OLD_PATH%

CALL python -m pip install -U pip --trusted-host pypi.python.org pypi.org files.pythonhosted.org
CALL pip install wheel --trusted-host pypi.python.org pypi.org files.pythonhosted.org

REM Check that we have the expected version and architecture for Python
CALL python --version
python -c "import struct; print(struct.calcsize('P') * 8)"

rmdir /s/q %REPO_DIR%
xcopy /s  %REPO_DIR_STAGE% "%REPO_DIR%\"

REM Checkout release commit
cd %REPO_DIR%

REM ======================
REM Build Protobuf Library
REM ======================

mkdir src\.libs

mkdir vcprojects
pushd vcprojects
CALL cmake -G "%generator%" -Dprotobuf_BUILD_SHARED_LIBS=%BUILD_DLL% -Dprotobuf_UNICODE=%UNICODE% -Dprotobuf_BUILD_TESTS=OFF ../cmake || goto :error
CALL msbuild protobuf.sln /p:Platform=%vcplatform% /p:Configuration=Release || goto :error
dir /s /b
popd
copy vcprojects\Release\libprotobuf.lib src\.libs\libprotobuf.a
copy vcprojects\Release\libprotobuf-lite.lib src\.libs\libprotobuf-lite.a
SET PATH=%cd%\vcprojects\Release;%PATH%
dir vcprojects\Release

REM ======================
REM Build python library
REM ======================

cd python

REM sed -i 's/\ extra_compile_args\ =\ \[\]/\ extra_compile_args\ =\ \[\'\/MT\'\]/g' setup.py

CALL python -m pip install setuptools==49.2.0 wheel==0.34.2 --trusted-host pypi.python.org pypi.org files.pythonhosted.org
CALL python setup.py bdist_wheel --cpp_implementation --compile_static_extension
dir dist
copy dist\* %ARTIFACT_DIR%
dir %ARTIFACT_DIR%
cd ..\..

goto :EOF

:error
exit /b %errorlevel%
