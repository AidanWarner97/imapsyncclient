REM $Id: install_modules.bat,v 1.44 2023/09/20 00:08:41 gilles Exp gilles $

::------------------------------------------------------
::--------------- Main of install_modules.bat ----------
@SETLOCAL
@ECHO OFF
ECHO Currently running through %0 %*

@REM Needed with remote ssh
SET SHELL=
SET
ECHO Installing Perl modules for imapsync

CD /D %~dp0

CALL :handle_error CALL :detect_perl
CALL :handle_error CALL :update_modules

@REM Do a PAUSE if run by double-click, aka, explorer (then ). No PAUSE in a DOS window or via ssh.
IF %0 EQU "%~dpnx0" IF "%SSH_CLIENT%"=="" PAUSE
@ENDLOCAL
EXIT /B


::------------------------------------------------------


::------------------------------------------------------
::--------------- Detect Perl --------------------------
:detect_perl
@SETLOCAL
perl -v
IF ERRORLEVEL 1 ECHO Perl needed. Install Strawberry Perl. Get it at http://strawberryperl.com/ ^
  && PAUSE && EXIT 3
ECHO perl is there
@ENDLOCAL
EXIT /B
::------------------------------------------------------


::------------------------------------------------------
::---------------- Update modules ----------------------
:update_modules
@SETLOCAL
FOR %%M in ( ^
 App::cpanminus ^
 Authen::NTLM ^
 Crypt::OpenSSL::RSA ^
 Crypt::SSLeay ^
 Data::Dumper ^
 Data::Uniqid ^
 Digest::HMAC_MD5 ^
 Digest::HMAC_SHA1 ^
 Digest::MD5 ^
 Encode ^
 Encode::Byte ^
 Encode::IMAPUTF7 ^
 File::Copy::Recursive ^
 File::Spec ^
 File::Tail ^
 Getopt::ArgvFile ^
 HTML::Entities ^
 IO::Socket ^
 IO::Socket::INET ^
 IO::Socket::INET6 ^
 IO::Socket::IP ^
 IO::Socket::SSL ^
 IO::Tee ^
 JSON ^
 JSON::WebToken ^
 LWP ^
 LWP::UserAgent ^
 Mail::IMAPClient ^
 MIME::Base64 ^
 Module::ScanDeps ^
 ^
 Net::SSL ^
 Net::SSLeay ^
 PAR::Packer ^
 Pod::Usage ^
 Proc::ProcessTable ^
 Readonly ^
 Regexp::Common ^
 Socket6 ^
 Sys::MemInfo ^
 Term::ReadKey ^
 Test::MockObject ^
 Test::Pod ^
 Time::Local ^
 Unicode::String ^
 URI::Encode ^
 URI::Escape ^

 ) DO @perl -m%%M -e "print qq{Updating %%M $%%M::VERSION \n}" ^
   & ECHO DOING cpanm %%M & cpanm %%M & ECHO DONE cpanm %%M 

ECHO Perl modules for imapsync updated
ECHO Revert Module::ScanDeps to release 1.31 since 1.33 sucks
cpanm https://cpan.metacpan.org/authors/id/R/RS/RSCHUPP/Module-ScanDeps-1.31.tar.gz
REM PAUSE
@REM @ECHO Net::Server::HTTP not updated

@ENDLOCAL
EXIT /B


::------------------------------------------------------


::------------------------------------------------------
::----------- Handle errors in LOG_bat\ directory ------
:handle_error
SETLOCAL
ECHO IN %0 with parameters %*
%*
SET CMD_RETURN=%ERRORLEVEL%

IF %CMD_RETURN% EQU 0 (
        ECHO GOOD END
) ELSE (
        ECHO BAD END
        IF NOT EXIST LOG_bat MKDIR LOG_bat
        ECHO Failure calling with extra %* >> LOG_bat\%~nx0.txt
)
ENDLOCAL
EXIT /B
::------------------------------------------------------

