@echo off
REM Install the .pfx certificate to Trusted Root Certification Authorities
certutil -addstore "Root" "C:\Program Files (x86)\NetCon\public.pfx"

if %ERRORLEVEL%==0 (
    del "C:\Program Files (x86)\NetCon\public.pfx"
    echo Certificate installed successfully.
) else (
    echo Certificate installation failed.
)