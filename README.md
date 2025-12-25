# quickshell-bar-example
a quickshell bar i made and use for my hyprland feel free to use it as an example

credits goes to: https://github.com/tonybanters/quickshell-btw
i used it as a starting point then just made a few tweeks to get it to my liking 
i added things like a battery percentage and a text to show currently playing spotify song and rearranged the items and added also a Theme.qml file for wallust


this is the template file for wallust (templates/Theme.qml)
```qml
pragma Singleton
import Quickshell
import QtQuick

Singleton {
  readonly property color colBg: "{{background}}"
  readonly property color colFg: "{{foreground}}"
  readonly property color col0: "{{color0}}"
  readonly property color col1: "{{color1}}"
  readonly property color col2: "{{color2}}"
  readonly property color col3: "{{color3}}"
  readonly property color col4: "{{color4}}"
  readonly property color col5: "{{color5}}"
  readonly property color col6: "{{color6}}"
  readonly property color col7: "{{color7}}"
  readonly property color col8: "{{color8}}"
  readonly property color col9: "{{color9}}"
  readonly property color col10: "{{color10}}"
  readonly property color col11: "{{color11}}"
  readonly property color col12: "{{color12}}"
  readonly property color col13: "{{color13}}"
  readonly property color col14: "{{color14}}"
  readonly property color col15: "{{color15}}"
}
```
```toml
then just added this in the wallust.toml file
qs.src = "Theme.qml"
qs.dst = "~/.config/quickshell/Theme.qml"
```
