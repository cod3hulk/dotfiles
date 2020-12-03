#!/bin/bash
engine='google'
query=$(rofi -dmenu -p "Search")

if [ ! -z "$query" ]
then
  sr "$engine" $query
fi

