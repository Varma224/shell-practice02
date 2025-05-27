#!/bin/bash

echo "All args passed in script : $@"
echo "No of args passed in script: $#"
echo "present working directory: $PWD"
echo "User name in script: $0"
echo "Home directory: $HOME"
echo "Process ID: $$"
sleep 10 &
echo "Last process ID: $!"
