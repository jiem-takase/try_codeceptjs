::--------------------------------------------------
:: javaをバックグラウンドで動かすためにstartで呼ぶ
:: npx.cmdがexit /bで終わってないのでcallで呼ぶ
::--------------------------------------------------

start "!!killme!!" java -jar selenium-server-standalone-3.141.59.jar -role hub
start "!!killme!!" java -jar selenium-server-standalone-3.141.59.jar -role node -hub http://localhost:4444/grid/register
timeout /t 8 /nobreak >nul
call npx codeceptjs run --steps
@pause
start taskkill /im java.exe  /fi "WINDOWTITLE eq !!killme!!"
exit /b
