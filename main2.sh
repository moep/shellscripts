#!/usr/bin/env bash

LANG=C
LC_NUMERIC=C

source bootstrap.sh
include lib/ui.sh
include lib/str.sh
include lib/ui.sh
include lib/os.sh
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
ui::progressbar::green 20 $(os::cpu_usage)
echo 
