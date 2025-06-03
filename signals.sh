#!/bin/bash

failure() {

    echo "Catching signals: SIGINT"

}

trap failure SIGINT
echo "Script started"
sleep 400
echo "Script completed"
