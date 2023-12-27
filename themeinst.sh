#!/bin/bash
if [ -t 0 ]; then interm=1; else interm=0; fi
if [ $# -eq 0 ]; then
if  [ $interm -eq 1 ]; then
echo "Usage:";echo "- Apply themepack:      $0 <xxxx.themepack>";echo "- Install association:  $0 install"
fi; exit 1; fi
USER_HOME=$(eval echo ~${SUDO_USER})
if [ "$interm" -eq 1 ] && [ "$1" = "install" ]; then
echo "installing...";scriptfolder=$(dirname "$(readlink -f "$0")")
desktopfilecontent="[Desktop Entry]
Exec[\$e]=$scriptfolder/themeinst.sh
MimeType=application/ms_themepack
Name=ms themepack installer
Terminal=false
Type=Application
X-TDE-InitialPreference=2
";desktopfilepath="$HOME/.trinity/share/applnk/.hidden/themeinst.sh.desktop"
sudo echo "$desktopfilecontent" > "$desktopfilepath"
mdesktopfilecontent="[Desktop Entry]
Comment=Microsoft themepack
Hidden=false
Icon=preferences-desktop-wallpaper
MimeType=application/ms_themepack
Patterns=*.themepack
Type=MimeType
";mdesktopfilepath="$HOME/.trinity/share/mimelnk/application/ms_themepack.desktop"
sudo echo "$mdesktopfilecontent" > "$mdesktopfilepath"
echo "Done."; exit; fi
filename=$(basename "$1" .themepack)
wallpapers_dir="/opt/trinity/share/wallpapers/$filename"
if  [ $interm -eq 0 ]; then
tdesudo -i preferences-desktop-wallpaper -d -c ls --comment "ms themepack installer needs administrators rights. Please enter your password:"; fi
sudo mkdir -p "$wallpapers_dir"
sudo 7z x "$1" -o"$wallpapers_dir" -y > /dev/null 2>&1
sudo chmod -R 755 "/opt/trinity/share/wallpapers/$filename"
sudo rm -f "/opt/trinity/share/wallpapers/$filename/"*.theme
sudo kwriteconfig --file $USER_HOME/.trinity/share/config/kdesktoprc --group Desktop0 --key WallpaperList "/opt/trinity/share/wallpapers/$filename/DesktopBackground/"
sudo kwriteconfig --file $USER_HOME/.trinity/share/config/kdesktoprc --group Desktop0 --key MultiWallpaperMode Random
sudo kwriteconfig --file $USER_HOME/.trinity/share/config/kdesktoprc --group Desktop0 --key CrossFadeBg true
sudo kwriteconfig --file $USER_HOME/.trinity/share/config/kdesktoprc --group Desktop0 --key ChangeInterval 5
if  [ $interm -eq 1 ]; then echo "MS Themepack $filename installed.";echo "Restarting kdesktop..."
else dcop knotify Notify notify "Themepack installation" "knotify" "Restarting kdesktop..." "" "" 16 0
fi
#refresh desktop - dirty kill... maybe there's another solution to force kdesktop to re-read config ?
killall -w -q kdesktop > /dev/null 2>&1 && kdesktop &> /dev/null 2>&1
if  [ $interm -eq 1 ]; then echo "Done."; else
dcop knotify Notify notify "Themepack installation" "knotify" "Themepack $filename Applied." "" "" 16 2
fi