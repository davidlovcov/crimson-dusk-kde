#!/usr/bin/env bash
# Crimson Dusk for KDE Plasma 6
# Global theme + splash screen, colours, fonts, clock widget,
# Panel Colorizer preset and kitty colours.
set -euo pipefail
cd "$(dirname "$0")"

R='\033[38;2;237;70;67m'; D='\033[2m'; N='\033[0m'
say() { echo -e "${R}◆${N} $1"; }
FONT="Share Tech Mono"
THEME_ID="org.devid.crimsondusk.desktop"
CLOCK_ID="org.devid.crimsondusk.clock"
QDBUS="$(command -v qdbus6 || command -v qdbus || true)"

echo -e "\n  crimson-dusk ${D}· KDE Plasma 6${N}\n"

say "Backing up ~/.config/kdeglobals to kdeglobals.bak-crimson"
[ -f ~/.config/kdeglobals ] && cp ~/.config/kdeglobals ~/.config/kdeglobals.bak-crimson

say "Installing font"
mkdir -p ~/.local/share/fonts
cp fonts/ShareTechMono.ttf ~/.local/share/fonts/
fc-cache -f >/dev/null

say "Installing colour scheme"
mkdir -p ~/.local/share/color-schemes
cp color-schemes/CrimsonDusk.colors ~/.local/share/color-schemes/

say "Installing global theme and splash screen"
kpackagetool6 -t Plasma/LookAndFeel -u "global-theme/$THEME_ID" >/dev/null 2>&1 \
  || kpackagetool6 -t Plasma/LookAndFeel -i "global-theme/$THEME_ID" >/dev/null
plasma-apply-lookandfeel -a "$THEME_ID" >/dev/null
# Make sure the colours and splash are active even if the theme was already selected
kwriteconfig6 --file kdeglobals --group General --key accentColorFromWallpaper false
kwriteconfig6 --file kdeglobals --group General --key AccentColor --delete
plasma-apply-colorscheme BreezeDark >/dev/null 2>&1 || true
plasma-apply-colorscheme CrimsonDusk >/dev/null
plasma-apply-desktoptheme default >/dev/null 2>&1 || true
kwriteconfig6 --file ksplashrc --group KSplash --key Engine KSplashQML
kwriteconfig6 --file ksplashrc --group KSplash --key Theme "$THEME_ID"

say "Setting fonts to $FONT"
f() { echo "$FONT,$1,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"; }
kwriteconfig6 --file kdeglobals --group General --key font                 "$(f 10)"
kwriteconfig6 --file kdeglobals --group General --key menuFont             "$(f 10)"
kwriteconfig6 --file kdeglobals --group General --key toolBarFont          "$(f 10)"
kwriteconfig6 --file kdeglobals --group General --key smallestReadableFont "$(f 8)"
kwriteconfig6 --file kdeglobals --group General --key fixed                "$(f 10)"
kwriteconfig6 --file kdeglobals --group WM      --key activeFont           "$(f 10)"

say "Installing clock widget"
kpackagetool6 -t Plasma/Applet -u "plasmoid/$CLOCK_ID" >/dev/null 2>&1 \
  || kpackagetool6 -t Plasma/Applet -i "plasmoid/$CLOCK_ID" >/dev/null

say "Installing Panel Colorizer preset"
mkdir -p ~/.config/panel-colorizer/presets
cp -r "panel-colorizer/Crimson Dusk" ~/.config/panel-colorizer/presets/

if [ -d ~/.config/kitty ]; then
  say "Applying kitty theme"
  cp kitty/crimson-dusk.conf ~/.config/kitty/
  grep -qx 'include crimson-dusk.conf' ~/.config/kitty/kitty.conf 2>/dev/null \
    || echo 'include crimson-dusk.conf' >> ~/.config/kitty/kitty.conf
  pkill -USR1 -x kitty 2>/dev/null || true
fi

if [ -n "$QDBUS" ]; then
  say "Setting the panel clock to $FONT, size 10"
  "$QDBUS" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    panels().forEach(function (p) {
      p.widgets('org.kde.plasma.digitalclock').forEach(function (w) {
        w.currentConfigGroup = ['Appearance'];
        w.writeConfig('autoFontAndSize', false);
        w.writeConfig('fontFamily', '$FONT');
        w.writeConfig('fontSize', 10);
      });
    });" >/dev/null || true

  echo -ne "${R}❯${N} Add the clock to your main desktop? [Y/n] "; read -r A
  if [[ "${A:-y}" =~ ^[Yy]$ ]]; then
    "$QDBUS" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
      var d = desktops();
      for (var i = 0; i < d.length; i++) {
        if (d[i].screen === 0) { d[i].addWidget('$CLOCK_ID', 80, 80, 480, 220); }
      }" >/dev/null && say "Clock added (drag it where you like)"
  fi
fi

echo
say "Done. Log out and back in once to see the splash screen and new fonts everywhere."
echo -e "  ${D}Panel: open Panel Colorizer settings → Presets → Crimson Dusk${N}"
echo -e "  ${D}Undo:  cp ~/.config/kdeglobals.bak-crimson ~/.config/kdeglobals, then pick another Global Theme${N}\n"
