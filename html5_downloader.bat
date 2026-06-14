@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:reset
::pause
set "PDFBASE="
set "PDFNAME="
set "PDFNAMEINPUT="
set "IMAGES="
set "CLEAN_NAME="
set "INPUT="
set "char="
set "INDEX="
set "MAGICKINSTALL="
set "MAGICKPATH="
set "MAGICK_URL="
set "MAGICK_DIR="
set "maxPage="
set "fullurl="
set "baseURL="
set "format="
set "suffix="
set "FoundDisk="
if not exist temp mkdir temp
if not exist images mkdir images
if not exist pdf mkdir pdf
:: GÖRSELLERİ TEMİZLE
if exist images\*.* del /q images\*.*
if exist temp\*.* del /q temp\*.*
::::pause
:: parse_config.ps1 dosyasını temp klasörüne yaz
(
echo param (
echo     [string]$ConfigPath,
echo     [string]$BaseUrl
echo ^)
echo.
echo [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
echo.
echo $jsonText = Get-Content $ConfigPath -Raw -Encoding UTF8
echo.
echo # Hem n hem l yakalayacak regexler
echo $nMatches = [regex]::Matches($jsonText, '"n"\s*:\s*\[\s*"([^"]+^)"')
echo $lMatches = [regex]::Matches($jsonText, '"l"\s*:\s*"([^"]+^)"')
echo.
echo if ($nMatches.Count -eq 0 -and $lMatches.Count -eq 0^) {
echo.
echo     # temp klasörü yoksa oluştur
echo     if (-not (Test-Path "temp"^)^) {
echo         New-Item -ItemType Directory -Path "temp" ^| Out-Null
echo     ^}
echo.
echo     $consoleFile = Join-Path "temp" "console.js.txt"
echo.
echo @"
echo (function(^) {
echo     const baseUrl = "$BaseUrl";
echo     const pagesData = window.fliphtml5_pages ^|^| window.htmlConfig^?.fliphtml5_pages;
echo     let pageList = [];
echo.
echo     if (^^!^pagesData^) {
echo         console.log("fliphtml5_pages bulunamadi^!"^);
echo         return;
echo     ^}
echo.
echo     pagesData.forEach((page^) =^> {
echo         let path = "";
echo.
echo         if (page.n ^&^& typeof page.n === "string"^) {
echo             path = page.n;
echo         ^} else if (page.n ^&^& Array.isArray(page.n^)^) {
echo             path = page.n[0];
echo         ^} else if (typeof page === "string"^) {
echo             path = page;
echo         ^}
echo.
echo         if (path^) {
echo             const fullUrl =
echo                 baseUrl.replace(^/\/$/, ""^) + "/" +
echo                 path.replace(^/^^^\.^?\//, ""^);
echo             pageList.push(fullUrl^);
echo         ^}
echo     ^}^);
echo.
echo     const textContent = pageList.join("\n"^);
echo     const blob = new Blob([textContent], { type: "text/plain" ^}^);
echo     const link = document.createElement("a"^);
echo     link.href = URL.createObjectURL(blob^);
echo     link.download = "resim_url_listesi.txt";
echo     link.click(^);
echo.
echo     console.log("Islem tamam^! " + pageList.length + " sayfa linki hazirlandi."^);
echo ^}^)(^);
echo "@ | Set-Content -Path $consoleFile -Encoding UTF8
echo.
echo # Dosyayı aç
echo Start-Process $consoleFile
echo.
echo.
echo     Write-Host ""
echo     Write-Host "[ENCRYPTED] sayfa olabilir. Liste regex ile bulunamadi." -ForegroundColor Yellow
echo     Write-Host "Deneyimliyseniz Chrome > F12 > Ag (Network) > F5 ile sayfayi yenileyip" -ForegroundColor Yellow
echo     Write-Host "config.js sag tiklayip yeni sekmede acin ve fliphtml5_pages degeri encrypted mi bakin." -ForegroundColor Yellow
echo     Write-Host "Encrypted(Sifrelenmis) ise txt ile acilan kodu yonergeye gore kullanin." -ForegroundColor Yellow
echo     Write-Host "Encrypted degilse bu manuel gibi devam edecek." -ForegroundColor Yellow
echo     Write-Host "Ya linkleri indirip pdf yapmasini bekleyin. Ya da iptal edip manuel yontemi kullanabilirsiniz." -ForegroundColor Yellow
echo     Write-Host "temp klasorunde console.js.txt olusturulacak ve otomatik acilacak." -ForegroundColor Cyan
echo     Write-Host "Kodu kopyalayin ve Chrome'da linki https://online.fliphtml5.com/oxgto/dxua gibi acin." -ForegroundColor Magenta
echo     Write-Host "NOT: Linkin https://online.fliphtml5.com ile baslamasi gerekiyor" -ForegroundColor Magenta
echo     Write-Host "Chrome > F12 > Konsol (Console)'a yapistir ve ENTER'a bas." -ForegroundColor Cyan
echo     Write-Host "resim_url_listesi.txt dosyasi indirildigi an script klasore alacak ve indirmeler baslayacak." -ForegroundColor Cyan
echo     Write-Host "resim_url_listesi.txt dosyasini 10 dk bekleyecek. 10 dk sonunda hata verecek ve menuye donecek." -ForegroundColor Cyan
echo.
echo.
echo # -------------------------------
echo # Downloads klasörünü bul
echo # -------------------------------
echo $downloads = (Get-ItemProperty `
echo     "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" `
echo     -Name "{374DE290-123F-4565-9164-39C4925E467B}"
echo ^)."{374DE290-123F-4565-9164-39C4925E467B}"
echo.
echo $downloads = [Environment]::ExpandEnvironmentVariables($downloads^)
echo.
echo $downloadedFile = Join-Path $downloads "resim_url_listesi.txt"
echo $tempDir = "temp"
echo $tempFile = Join-Path $tempDir "resim_url_listesi.txt"
echo $imageDir = "images"
echo.
echo # -------------------------------
echo # Klasörleri hazırla
echo # -------------------------------
echo if (-not (Test-Path $tempDir^)^) {
echo     New-Item -ItemType Directory -Path $tempDir ^| Out-Null
echo ^}
echo.
echo if (-not (Test-Path $imageDir^)^) {
echo     New-Item -ItemType Directory -Path $imageDir ^| Out-Null
echo ^}
echo.
echo Write-Host ""
echo Write-Host "resim_url_listesi.txt bekleniyor..." -ForegroundColor Cyan
echo.
echo # -------------------------------
echo # Dosya inene kadar bekle
echo # -------------------------------
echo $timeout = 600
echo $elapsed = 0
echo.
echo while (-not (Test-Path $downloadedFile^)^) {
echo     Start-Sleep -Seconds 1
echo     $elapsed++
echo.
echo     if ($elapsed -ge $timeout^) {
echo         Write-Host "[HATA] Dosya Downloads klasorunde bulunamadi!" -ForegroundColor Red
echo         exit 1
echo     ^}
echo ^}
echo.
echo # -------------------------------
echo # Dosyayı temp'e taşı
echo # -------------------------------
echo Move-Item -Force $downloadedFile $tempFile
echo Write-Host "resim_url_listesi.txt temp klasorune tasindi." -ForegroundColor Green
echo.
echo # -------------------------------
echo # İndirme işlemi
echo # -------------------------------
echo Write-Host ""
echo Write-Host "Resimler indiriliyor..." -ForegroundColor Cyan
echo.
echo $counter = 1
echo Get-Content $tempFile ^| ForEach-Object {
echo.
echo     $url = $_.Trim(^)
echo     if (-not $url^) { return }
echo.
echo     try {
echo         $uri = [Uri]$url
echo         $ext = [IO.Path]::GetExtension($uri.AbsolutePath^)
echo         if (-not $ext^) { $ext = ".jpg" }
echo.
echo         $destFile = "$counter$ext"
echo         $destPath = Join-Path $imageDir $destFile
echo.
echo         Write-Host "indiriliyor: $url" -ForegroundColor Cyan
echo         Invoke-WebRequest -Uri $url -OutFile $destPath -UseBasicParsing -ErrorAction Stop
echo         Write-Host "indirildi: $destFile" -ForegroundColor Green
echo.
echo         $counter++
echo     ^}
echo     catch {
echo         Write-Warning "İndirme hatasi: $url"
echo     ^}
echo ^}
echo.
echo Write-Host ""
echo Write-Host "Tum indirmeler tamamlandi." -ForegroundColor Cyan
echo.
echo     exit 0
echo ^}
echo.
echo $outputLines = @(^)
echo if (-not (Test-Path "images"^)^) {
echo     New-Item -Path "images" -ItemType Directory ^| Out-Null
echo ^}
echo.
echo $counter = 1
echo.
echo # Önce nMatches işle (FlipHTML5^)
echo foreach ($match in $nMatches^) {
echo     $nPath = $match.Groups[1].Value -replace '\\/', '/'
echo     $fileName = [System.IO.Path]::GetFileName($nPath^)
echo.
echo     # FlipHTML5 için doğru yolu kur
echo     $fullUrl = $BaseUrl.TrimEnd('/'^) + "/files/large/" + $fileName
echo.
echo     Write-Host "indiriliyor: $fullUrl" -ForegroundColor Cyan
echo     $outputLines += $fullUrl
echo.
echo     $ext = [System.IO.Path]::GetExtension($fileName^)
echo     $destFile = "$counter$ext"
echo     $dest = Join-Path "images" $destFile
echo.
echo     try {
echo         Invoke-WebRequest -Uri $fullUrl -OutFile $dest -ErrorAction Stop
echo         Write-Host "indirildi: $destFile" -ForegroundColor Green
echo     ^}
echo     catch {
echo         Write-Warning "İndirme hatası: $fullUrl"
echo     ^}
echo     $counter++
echo ^}
echo.
echo # Sonra lMatches işle (PubHTML5^)
echo foreach ($match in $lMatches^) {
echo     $lPath = $match.Groups[1].Value -replace '\\/', '/'
echo.
echo     # l tam path içeriyor, doğrudan ekle
echo     $fullUrl = $BaseUrl.TrimEnd('/'^) + "/" + $lPath.TrimStart('/'^)
echo.
echo     Write-Host "indiriliyor: $fullUrl" -ForegroundColor Cyan
echo     $outputLines += $fullUrl
echo.
echo     $ext = [System.IO.Path]::GetExtension($lPath^)
echo     $destFile = "$counter$ext"
echo     $dest = Join-Path "images" $destFile
echo.
echo     try {
echo         Invoke-WebRequest -Uri $fullUrl -OutFile $dest -ErrorAction Stop
echo         Write-Host "indirildi: $destFile" -ForegroundColor Green
echo     ^}
echo     catch {
echo         Write-Warning "İndirme hatası: $fullUrl"
echo     ^}
echo     $counter++
echo ^}
echo.
echo # URL listesi dosyası yaz
echo $outputFile = Join-Path "temp" "resim_url_listesi.txt"
echo $outputLines ^| Set-Content -Encoding UTF8 $outputFile
echo Write-Host "URL listesi $outputFile olarak kaydedildi."
echo.
echo.
echo.
echo.
echo #https://online.fliphtml5.com/rzegl/nmro/
echo #{"n":[".\/files\/large\/1.webp"],"t":".\/files\/thumb\/1.webp"^}
echo #https://online.fliphtml5.com/tsyqb/btts/
echo #{"n":[".\/files\/large\/a56f6674a819cd352c59a856168782e6.webp"],"t":".\/files\/thumb\/f5a804049d5f1ab4cf21d99959b8065e.webp"^} ^<^<^<^< ama 1-2-3 diye indirmiyor.
echo #https://online.fliphtml5.com/rzegl/hmha/
echo #{"n":["04956e28e6d81411ed1b25856d58fe9f.webp"],"t":".\/files\/thumb\/a33a7d073834a04490ca0d7d2fae9133.webp"^}
echo #https://online.pubhtml5.com/uayrm/afol/
echo #{"n":["1289710aa849fac1a274ffa02854ffee.jpg"],"t":".\/files\/thumb\/30b0c064ca24da6d8731c12bde37b024.jpg"^}
echo #https://online.pubhtml5.com/mryp/pwik/
echo #{"l":"files/large/1.jpg","t":"files/thumb/1.jpg"^}
echo #https://online.pubhtml5.com/mryp/yeam/
echo #{"l":"files\/large\/1.jpg","t":"files\/thumb\/1.jpg"^}
) > temp\parse_config.ps1

::pause

:menu
cls
title HTML5 to PDF Creator - MENU

echo ===========================================================
echo             HTML5 to PDF Creator - MENU
echo ===========================================================
echo.
echo             NOT: PDF Dönüşümü için ImageMagick gereklidir.
echo             Önce 3. adımdan kurulum adımına bakınız.
echo.
echo ===========================================================
echo 1. FlipHTML5 - PubHTML5 PDF Creator
echo 2. Manuel (Otomatik URL Ayrıştırma) Z-Kitap PDF Creator
echo 3. Manuel Z-Kitap PDF Creator
echo 4. Images Klasöründekileri PDF yap
echo 5. IMAGEMAGICK Kurulum
echo 6. Çıkış
echo ===========================================================
set /p CHOICE=Seciminizi girin (1/2/3/4/5/6): 

if "%CHOICE%"=="1" goto fliphtml5
if "%CHOICE%"=="2" goto manuelotosplit
if "%CHOICE%"=="3" goto manualtektekellegir
if "%CHOICE%"=="4" goto imagesfoldertopdf
if "%CHOICE%"=="5" goto imagemagicksetup
if "%CHOICE%"=="6" exit
echo Geçersiz seçim. Tekrar deneyin.
pause
call :reset
goto menu

:imagemagicksetup
if not exist temp mkdir temp
if not exist images mkdir images
if not exist pdf mkdir pdf

:: Ön hazırlık: Magick kurulumu sor
echo ===========================================================
echo PDF DONUSTURMEK ICIN IMAGEMAGICK GEREKIR!
echo MAGICK kurulacaksa kurulum adımında ASAGIDAKILER TIKLI OLMALIDIR:
echo  ✔ Add application directory to your system path
echo  ✔ Install legacy utilities (e.g. identify)
echo Kurulum tamamlandıktan sonra PATH degiskenine su sekilde yol eklenecek: C:\Program Files\ImageMagick-X.Y.Z-Q16-HDRI
echo Diger secenekler istege baglidir.
echo ===========================================================

:askinstall
if not exist temp mkdir temp
if not exist images mkdir images
if not exist pdf mkdir pdf

echo ===========================================================
set /p MAGICKINSTALL=Magick indirilsin ve kurulsun mu? (E/H):

if /i "%MAGICKINSTALL%"=="E" (
    echo Magick son surum bilgisi aliniyor...
    goto magicksurumontrol
) else if /i "%MAGICKINSTALL%"=="H" (
    echo Kurulum atlandi.
    goto askpath
) else (
    echo Gecersiz secim. Lutfen sadece E ya da H girin.
    pause
    goto askinstall
)

:magicksurumontrol
rem PowerShell ile en son .exe dosyasinin URL'sini bul
for /f "usebackq delims=" %%i in (`powershell -Command ^
  "$url='https://imagemagick.org/archive/binaries/';" ^
  "$page=(Invoke-WebRequest -Uri $url).Content;" ^
  "$match=[regex]::Matches($page,'ImageMagick-[0-9\.\-]+-Q16-HDRI-x64-dll\.exe');" ^
  "if ($match.Count -gt 0) { $latest=$match[$match.Count-1].Value; Write-Output $url$latest }"`) do (
    set "MAGICK_URL=%%i"
)

if "%MAGICK_URL%"=="NOT_FOUND" (
    echo HATA: Uygun surum bulunamadi. URL yapisi degismis olabilir. 
	echo https://imagemagick.org/archive/binaries/ sayfasına gidip ImageMagick-X.Y.Z-Q16-HDRI.exe olanı indirip kurunuz.
    pause
    goto askpath
)

if "%MAGICK_URL%"=="ERROR" (
    echo HATA: Surum bilgisi alinirken bir hata olustu. Internet baglantinizi kontrol edin.
    pause
    goto askpath
)

echo Son surum bulundu: %MAGICK_URL%
echo Indiriliyor...

if exist temp\*.* del /q temp\*.*
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%MAGICK_URL%' -OutFile 'temp\imagemagick_installer.exe' -UseBasicParsing"

if not exist temp\imagemagick_installer.exe (
    echo HATA: Indirme basarisiz oldu!
    pause
    goto askpath
)

echo Kurulum baslatiliyor... Kurulum tamamlandiginda diger adimlara gecilecek.
start "" /wait "%CD%\temp\imagemagick_installer.exe"
echo Kurulum tamamlandi. Bir sonraki adima geciliyor.
pause
goto askpath
echo ===========================================================


:askpath
echo ===========================================================
set /p MAGICKPATH=Magick Sistem Ortam Değişkenlerine eklensin mi? (E/H):
if /i "%MAGICKPATH%"=="E" (
    echo Magick dizini araniyor...
    goto askpathsearchdir
) else if /i "%MAGICKPATH%"=="H" (
    echo Path ayari atlandi.
    pause
    goto magickontrol
) else (
    echo Gecersiz secim. Lutfen sadece E ya da H girin.
    pause
    goto askpath
)

:askpathsearchdir
rem ImageMagick yuklu dizini otomatik bul
set "MAGICK_DIR="
for /f "usebackq delims=" %%j in (`powershell -Command ^
    "Get-ChildItem 'C:\Program Files' -Directory | Where-Object { $_.Name -like 'ImageMagick-*-Q16-HDRI' } | Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName"`) do (
    set "MAGICK_DIR=%%j"
)

if not defined MAGICK_DIR (
    echo ❌ HATA: ImageMagick dizini bulunamadi.
    echo Lutfen ImageMagick'in 'C:\Program Files' klasorune kuruldugundan emin olun.
    echo Menüye dönebilirsiniz.
    pause
    goto magickontrol
)

echo ✅ Bulunan Magick dizini: %MAGICK_DIR%

rem Kalici PATH ekleme (kayit defteri)
powershell -Command ^
    "$p=[Environment]::GetEnvironmentVariable('Path','User'); if ($p -notlike '*%MAGICK_DIR%*') { [Environment]::SetEnvironmentVariable('Path', $p + ';%MAGICK_DIR%', 'User') }"

rem Gecici PATH ekleme (mevcut CMD oturumu icin)
set "PATH=%PATH%;%MAGICK_DIR%"
	
echo ===========================================================
echo ===========================================================
echo PATH BİLGİSİ TAMAMLANDI. MAGICK PATH'E EKLENDI!
echo Kurulumdan sonra yeni bir Komut İstemi "(CMD)" açıp sadece magick yazın.
echo Eğer PATH'e doğru eklendiyse, magick hakkında bilgiler göreceksiniz; hata mesajı almazsınız.

echo ===========================================================
echo ===========================================================
echo ===========================================================
goto magickontrol

:magickontrol
where magick >nul 2>nul
if errorlevel 1 (
    echo ===========================================================
    echo Magick bulunamadi. PATH eklenmemis olabilir.
    echo Kurulum adimina gecilecek.
    echo Indirme yapmadan Path ayarini guncelleyebilirsiniz.
    echo ===========================================================
    echo ===========================================================
    echo ====================    ONEMLI    ===========================
    echo ===========================================================
    echo ===========================================================
    echo Bu islemden sonra Scripti kapatip tekrar aciniz.
    echo Aksi durumda "Magick dogru sekilde PATH'e eklenmis" dongusune girecektir.
    echo ===========================================================
    echo Bu islemden sonra Scripti kapatip tekrar aciniz.
    echo Aksi durumda "Magick dogru sekilde PATH'e eklenmis" dongusune girecektir.
    echo ===========================================================
    echo Bu islemden sonra Scripti kapatip tekrar aciniz.
    echo Aksi durumda "Magick dogru sekilde PATH'e eklenmis" dongusune girecektir.
    echo ===========================================================
    pause
	goto imagemagicksetup
) else (
    echo ===========================================================
    echo Magick dogru sekilde PATH'e eklenmis.
    echo ===========================================================
    pause
)
echo ===========================================================
goto menu

:fliphtml5
if not exist temp mkdir temp
if not exist images mkdir images
if not exist pdf mkdir pdf
:: GÖRSELLERİ TEMİZLE
::if exist images\*.* del /q images\*.*
::if exist temp\*.* del /q temp\*.*

:: Ön hazırlık: Magick kurulumu sor
echo ===========================================================
echo PDF DONUSTURMEK ICIN IMAGEMAGICK GEREKIR!
echo MAGICK kurulmadıysa menüye dönüp kurunuz.
echo ===========================================================
echo DESTEKLENEN URL ÖRNEKLERİ:
echo  ✔ https://fliphtml5.com/bvgyx/skua/
echo  ✔ https://fliphtml5.com/bvgyx/skua/Coastal_Delights_2025_%28R%29/
echo  ✔ https://fliphtml5.com/agdey/bfym/2025_TT_B%C4%B0NAL%C4%B0_YILDIRIM_DERG%C4%B0_2_kopyas%C4%B1_%285%29/
echo  ✔ https://online.fliphtml5.com/rzegl/yxts/
echo  ✔ https://pubhtml5.com/uayrm/afol/
echo  ✔ https://pubhtml5.com/wnsyv/dymw/GRAMMAR_IN_USE_5_Edition/
echo  ✔ https://online.pubhtml5.com/uayrm/afol/
echo.
echo ===========================================================
echo BASE URL ÖRNEKLERİ:
echo  ✔ https://online.fliphtml5.com/rzegl/yxts/
echo  ✔ https://online.pubhtml5.com/uayrm/afol/
echo.
set /p URL=URL'yi girin: 
if "%URL:~-1%"=="/" set URL=%URL:~0,-1%

echo Girilen URL: %URL%
echo URL düzenleniyor...

:: Domain kontrolü yap
echo %URL% | findstr /i "fliphtml5.com" >nul
if %errorlevel%==0 (
    :: FlipHTML5 için online.fliphtml5.com'a çevir
    set URL=%URL:https://fliphtml5.com/=https://online.fliphtml5.com/%
)

echo %URL% | findstr /i "pubhtml5.com" >nul
if %errorlevel%==0 (
    :: PubHTML5 için online.pubhtml5.com'a çevir
    set URL=%URL:https://pubhtml5.com/=https://online.pubhtml5.com/%
)

echo Kullanılacak URL: %URL%

:: https:// kısmını at (8 karakter)
for /f "tokens=1* delims=/" %%a in ("%URL:~8%") do set "AFTER_DOMAIN=%%b"

:: İlk iki segmenti al (token1 = udqwy, token2 = bavp)
for /f "tokens=1,2 delims=/" %%a in ("%AFTER_DOMAIN%") do (
    set "SEG1=%%a"
    set "SEG2=%%b"
)

:: Domain kısmını al (https://online.fliphtml5.com veya https://online.pubhtml5.com)
for /f "tokens=1,2 delims=/" %%a in ("%URL:~8%") do set "DOMAIN=https://%%a"

:: BASEURLSALT oluştur
set "BASEURL=%DOMAIN%/%SEG1%/%SEG2%"

echo Kullanılacak BASEURL: %BASEURL%
echo ===========================================================

echo Config dosyası indiriliyor...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%BASEURL%/javascript/config.js' -OutFile 'temp\config.js' -UseBasicParsing"

if not exist temp\config.js (
    echo Config dosyası indirilemedi.
    pause
    exit /b
)
echo ===========================================================
echo Resimler listeleniyor...
::echo %~dp0 < bunda \ var sonda
::echo %CD%

powershell -ExecutionPolicy Bypass -File "%~dp0temp\parse_config.ps1" -ConfigPath "temp\config.js" -BaseUrl "%BASEURL%"

if errorlevel 1 (
    echo.
    echo [HATA] Resimler indirilemedi!
    echo PDF olusturma adimina gecilmiyor.
    echo Menuye donuluyor...
    pause
    goto menu
)


echo ===========================================================
echo.
echo Indirme tamamlandi. PDF olusturulacak...
goto pdfolustur


:manuelotosplit
if not exist temp mkdir temp
if not exist images mkdir images
if not exist pdf mkdir pdf
:: GÖRSELLERİ TEMİZLE
::if exist images\*.* del /q images\*.*
::if exist temp\*.* del /q temp\*.*

:: Ön hazırlık: Magick kurulumu sor
echo ===========================================================
echo PDF DONUSTURMEK ICIN IMAGEMAGICK GEREKIR!
echo MAGICK kurulmadıysa menüye dönüp kurunuz.
echo ===========================================================
echo KULLANIM YÖNTEMİ
echo  ✔ https://www.ataekitap.com gibi sitelerden e-kitap veya z-kitap açılır. Iframe içerisindeyse de iframe linkini bulmak gerekiyor.
echo  ✔ F12 Geliştirici Araçlarında (CTRL "+" Üst "+" I) Ağ sekmesi size yardımcı olacaktır. 
echo  ✔ Z-Kitaplarda sayfaları ilerledikçe ağ kısmında yüklenen öğeler görülecek. Gerekirse F5 yaparak sayfayı yenileyin ve inceleyin.
echo  ✔ 6.jpg, 5.jpeg, 10.png gibi öğeler sayfanın görüntüsü olabilir. Üzerine tıklarsanız önizlemede görebilirsiniz.
echo  ✔ Doğru resmi bulduğunuzda sağ tıklayıp yeni sekmede aç dediğinizde alttaki gibi link elde edersiniz.
echo  ✔ https://www.ataekitap.com/e-kitaplar/2024-2025-Ekitap/Okul_Oncesi/Okul_Yolculugum/Okul_Yolculugu_1_Kitap/files/mobile/1.jpg?240723105533
echo  ✔ https://www.aydindijital.com//Media/UserData/bookimages/424e692c-e532-4752-80d8-1ce0d7969218/Page1.png
echo  ✔ Linki aldıktan sonra z-kitabın toplam kaç sayfa olduğuna bakıyoruz.
echo  ✔ Sonrasında sayfa numarası önündeki kısım baseURL, sayfa numarası sonrası URL sonundaki sabit kısım, sayfa numarasından sonraki noktadan sonraki dosya formatıdır.
echo  ✔ Bu bilgilerle birlikte kitap sayfa sayısı sırayla girildikten sonra sayfalar indirilmeye başlanacak ve PDF yapılacak.
echo  ✔ ÖNEMLİ NOTLAR
echo  ✔ NOT: Kod satırımız resim linkini yapıştırdığınızda .jpg .jpeg .png .webp durumuna göre baseURL, format, suffix değerlerini bulacaktır. Sonrasında kitabın sayfa sayısını soracaktır. 
echo  ✔ NOT: Linkimiz blob:https://www.lisedestek.com/5246b6f8-9e49-45d4-85c1-10c1bbae357b gibiyse üzerinde yöntem geliştirmedim. Tek tek manuel sayfa numarası şeklinde resmi kaydedip PDF yapıyoruz.
echo  ✔ NOT: Fernus bookzkitap sayfaları şifreli veya indirilemeyecek durumda. En iyi ihtimalle tek tek indirip PDF yapılabilir.
echo  ✔ NOT: https://dijital.5renkyayinevi.com/ gibi sayfalardaki z-kitaplar açıldığında Geliştirici Araçlarında Ağ kısmında doğrudan PDF yolu bulunabiliyor.

echo.
echo ===========================================================
::MANUEL baseurl format suffix girişi
::echo Ornek: https://online.fliphtml5.com/rzegl/nmro/files/large/
::echo Ornek: https://www.ataekitap.com/e-kitaplar/2024-2025-Ekitap/Okul_Oncesi/Okul_Yolculugum/Okul_Yolculugu_1_Kitap/files/mobile/
::echo Ornek: https://www.aydindijital.com//Media/UserData/bookimages/424e692c-e532-4752-80d8-1ce0d7969218/Page
::echo.

::set /p baseURL=Baslangic URL'yi gir (sayfa numarasi olmadan): 
::echo Ornek format: webp
::echo Ornek format: jpg
::echo Ornek format: jpeg
::echo Ornek format: png
::echo.
::set /p format=Dosya formatini girin (webp/jpg/png): 

::echo Ornek: ?1655277345^&1655277345
::echo Ornek: ?240723105533
::echo Ornek: (bos birakabilirsiniz)
::echo.
::set /p suffix=URL sonundaki sabit kisim (yoksa bos birakin): 


::OTOMATİK baseurl format suffix tespiti
::@echo off
::setlocal enabledelayedexpansion
echo.
echo   ✔ Örnek: "https://online.fliphtml5.com/rzegl/nmro/files/large/4.webp?1655277345&1655277345"
echo   ✔ Örnek: https://akilli-tahta.ogretmenevde.com/paket_icerik/1sinif-okuma-yazma-seti/OKUYORUM/app/sayfalar/(1).webp
echo   ✔ Örnek: https://akilli-tahta.ogretmenevde.com/paket_icerik/1sinif-okuma-yazma-seti/OKUYORUM/app/sayfalar/(1).webp?240723105533
echo   ✔ Örnek: https://www.aydindijital.com//Media/UserData/bookimages/424e692c-e532-4752-80d8-1ce0d7969218/Page1.png
echo.

set /p "fullurl=Örnek URL'yi girin (örneğin: https://.../1.jpg?...): "
for /f "tokens=1-3 delims=|" %%a in ('powershell -nologo -command "$u='%fullurl%';$m=[regex]::Match($u,'\d+(?=[^/]*\.(jpg|jpeg|png|webp))');if($m.Success){$base=$u.Substring(0,$m.Index);$after=$u.Substring($m.Index+$m.Length);$e=[regex]::Match($after,'\.(jpg|jpeg|png|webp)');$format=$e.Groups[1].Value;$suffix=$after;Write-Output ($base+'|'+$format+'|'+$suffix)}else{Write-Output 'HATA - Ayrım başarısız||'}"') do (set "baseURL=%%a" & set "format=%%b" & set "suffix=%%c")
::Bu eski ayırma yöntemi. base + format + suffix olarak ayırıyor
::Alt kısımda bununla güncelle    set "url=!baseURL!%%i.%format%!suffix!"
::for /f "tokens=1-3 delims=|" %%a in ('powershell -nologo -command "$url='%fullurl%'; if ($url -match '^(.*/)([^0-9/]*)(\d+\.(jpg|jpeg|png|webp))(\?.*)?$') { $base = $Matches[1] + $Matches[2]; $format = $Matches[4]; $suffix = $Matches[5]; if (-not $suffix) { $suffix = '' }; Write-Output ($base + '|' + $format + '|' + $suffix) } else { Write-Output 'HATA - Ayrım başarısız||' }"') do (set "baseURL=%%a" & set "format=%%b" & set "suffix=%%c")

echo.
echo baseURL = !baseURL!
echo format  = !format!
echo suffix  = !suffix!
echo.

if "!baseURL!"=="HATA - Ayrım başarısız" (
    echo.
    echo HATA: URL uygun formatta değil. Lütfen örneğe uygun bir bağlantı girin.
    pause
    goto manualotomatik
)

:: ==================== ÖRNEK URL GÖSTER ====================
echo.
echo -----------------------------------------------------------
echo   🔍 Örnek URL:
echo   %baseURL%1%suffix%
echo -----------------------------------------------------------
echo.
choice /m "Bu örnek doğru mu?"
if errorlevel 2 goto manuelotosplit

goto GET_MAXPAGE


:manualtektekellegir
if not exist temp mkdir temp
if not exist images mkdir images
if not exist pdf mkdir pdf
:: GÖRSELLERİ TEMİZLE
::if exist images\*.* del /q images\*.*
::if exist temp\*.* del /q temp\*.*

:: Ön hazırlık: Magick kurulumu sor
echo ===========================================================
echo PDF DONUSTURMEK ICIN IMAGEMAGICK GEREKIR!
echo MAGICK kurulmadıysa menüye dönüp kurunuz.
echo ===========================================================
echo KULLANIM YÖNTEMİ
echo  ✔ https://www.ataekitap.com gibi sitelerden e-kitap veya z-kitap açılır. Iframe içerisindeyse de iframe linkini bulmak gerekiyor.
echo  ✔ F12 Geliştirici Araçlarında (CTRL "+" Üst "+" I) Ağ sekmesi size yardımcı olacaktır. 
echo  ✔ Z-Kitaplarda sayfaları ilerledikçe ağ kısmında yüklenen öğeler görülecek. Gerekirse F5 yaparak sayfayı yenileyin ve inceleyin.
echo  ✔ 6.jpg, 5.jpeg, 10.png gibi öğeler sayfanın görüntüsü olabilir. Üzerine tıklarsanız önizlemede görebilirsiniz.
echo  ✔ Doğru resmi bulduğunuzda sağ tıklayıp yeni sekmede aç dediğinizde alttaki gibi link elde edersiniz.
echo  ✔ https://akilli-tahta.ogretmenevde.com/paket_icerik/1sinif-okuma-yazma-seti/OKUYORUM/app/sayfalar/(1).webp
echo  ✔ Linki aldıktan sonra z-kitabın toplam kaç sayfa olduğuna bakıyoruz.
echo  ✔ Sonrasında sayfa numarası önündeki kısım baseURL, sayfa numarası sonrası URL sonundaki sabit kısım, sayfa numarasından sonraki noktadan sonraki dosya formatıdır.
echo  ✔ Bu bilgilerle birlikte kitap sayfa sayısı sırayla girildikten sonra sayfalar indirilmeye başlanacak ve PDF yapılacak.
echo  ✔ ÖNEMLİ NOTLAR
echo  ✔ NOT: Kod satırımız resim linkinin bölümlerini ayrı ayrı isteyecektir. Sonrasında kitabın sayfa sayısını soracaktır. 
echo  ✔ NOT: Linkimiz blob:https://www.lisedestek.com/5246b6f8-9e49-45d4-85c1-10c1bbae357b gibiyse üzerinde yöntem geliştirmedim. Tek tek manuel sayfa numarası şeklinde resmi kaydedip PDF yapıyoruz.
echo  ✔ NOT: Fernus bookzkitap sayfaları şifreli veya indirilemeyecek durumda. En iyi ihtimalle tek tek indirip PDF yapılabilir.
echo  ✔ NOT: https://dijital.5renkyayinevi.com/ gibi sayfalardaki z-kitaplar açıldığında Geliştirici Araçlarında Ağ kısmında doğrudan PDF yolu bulunabiliyor.

echo.
echo ===========================================================
::MANUEL baseurl format suffix girişi
::echo Ornek: https://online.fliphtml5.com/rzegl/nmro/files/large/
::echo Ornek: https://www.ataekitap.com/e-kitaplar/2024-2025-Ekitap/Okul_Oncesi/Okul_Yolculugum/Okul_Yolculugu_1_Kitap/files/mobile/
::echo Ornek: https://www.aydindijital.com//Media/UserData/bookimages/424e692c-e532-4752-80d8-1ce0d7969218/Page
::echo.

::set /p baseURL=Baslangic URL'yi gir (sayfa numarasi olmadan): 
::echo Ornek format: webp
::echo Ornek format: jpg
::echo Ornek format: jpeg
::echo Ornek format: png
::echo.
::set /p format=Dosya formatini girin (webp/jpg/png): 

::echo Ornek: ?1655277345^&1655277345
::echo Ornek: ?240723105533
::echo Ornek: (bos birakabilirsiniz)
::echo.
::set /p suffix=URL sonundaki sabit kisim (yoksa bos birakin): 


::OTOMATİK baseurl format suffix tespiti
::@echo off
::setlocal enabledelayedexpansion
echo.
echo   Bu mod, sayfa numarasıyla iki parçaya ayrılabilen linkleri indirir.
echo   test4asf.webp gibi sonla biten dosyalarda 4 öncesi ve 4 sonrası olarak iki parçaya ayrılır.
echo   ✔ Örnek: https://akilli-tahta.ogretmenevde.com/paket_icerik/1sinif-okuma-yazma-seti/OKUYORUM/app/sayfalar/(1).webp
echo   ✔ Örnek: https://akilli-tahta.ogretmenevde.com/paket_icerik/1sinif-okuma-yazma-seti/OKUYORUM/app/sayfalar/1.webp?=1231241241   
echo   ✔ Örnek: https://akilli-tahta.ogretmenevde.com/paket_icerik/1sinif-okuma-yazma-seti/OKUYORUM/app/sayfalar/test1.webp?=1231241241  
echo   ✔ Örnek: https://akilli-tahta.ogretmenevde.com/paket_icerik/1sinif-okuma-yazma-seti/OKUYORUM/app/sayfalar/test1asf.webp?=1231241241 
echo.
echo   Linkin sayfa numarasindan onceki ve sonraki kisimlarini asagida girin.
echo.

set "baseURL="
set "suffix="
set "format="

echo   🔍 Önemli: Linkteki (1).webp gibi sonundaki 1 gibi sayfa numarasının solundaki tüm kısım girilecek.
echo.
set /p "baseURL=🔹 URL'nin sayfa numarasından önceki kısmı: "
if "%baseURL%"=="" (
    echo ❌ Hata: Ön kısım boş bırakılamaz!
    pause
    goto manualtektekellegir
)
echo   🔍 Önemli: Linkteki (1).webp gibi sonundaki 1 gibi sayfa numarasının sağındaki tüm kısım girilecek.
echo.
set /p "suffix=🔹 URL'nin sayfa numarasından sonraki kısmı: "
if "%suffix%"=="" (
    echo ❌ Hata: Son kısım boş bırakılamaz!
    pause
    goto manualtektekellegir
)

set /p "format=🔹 Dosya formatı (jpg/png/webp): "

if "%format%"=="" (
    echo ❌ Hata: Format boş bırakılamaz!
    pause
    goto manualtektekellegir
)

:: ==================== ÖRNEK URL GÖSTER ====================
echo.
echo -----------------------------------------------------------
echo   🔍 Örnek URL:
echo   %baseURL%1%suffix%
echo -----------------------------------------------------------
echo.
choice /m "Bu örnek doğru mu?"
if errorlevel 2 goto manualtektekellegir

goto GET_MAXPAGE


:imagesfoldertopdf
echo ============================================================
echo  BILGILENDIRME:
echo ------------------------------------------------------------
echo  Bu script calistiginda mevcut 'images' klasoru varsa içindekiler silinir.
echo  Daha sonra olusturulacak PDF icin resim dosyalari bu klasore manuel olarak eklenmelidir.
echo ------------------------------------------------------------
echo  Yani:
echo   1. Scripti calistirin.
echo   2. 'images' klasorunun içerisine resimleri kopyalayın. (Yedek olması her zaman iyidir.)
echo   4. Sonra devam edin.
echo ============================================================
echo.
pause

goto imagestopdf

::********************************************SON KISIMLAR********************************************
::********************************************SON KISIMLAR********************************************
::********************************************SON KISIMLAR********************************************
::********************************************SON KISIMLAR********************************************

:GET_MAXPAGE
set "maxPage="
set /p "maxPage=Kitap kaç sayfa? (örnek: 146): "
if not defined maxPage (
    echo Hata: Bu alan boş bırakılamaz!
    goto GET_MAXPAGE
)
echo %maxPage%|findstr /r "^[0-9][0-9]*$">nul
if not errorlevel 1 (
	if %maxPage% LSS 1 (
        echo Hata: Sayfa sayısı 1 veya daha büyük sayı olmalıdır.
        goto GET_MAXPAGE
    )
    echo Girdiğiniz sayfa sayısı: %maxPage%
    goto VALID_INPUT
)
echo Hata: Sayfa sayısı 1 veya daha büyük sayı olmalıdır.
goto GET_MAXPAGE

:VALID_INPUT

echo Resimler indiriliyor...

for /L %%i in (1,1,%maxPage%) do (
    set "url=!baseURL!%%i!suffix!"
    echo Indiriliyor: !url!
    powershell -Command "Invoke-WebRequest -Uri '!url!' -OutFile 'images\%%i.%format%'"
	echo indirildi: %%i.%format%
)

echo ===========================================================
echo.
echo Indirme tamamlandi. PDF olusturuluyor...

:imagestopdf 
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path 'images' -File | Sort-Object {[int]([regex]::Match($_.BaseName,'\d+$').Value)} | ForEach-Object { Add-Content -Path 'temp\\filelist.txt' -Value ('\"images\\' + $_.Name + '\"') }"

goto pdfdosyaadi

:pdfolustur
echo ===========================================================
echo PDF icin dosya listesi hazirlaniyor...
echo.

:: images klasoru var mi?
if not exist "images\" (
    echo [HATA] images klasoru bulunamadi!
    goto menu
)

:: icinde hic resim var mi?
dir /b "images\*" >nul 2>&1 || (
    echo [HATA] images klasoru bos!
    goto menu
)

:: filelist.txt varsa sifirla
if exist "temp\filelist.txt" del /f /q "temp\filelist.txt"

:: Listeyi sıfırla
::del /f /q temp\filelist.txt >nul 2>&1

::PDF OLUŞTURMA YOLU (önce txtye FullName olarak alfabetik yazar. Sonra magick ile oluşturur.)
:: PowerShell ile sıralı dosya listesini oluştur
::powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path 'images' | Where-Object { -Not $_.PSIsContainer } | Sort-Object { [int]($_.BaseName) } | ForEach-Object { Add-Content -Path 'temp\\filelist.txt' -Value ('\"images\' + $_.Name + '\"') }"

::Üstteki filelist.txt dosyası kilitlendiği için açamayınca 40 kadar dosya adını yazamamıştı. Alttakini deniyorum.
::powershell -NoProfile -ExecutionPolicy Bypass -Command "$out='temp\filelist.txt'; Get-ChildItem 'images' -File | Sort-Object { [int]($_.BaseName) } | ForEach-Object { '\"images\' + $_.Name + '\"' } | Out-File -FilePath $out -Encoding UTF8"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$out='temp\filelist.txt'; Get-ChildItem 'images' -File | Where-Object { $_.BaseName -match '^\d+$' } | Sort-Object { [int]$_.BaseName } | ForEach-Object { '\"images\' + $_.Name + '\"' } | Set-Content -Path $out -Encoding Ascii"
echo.
echo "Add-Content : Akış okunabilir değildi." hatası verirse dosya yazma isleminde hata olustugundan menuye don ve bastan basla.
echo.

::powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path 'images' | Where-Object { -Not $_.PSIsContainer } | Sort-Object { [int]($_.BaseName) } | ForEach-Object { Add-Content -Path 'temp\\filelist.txt' -Value ('\"images\' + $_.FullName  + '\"') }"


::FARKLI BİR PDF OLUŞTURMA YOLU (önce txtye Name olarak alfabetik yazar. IMAGES tanımını filelist.txt olarak atar. Sonra magick ile oluşturur.)
:: filelist.txt içine sadece göreli yol (images\1.jpg) yaz
::powershell -NoProfile -ExecutionPolicy Bypass -Command ^
::  "Get-ChildItem -Path 'images' | Where-Object { -Not $_.PSIsContainer } | Sort-Object { [int]($_.BaseName) } | ForEach-Object { Add-Content -Path 'temp\\filelist.txt' -Value ('\"images\\' + $_.Name + '\"') }"


:: filelist.txt'ten sırayla al, %IMAGES%'e yaz
::set "IMAGES="
::for /f "usebackq delims=" %%f in ("temp\filelist.txt") do (
::    set "IMAGES=!IMAGES! %%f"
::)
:: PowerShell hata verdi mi?
IF ERRORLEVEL 1 (
    echo [HATA] Dosya listesi olusturulamadi!
    goto menu
)


:pdfdosyaadi

if not exist pdf mkdir pdf



:: PDF dosya adını al
set /p PDFNAMEINPUT=Olusturulacak PDF dosya adi ne olsun? (Enter = output): 

if "%PDFNAMEINPUT%"=="" (
    set "PDFBASE=output"
) else (
    set "INPUT=%PDFNAMEINPUT%"
    set "CLEAN_NAME="

    :clean_loop
    set "char=!INPUT:~0,1!"
    set "INPUT=!INPUT:~1!"

    :: Türkçe karakter dönüşümü
    if "!char!"=="ç" set "char=c"
    if "!char!"=="Ç" set "char=C"
    if "!char!"=="ğ" set "char=g"
    if "!char!"=="Ğ" set "char=G"
    if "!char!"=="ı" set "char=i"
    if "!char!"=="İ" set "char=I"
    if "!char!"=="ö" set "char=o"
    if "!char!"=="Ö" set "char=O"
    if "!char!"=="ş" set "char=s"
    if "!char!"=="Ş" set "char=S"
    if "!char!"=="ü" set "char=u"
    if "!char!"=="Ü" set "char=U"

    :: Geçerli karakter kontrolü (harf, rakam, alt tire, eksi)
    echo !char!|findstr /r "[a-zA-Z0-9_-]" >nul
    if !errorlevel! equ 0 (
        set "CLEAN_NAME=!CLEAN_NAME!!char!"
    ) else (
        set "CLEAN_NAME=!CLEAN_NAME!_"
    )

    if not "!INPUT!"=="" goto clean_loop
    set "PDFBASE=!CLEAN_NAME!"
)

:: Uzantı .pdf mi? Değilse ekle (son 4 karaktere bak)
if /i not "%PDFBASE:~-4%"==".pdf" (
    set "PDFBASE=%PDFBASE%.pdf"
)

:: Dosya varsa _1, _2 şeklinde ilerle
set "INDEX=0"
set "BASE_NO_EXT=%PDFBASE%"
if /i "%PDFBASE:~-4%"==".pdf" set "BASE_NO_EXT=%PDFBASE:~0,-4%"

set "PDFNAME=%PDFBASE%"

:findpdfname
if exist "pdf\%PDFNAME%" (
    set /a INDEX+=1
    set "PDFNAME=%BASE_NO_EXT%_!INDEX!.pdf"
    goto findpdfname
)

::Magick Temp Klasörünü değiştir
::ImageMagick aslında %TEMP%’i kullanır, yani C:\Users\<kullanıcı>\AppData\Local\Temp.
::set MAGICK_TMPDIR=D:\IMTemp

::Kalıcı yapmak (sabit çözüm)
:::Win + R → sysdm.cpl → Gelişmiş sekmesi → Ortam Değişkenleri
::Yeni bir sistem değişkeni ekle:
::Değişken adı: MAGICK_TMPDIR
::Değişken değeri: D:\IMTemp
::Sonra bilgisayarı yeniden başlat. Artık ImageMagick hep oraya yazacak.

::set MAGICK_TMPDIR=D:\IMTemp
:: D sürücüsü varsa ve erişilebiliyorsa
::if exist Z:\ (
::    if not exist "D:\IMTemp" (
::        mkdir "D:\IMTemp"
::    )
::    echo D: sürücüsü sabit disk olarak bulundu.
::    if not exist "D:\IMTemp" mkdir "D:\IMTemp"
::    set "MAGICK_TMPDIR=D:\IMTemp"
::    echo MAGICK_TMPDIR ayarlandı: !MAGICK_TMPDIR!
::) else (
::    echo D: sürücüsü yok veya CD/USB tipi.
::    set "MAGICK_TMPDIR=%~dp0temp"
::    echo MAGICK_TMPDIR ayarlandı: !MAGICK_TMPDIR!
::)



::WMIC ile D diski kontrolü
::for /f "tokens=2 delims==" %%A in ('wmic logicaldisk where "DeviceID='D:' and DriveType=3" get DeviceID /value 2^>nul') do set D_DRIVE=%%A
::if defined D_DRIVE (
::    echo D: sürücüsü sabit disk olarak bulundu.
::    if not exist "D:\IMTemp" mkdir "D:\IMTemp"
::    set "MAGICK_TMPDIR=D:\IMTemp"
::    echo MAGICK_TMPDIR ayarlandı: !MAGICK_TMPDIR!
::) else (
::    echo D: sürücüsü yok veya CD/USB tipi.
::    set "MAGICK_TMPDIR=%~dp0temp"
::    echo MAGICK_TMPDIR ayarlandı: !MAGICK_TMPDIR!
::)




::Powershell ile D diski kontrolü
::powershell -Command "if (Test-Path 'D:\') { exit 0 } else { exit 1 }"
::if %errorlevel%==0 (
::    echo D: sürücüsü sabit disk olarak bulundu.
::    if not exist "D:\IMTemp" mkdir "D:\IMTemp"
::    set "MAGICK_TMPDIR=D:\IMTemp"
::    echo MAGICK_TMPDIR ayarlandı: !MAGICK_TMPDIR!
::) else (
::    echo D: sürücüsü yok veya CD/USB tipi.
::    set "MAGICK_TMPDIR=%~dp0temp"
::    echo MAGICK_TMPDIR ayarlandı: !MAGICK_TMPDIR!
::)


::Powershell ile D diski kontrolü
:: D sürücüsünü kontrol et
::for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DeviceID -eq 'D:' } | Select-Object -ExpandProperty DriveType"`) do set "DriveType=%%A"

:: DriveType değerini yazdır
::echo DriveType: %DriveType%

:: Local disk kontrolü
::if "%DriveType%"=="3" (
::    if not exist "D:\IMTemp" mkdir "D:\IMTemp"
::    set "MAGICK_TMPDIR=D:\IMTemp"
::    echo Yerel disk bulundu, MAGICK_TMPDIR ayarlandı: !MAGICK_TMPDIR!
::) else (
::    echo D: sürücüsü yok veya CD/USB tipi.
::    set "MAGICK_TMPDIR=%~dp0temp"
::    echo MAGICK_TMPDIR ayarlandı: !MAGICK_TMPDIR!
::)





:: C dışındaki ilk local diski bul
for /f "usebackq tokens=1" %%A in (`powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 -and $_.DeviceID -ne 'C:' } | Select-Object -First 1 -ExpandProperty DeviceID"`) do set "FoundDisk=%%A"
:: C ve D dışındaki ilk local diski bul
::for /f "usebackq tokens=1" %%A in (`powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 -and $_.DeviceID -ne 'C:' -and $_.DeviceID -ne 'D:' } | Select-Object -First 1 -ExpandProperty DeviceID"`) do set "FoundDisk=%%A"

:: Drive bulunduysa temp klasörü oluştur ve MAGICK_TMPDIR ayarla
if defined FoundDisk (
    if not exist "%FoundDisk%\IMTemp" mkdir "%FoundDisk%\IMTemp"
    set "MAGICK_TMPDIR=%FoundDisk%\IMTemp"
    echo Yerel disk bulundu, MAGICK_TMPDIR ayarlandı: !MAGICK_TMPDIR!
) else (
    echo C dışındaki sabit disk bulunamadı, temp klasörü script dizininde oluşturulacak.
    set "MAGICK_TMPDIR=%~dp0temp"
    if not exist "%MAGICK_TMPDIR%" mkdir "%MAGICK_TMPDIR%"
    echo MAGICK_TMPDIR ayarlandı: !MAGICK_TMPDIR!
)

:: PDF oluştur


:: ==========================
:: RAM TESPİT
:: ==========================
setlocal EnableDelayedExpansion

for /f %%A in ('
powershell -NoProfile -Command "[int][math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)"
') do set /a RAM_GB=%%A
::for /f %%A in ('powershell -NoProfile -Command "[int][math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)"') do set /a RAM_GB=%%A
::for /f "delims=" %%A in ('powershell -NoProfile -Command "[int][math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)"') do set "RAM_GB=%%A"

echo Tespit edilen RAM: !RAM_GB! GB

echo.

:: Karşılaştırma Mantığı (Artık tam sayılarla çalışabiliriz)
if !RAM_GB! GEQ 64 (
    set "MAGICK_ARGS=-limit memory 12GB -limit map 24GB -limit thread 6 -quality 90"
    echo 64 GB RAM algilandi - ULTRA
    goto :apply_settings
)
if !RAM_GB! GEQ 32 (
    set "MAGICK_ARGS=-limit memory 8GB -limit map 16GB -limit thread 4 -quality 88"
    echo 32 GB RAM algilandi - COK YUKSEK
    goto :apply_settings
)
if !RAM_GB! GEQ 16 (
    set "MAGICK_ARGS=-limit memory 3GB -limit map 8GB -limit thread 2 -quality 85"
    echo 16 GB RAM algilandi - YUKSEK
    goto :apply_settings
)
if !RAM_GB! GEQ 8 (
    set "MAGICK_ARGS=-limit memory 1GB -limit map 4GB -limit thread 1 -quality 82"
    echo 8 GB RAM algilandi - ORTA
    goto :apply_settings
)

:: Varsayılan (Düşük RAM)
set "MAGICK_ARGS=-limit memory 512MB -limit map 1GB -limit thread 1 -quality 78"
echo Düşük RAM algilandi - DUSUK

:apply_settings
echo.
echo MAGICK AYARLARI: !MAGICK_ARGS!
echo.


magick !MAGICK_ARGS! -compress jpeg ^
@"temp\filelist.txt" "pdf\%PDFNAME%"


endlocal



::magick -limit memory 512MB -limit map 1GB @"temp\filelist.txt" "pdf\%PDFNAME%"
::VARSAYILANA BUNU KOYMUŞTUM.
::magick @"temp\filelist.txt" -quality 85 -compress jpeg "pdf\%PDFNAME%"
::magick @"temp\filelist.txt" -quality 100 -compress jpeg "pdf\%PDFNAME%"

::FULL DEFAULT
::magick @"temp\filelist.txt" "pdf\%PDFNAME%"
::DEFAULT
::magick @"temp\filelist.txt" -quality 100 "pdf\%PDFNAME%"
::16 GB RAM VARSA;
::magick -limit memory 3GB -limit map 8GB -limit thread 2 @"temp\filelist.txt" -quality 85 -compress jpeg "pdf\%PDFNAME%"
::8 GB RAM VARSA;
::magick -limit memory 1GB -limit map 4GB -limit thread 1 @"temp\filelist.txt" -quality 85 -compress jpeg "pdf\%PDFNAME%"

::magick @"temp\filelist.txt" "pdf\%PDFNAME%"
::magick %IMAGES% "pdf\%PDFNAME%"

::Thread sayısını düşür (çok fark eder)
::magick -limit thread 2 @"temp\filelist.txt" output.pdf
::magick -limit memory 2GB -limit map 4GB @"temp\filelist.txt" output.pdf
::magick -limit memory 512MB -limit map 1GB @"temp\filelist.txt" -quality 85 -compress jpeg "pdf\%PDFNAME%"
::-limit memory → RAM kullanımını sınırlar
::-limit map → disk tabanlı swap/temp kullanımını sınırlar
::Density	Ne olur
::magick -limit memory 3GB -limit map 8GB -limit thread 2 -density 200 @"temp\filelist.txt" -quality 85 -compress jpeg "pdf\%PDFNAME%"
::150	Ekran için yeterli, hafif
::180	Dengeli (önerilir)
::200	Çok net, baskıya yakın
::300	Matbaa kalitesi, çok ağır


::OPTIMIZE pdf
::magick @"temp\filelist.txt" -quality 85 -compress jpeg "pdf\%PDFNAME%"
::-quality 85 → JPEG kalite seviyesi (85 genellikle göze fark etmeden %60+ küçültür).
::-compress jpeg → her sayfayı JPEG olarak sıkıştırır.


if errorlevel 1 (
    echo PDF olusturma sirasinda hata olustu.
) else (
    echo PDF olusturuldu: pdf\%PDFNAME%
)


::EĞER DOSYA BOYUTU ÇOK YÜKSEK OLURSA GHOSTSCRIPT İLE PDF SIKIŞTIR (gswin64c ve altındaki iki satırın önündeki :: kaldırarak aktif et veya  imagemagick'te pdf oluştururken optimizasyon -quality 85 gibi ayar ekle)
::https://www.bilgisayarbilisim.net/konular/fliphtml5-%C4%B0ndirme-sorunu.184790/page-2#post-2010016
::Ghostscript
::https://ghostscript.readthedocs.io/en/gs10.05.0/
::https://github.com/ArtifexSoftware/ghostpdl-downloads/
::https://ghostscript.com/releases/gsdnld.html
::gswin64c -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook ^
::  -dNOPAUSE -dQUIET -dBATCH ^
::  -sOutputFile="pdf\%BASE_NO_EXT%_compressed.pdf" "pdf\%PDFNAME%"
echo ===========================================================
pause
call :reset
goto menu




:end
endlocal
exit /b
::https://online.fliphtml5.com/rzegl/nmro/
::{"n":[".\/files\/large\/1.webp"],"t":".\/files\/thumb\/1.webp"}
::https://online.fliphtml5.com/tsyqb/btts/
::{"n":[".\/files\/large\/a56f6674a819cd352c59a856168782e6.webp"],"t":".\/files\/thumb\/f5a804049d5f1ab4cf21d99959b8065e.webp"} <<<< ama 1-2-3 diye indirmiyor.
::https://online.fliphtml5.com/rzegl/hmha/
::{"n":["04956e28e6d81411ed1b25856d58fe9f.webp"],"t":".\/files\/thumb\/a33a7d073834a04490ca0d7d2fae9133.webp"}
::https://online.pubhtml5.com/uayrm/afol/
::{"n":["1289710aa849fac1a274ffa02854ffee.jpg"],"t":".\/files\/thumb\/30b0c064ca24da6d8731c12bde37b024.jpg"}
::https://online.pubhtml5.com/mryp/pwik/
::{"l":"files/large/1.jpg","t":"files/thumb/1.jpg"}
::https://online.pubhtml5.com/mryp/yeam/
::{"l":"files\/large\/1.jpg","t":"files\/thumb\/1.jpg"}




::ÖNEMLİ NOTLAR::




::fliphtml5 pubhtml5 için config dosyasında
::https://online.fliphtml5.com/rzegl/yxts/javascript/config.js?1722315719
::https://online.fliphtml5.com/rzegl/nmro/javascript/config.js?1724755692
::https://online.fliphtml5.com/hpboy/fcno/javascript/config.js?1730775006 <<bu 2566c3bbb6e33d87a3c25217d9f63bb3.webp şeklinde https://online.fliphtml5.com/hpboy/fcno/#p=2
::https://online.pubhtml5.com/mryp/vplk/#p=1
::https://online.pubhtml5.com/mryp/vplk/javascript/config.js?1731327018 
::https://online.pubhtml5.com/trepx/jkmp/javascript/config.js?1750914842 <<bu 2566c3bbb6e33d87a3c25217d9f63bb3.webp şeklinde https://online.pubhtml5.com/trepx/jkmp/
::https://online.fliphtml5.com/templates/grcl/ << https://online.fliphtml5.com/templates/grcl/files/pageConfig/356a7ed4f78ebd00f3c02cf4808429c7_1696916950807.jpg şeklinde "fliphtml5_pages":[{"n":"none","t":"files\/thumb\/0-65c8012bfa8244e8d3fd581b3cd03e3a.webp","p":"..\/files\/preview\/5c1f0f73d46c318902920349e8cd449b.jpg"}
::https://online.fliphtml5.com/lkxjv/hfpz/ << {"n":[".\/files\/large\/8fd4fbf09577a968dcf1aafac08385cc.webp"],"t":".\/files\/thumb\/52c94ec2ed7ae6d6bc83da1456a4da13.webp"}


::https://online.fliphtml5.com/oxgto/dxua/ << encrypted şifreli fliphtml5_pages veya window.fliphtml5_pages ...chrome konsol console gerekiyor.
::indivibook tarzında e-kitaplar z-kitaplar için
::https://egitimvadisi.etkilesimlitahta.com/#/indivibook/tyt-matematik-pdf-1-modul/15
::https://cdn1.indivibook.com/cozum01/f/8f44cc904fc6f31ae792076d9097ae39_1622012701/data/1750816214-ebook-data.json


::5 renk pdf doğrudan https://dijital.5renkyayinevi.com/
::https://dijital.5renkyayinevi.com/wp-content/uploads/2024/10/KIRAZ.pdf



::lisedestek yayincilik dijitalim flipbook blob: linkleri
::https://www.lisedestek.com/FlipBook/?version=0&bookId=20892&template=flipbook#13
::https://www.lisedestek.com/FlipBook/app.config.js
::https://www.lisedestek.com/Uploads/WebDijitapDosyalar/20892/data/BookContent.xml

::https://www.dijitalalternatif.com/WebZKitap/?version=0&bookId=33822
::https://www.dijitalalternatif.com/WebZKitap/app.config.js
::https://www.dijitalalternatif.com/Uploads/WebDijitapDosyalar/33822/data/BookContent.xml


::fernus bookzkitap şifreli
::https://akillidefter.com.tr/bookszkitapx/2024-2-sinif-turkce-atolyem//book.json
::https://zkitapx.fernus.net/assets/AssetManifest.bin.json


::ataekitap örnekleri
::https://www.ataekitap.com/
::https://www.ataekitap.com/e-kitaplar/2024-2025-Ekitap/Okul_Oncesi/Okul_Yolculugum/Okul_Yolculugu_1_Kitap/index.html
::https://www.ataekitap.com/e-kitaplar/2024-2025-Ekitap/Okul_Oncesi/Okul_Yolculugum/Okul_Yolculugu_1_Kitap/files/mobile/1.jpg?240723105533


::basit url yapısı
::https://www.aydindijital.com/library/smartbook/1146
::https://www.aydindijital.com/MobileApp/BookPublic/BookDetails/424e692c-e532-4752-80d8-1ce0d7969218
::https://www.aydindijital.com//Media/UserData/bookimages/424e692c-e532-4752-80d8-1ce0d7969218/Page1.png
::https://www.aydindijital.com/smartbook/sbookpublic/GetSmartBook?bookId=1146&includePageItems=true&isSolutionPage=false&includePageImages=false&includeQImages=false&includeGfImages=false



