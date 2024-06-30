@echo on
REM Move scripts to root
set REPO_DIR_STAGE=%cd%\github\protobuf-stage
xcopy /S  github\protobuf "%REPO_DIR_STAGE%\"
cd github\protobuf
copy kokoro\release\python\windows\build_single_artifact.bat build_single_artifact.bat

REM Set environment variables
set PACKAGE_NAME=protobuf
set REPO_DIR=protobuf
set BUILD_DLL=OFF
set UNICODE=ON
set PB_TEST_DEP="six==1.9"
set OTHER_TEST_DEP="setuptools==38.5.1"
set OLD_PATH=C:\Program Files (x86)\MSBuild\14.0\bin\;%PATH%

REM Fetch multibuild
git clone https://github.com/matthew-brett/multibuild.git

REM Install zlib
mkdir zlib
curl -L -o zlib.zip http://www.winimage.com/zLibDll/zlib123dll.zip
curl -L -o zlib-src.zip http://www.winimage.com/zLibDll/zlib123.zip
7z x zlib.zip -ozlib
7z x zlib-src.zip -ozlib\include
SET ZLIB_ROOT=%cd%\zlib
del /Q zlib.zip
del /Q zlib-src.zip

REM Create directory for artifacts
SET ARTIFACT_DIR=%cd%\artifacts
mkdir %ARTIFACT_DIR%

REM Build wheel
REM add pyenv to path
SET PATH=C:\Users\appveyor\.pyenv\pyenv-win\bin;C:\Users\appveyor\.pyenv\pyenv-win\shims;%PATH%

SET PYTHON=C:\python35
SET PYTHON_VERSION=3.5.4-win32
SET PYTHON_ARCH=32
CALL build_single_artifact.bat || goto :error

@REM SET PYTHON=C:\python35-x64
@REM SET PYTHON_VERSION=3.5.4
@REM SET PYTHON_ARCH=64
@REM CALL build_single_artifact.bat || goto :error

@REM SET PYTHON=C:\python36
@REM SET PYTHON_VERSION=3.6.8-win32
@REM SET PYTHON_ARCH=32
@REM CALL build_single_artifact.bat || goto :error

@REM SET PYTHON=C:\python36-x64
@REM SET PYTHON_VERSION=3.6.8
@REM SET PYTHON_ARCH=64
@REM CALL build_single_artifact.bat || goto :error

@REM SET PYTHON=C:\python37
@REM SET PYTHON_VERSION=3.7.9-win32
@REM SET PYTHON_ARCH=32
@REM CALL build_single_artifact.bat || goto :error

@REM SET PYTHON=C:\python37-x64
@REM SET PYTHON_VERSION=3.7.9
@REM SET PYTHON_ARCH=64
@REM CALL build_single_artifact.bat || goto :error

@REM SET PYTHON=C:\python38
@REM SET PYTHON_VERSION=3.8.10-win32
@REM SET PYTHON_ARCH=32
@REM CALL build_single_artifact.bat || goto :error

@REM SET PYTHON=C:\python38-x64
@REM SET PYTHON_VERSION=3.8.10
@REM SET PYTHON_ARCH=64
@REM CALL build_single_artifact.bat || goto :error

goto :EOF

:error
exit /b %errorlevel%
