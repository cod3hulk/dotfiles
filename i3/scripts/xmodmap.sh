#!/bin/bash
xmodmap -e "clear Lock"
xmodmap -e "keycode 66 = Mode_switch"
xmodmap -e "keysym h = h H Left"
xmodmap -e "keysym l = l L Right"
xmodmap -e "keysym k = k K Up"
xmodmap -e "keysym j = j J Down"
xmodmap -e "keysym u = u U Prior"
xmodmap -e "keysym p = p P Next"
xmodmap -e "remove mod1 = Alt_L"
xmodmap -e "remove mod4 = Super_L"
xmodmap -e "add mod1 = Super_L"
xmodmap -e "add mod4 = Alt_L"