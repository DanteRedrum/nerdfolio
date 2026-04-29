# ARCHIVED — Environment specific installer script
# Technique: Copy software from network share then run silent installer
# This pattern was generalized into Install-SoftwareRemote.ps1
# Original environment: am_monroe file server, Micro Focus Reflection Desktop
#
# Copy-Item -Recurse -Path \\am_monroe\VOL1\Software\_reflection -Destination 'C:\Support Tools'
# Start-Process -FilePath 'C:\Support Tools\_reflection\rdesktop-16.1-prod-w32\setup.exe' -ArgumentList "/c /install /quiet"
