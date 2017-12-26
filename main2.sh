#!/usr/bin/env bash

LANG=C
LC_NUMERIC=C

source bootstrap.sh
include lib/ui.sh
include lib/str.sh
include lib/ui.sh
include lib/os.sh
include lib/tmux.sh
include lib/fx.sh
bootstrap::finish

ansi::cls
ansi::cur_pos 1 1

ui::h1 "String"
str::length "12345"
echo
str::length ""
echo
str::fill "" "#" "" 5
echo

ui::h1 "Math"

ui::h1 "UI"
echo "....#....#....#....#"
ui::progressbar::white 20 30
echo
printf "CPU: "
ui::progressbar::white 20 $(os::cpu_usage)
echo 
printf "CPU: "
ui::progressbar::red 20 $(os::cpu_usage)
echo 
printf "CPU: "
ui::progressbar::yellow 20 $(os::cpu_usage)
echo 
printf "CPU: "
ui::progressbar::green 20 $(os::cpu_usage)
echo 

ui::h1 "OS"
#__LOADING_ANIMATION='echo -n "#"'
#os::exec_and_wait sleep 2
echo "Done"
echo "Bat:" $(os::battery_percent)"%" $(! os::battery_charging? && echo -n "dis")"charging"
os::battery_remaining_time
echo 

ui::h1 "FX"
fx::typewriter "This is quite a long line. Typed one char at a time." "This is some extra text" 
echo
fx::fade "This text fades in slowly"
echo
ui::h1 "tmux"
tmux::is_tmux? && echo "tmux" || echo "!tmux"
tmux::message "Normal"
#sleep 10
#tmux::message_red "ROT!!"
