#!/bin/bash

if [[ $( hostname ) =~ 002 ]]; then
    echo "Hostname contains 002"
    sleep 10
else
    echo "Hostname does not contain 002"
fi