#!/usr/bin/env bash

include lib/ansi.sh

start::finish

echo "main"
ansi::bold "Fetter Text"; ansi::reset
echo ""

ansi::fg_256 150 "blubb"; ansi::reset
echo ""

ansi::fg_tc 255 0 0 "rot"; ansi::reset
echo ""

ansi::red "rot2"; ansi::reset_fg; printf " normal"
echo ""

ansi::black "schwarz"; ansi::red " rot"; ansi::green " grün";
ansi::yellow " gelb"; ansi::blue " blau"; ansi::magenta " magenta";
ansi::cyan " cyan"; ansi::white " weiß"; ansi::reset
echo ""

ansi::bright_black "schwarz"; ansi::bright_red " rot"; ansi::bright_green " grün";
ansi::bright_yellow " gelb"; ansi::bright_blue " blau"; ansi::bright_magenta " magenta";
ansi::bright_cyan " cyan"; ansi::bright_white " weiß"; ansi::reset
echo ""

ansi::bg_256 4 "xxxxxxxxxx"; ansi::reset_bg "yyyyyyyy"; ansi::reset
echo ""

ansi::cur_save; printf "12345678"; ansi::cur_restore; printf "ab  ef"
echo""
#echo -en "\e[s"
#echo -en "12345678"
#echo -en "\e[u"
#echo -en "ab  ef"
#echo ""

#ansi::cur_print | printf "cur: %s\r\n" 
ansi::cur_getpos

