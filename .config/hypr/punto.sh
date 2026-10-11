#!/bin/bash
hyprctl dispatch pass "CTRL_SHIFT, left"
hyprctl dispatch pass "CTRL, C"
hyprctl dispatch pass ", BackSpace"
sleep 0.05
python3 /home/rdf-2041/dotfiles/.config/hypr/punto.py
sleep 0.05
hyprctl dispatch pass "CTRL, V"
hyprctl dispatch switchxkblayout current next
