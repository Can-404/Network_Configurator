@echo off
REM Install the .pfx certificate to Trusted Root Certification Authorities
certutil -addstore "Root" "%APPDATA%\YourApp\Certs\PublicCertificate.pfx"

if %ERRORLEVEL%==0 (
    del "%APPDATA%\YourApp\Certs\PublicCertificate.pfx"
    echo Certificate installed successfully and deleted.
) else (
    echo Certificate installation failed.
)