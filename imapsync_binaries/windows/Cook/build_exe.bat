
REM $Id: build_exe.bat,v 1.60 2023/09/19 23:46:43 gilles Exp gilles $

@SETLOCAL
@ECHO Currently running through %0 %*

@ECHO Building imapsync.exe

@REM the following command change current directory to the dirname of the current batch pathname
CD /D %~dp0

REM Remove the error file because its existence means an error occurred during this script execution
IF EXIST LOG_bat\%~nx0.txt DEL LOG_bat\%~nx0.txt


CALL :handle_error CALL :detect_perl
CALL :handle_error CALL :check_modules
CALL :handle_error CALL :rename_to_old
CALL :handle_error CALL :pp_exe
CALL :handle_error CALL :tests_check_binary_embed_all_dyn_libs
CALL :handle_error CALL :testslive 
CALL :handle_error CALL :tests
CALL :handle_error CALL :copy_with_architecture_name

@REM Do a PAUSE if run by double-click, aka, explorer (then ). No PAUSE in a DOS window or via ssh.
IF %0 EQU "%~dpnx0" IF "%SSH_CLIENT%"=="" PAUSE
@ENDLOCAL
EXIT /B


:pp_exe
@SETLOCAL
@REM In order to verify that all Strawberry dlls are statically included in the exe
@REM get https://docs.microsoft.com/en-us/sysinternals/downloads/listdlls
@REM You'll need a first run with Listdlls.exe -accepteula
@REM Run test_exe_tests.bat
@REM In parallel, run Listdlls.exe imapsync|findstr Strawberry
@REM No line should be in the output

@REM Now imapsync can check this itself if Listdlls.exe is in its dir 
@REM .\imapsync.exe  --testsunit tests_check_binary_embed_all_dyn_libs

@REM CALL pp -o imapsync.exe  --link libeay32_.dll  --link zlib1_.dll --link ssleay32_.dll .\imapsync
@IF [%PROCESSOR_ARCHITECTURE%] == [x86] (
        @REM 32 bits
        @REM Do not add command after this one since it will anihilate the %ERRORLEVEL% of pp
        ECHO Building 32 bits binary PROCESSOR_ARCHITECTURE = %PROCESSOR_ARCHITECTURE%
        CALL pp -u -x -o imapsync.exe -M Test2::Formatter -M Test2::Formatter::TAP -M Test2::Event ^
                                --link zlib1_.dll ^
                                --link libcrypto-1_1_.dll ^
                                --link libssl-1_1_.dll ^
                                .\imapsync
) ELSE (
        @REM 64 bits
        @REM Do not add command after this one since it will anihilate the %ERRORLEVEL% of pp
        ECHO Building 64 bits binary PROCESSOR_ARCHITECTURE = %PROCESSOR_ARCHITECTURE%
        CALL pp --bundle --run --clean --compile --save --verbose 3 --compress 0 --execute --output imapsync.exe ^
                -M Test2::Formatter   -M Test2::Formatter::TAP -M Test2::Event ^
                -M Test2::EventFacet  -M Test2::Event::Pass ^
                -M Test2::Event::Fail -M Test2::Event::V2 ^
                --link  libcrypto-1_1-x64__.dll ^
                --link  zlib1__.dll ^
                --link  libssl-1_1-x64__.dll ^
                .\imapsync
)
@ENDLOCAL
EXIT /B


:testslive
@SETLOCAL
CALL .\imapsync.exe --testslive
@ENDLOCAL
EXIT /B

:tests
@SETLOCAL
CALL .\imapsync.exe --tests
@ENDLOCAL
EXIT /B


:tests_check_binary_embed_all_dyn_libs
@SETLOCAL
CALL .\imapsync.exe --testsunit tests_check_binary_embed_all_dyn_libs
@ENDLOCAL
EXIT /B





::------------------------------------------------------
::--------------- Copy with architecture name ----------
:copy_with_architecture_name
@SETLOCAL
IF [%PROCESSOR_ARCHITECTURE%] == [x86] (
        @REM 32 bits
        COPY /B .\imapsync.exe .\imapsync_32bit.exe
) ELSE (
        @REM 64 bits
        COPY /B .\imapsync.exe .\imapsync_64bit.exe
)
@ENDLOCAL
EXIT /B
::------------------------------------------------------

::------------------------------------------------------
::--------------- Copy with architecture name ----------
:rename_to_old
@SETLOCAL
IF EXIST imapsync_old.exe DEL imapsync_old.exe
IF EXIST imapsync.exe RENAME imapsync.exe imapsync_old.exe
@ENDLOCAL
EXIT /B
::------------------------------------------------------



::------------------------------------------------------
::--------------- Detect Perl --------------------------
:detect_perl
@SETLOCAL
perl -v
@ENDLOCAL
EXIT /B
::------------------------------------------------------


::------------------------------------------------------
::--------------- Check  modules are here --------------
:check_modules
@SETLOCAL
perl ^
     -mApp::cpanminus ^
     -mAuthen::NTLM ^
     -mCrypt::OpenSSL::RSA ^
     -mCrypt::SSLeay ^
     -mData::Dumper ^
     -mData::Uniqid ^
     -mDigest::HMAC_MD5 ^
     -mDigest::HMAC_SHA1 ^
     -mDigest::MD5 ^
     -mEncode ^
     -mEncode::Byte ^
     -mEncode::IMAPUTF7 ^
     -mFile::Copy::Recursive  ^
     -mFile::Spec ^
     -mFile::Tail ^
     -mGetopt::ArgvFile ^
     -mHTML::Entities ^
     -mIO::Socket ^
     -mIO::Socket::INET ^
     -mIO::Socket::INET6 ^
     -mIO::Socket::IP ^
     -mIO::Socket::SSL ^
     -mIO::Tee ^
     -mJSON ^
     -mJSON::WebToken ^
     -mLWP ^
     -mLWP::UserAgent ^
     -mMail::IMAPClient ^
     -mMIME::Base64 ^
     -mModule::ScanDeps ^
     ^
     -mNet::SSL ^
     -mNet::SSLeay ^
     -mPAR::Packer ^
     -mPod::Usage ^
     -mProc::ProcessTable ^
     -mReadonly ^
     -mRegexp::Common ^
     -mSocket6 ^
     -mSys::MemInfo ^
     -mTerm::ReadKey ^
     -mTest::MockObject ^
     -mTest::Pod ^
     -mTime::Local ^
     -mUnicode::String ^
     -mURI::Encode ^
     -mURI::Escape ^
     -e ''
IF ERRORLEVEL 1 CALL .\install_modules.bat
@ECHO Calling a second time to check all modules are now installed
perl ^
     -mApp::cpanminus ^
     -mAuthen::NTLM ^
     -mCrypt::OpenSSL::RSA ^
     -mCrypt::SSLeay ^
     -mData::Dumper ^
     -mData::Uniqid ^
     -mDigest::HMAC_MD5 ^
     -mDigest::HMAC_SHA1 ^
     -mDigest::MD5 ^
     -mEncode ^
     -mEncode::Byte ^
     -mEncode::IMAPUTF7 ^
     -mFile::Copy::Recursive  ^
     -mFile::Spec ^
     -mFile::Tail ^
     -mGetopt::ArgvFile ^
     -mHTML::Entities ^
     -mIO::Socket ^
     -mIO::Socket::INET ^
     -mIO::Socket::INET6 ^
     -mIO::Socket::IP ^
     -mIO::Socket::SSL ^
     -mIO::Tee ^
     -mJSON ^
     -mJSON::WebToken ^
     -mLWP ^
     -mLWP::UserAgent ^
     -mMail::IMAPClient ^
     -mMIME::Base64 ^
     -mModule::ScanDeps ^
     ^
     -mNet::SSL ^
     -mNet::SSLeay ^
     -mPAR::Packer ^
     -mPod::Usage ^
     -mProc::ProcessTable ^
     -mReadonly ^
     -mRegexp::Common ^
     -mSocket6 ^
     -mSys::MemInfo ^
     -mTerm::ReadKey ^
     -mTest::MockObject ^
     -mTest::Pod ^
     -mTime::Local ^
     -mUnicode::String ^
     -mURI::Encode ^
     -mURI::Escape ^
     -e ''
@ENDLOCAL
EXIT /B
::------------------------------------------------------





::------------------------------------------------------
::--------------- Handle error -------------------------
:handle_error
@SETLOCAL
ECHO IN %0 with parameters %*
%*
SET CMD_RETURN=%ERRORLEVEL%

IF %CMD_RETURN% EQU 0 (
        ECHO GOOD END
) ELSE (
        ECHO BAD END
        IF NOT EXIST LOG_bat MKDIR LOG_bat
        ECHO Failure calling: %* >> LOG_bat\%~nx0.txt
)
@ENDLOCAL
EXIT /B
::------------------------------------------------------
