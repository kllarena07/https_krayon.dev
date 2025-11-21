#!/bin/bash
ttyd --writable -t titleFixed="krayon.dev" -p 7681 sh -c "./portfolio-v2 --local; ./welcome.sh; exec bash"
