#!/bin/bash

echo "All args passed in script : $@"
echo "No of args passed in script: $#"
echo "present working directory: $PWD"
echo "User name in script: $USER"
echo "Home directory: $HOME"
echo "Process ID: $$"
sleep 15 &
echo "Last process ID: $!"
