#!/bin/bash


loop() 
{
    for file in $2
    do
    ## If $file is a directory
    if [ -d "$file" ]
    then
        loop $1 "$file/*"
    else
            ./grep $1 $file
    fi
    done
}
loop $1 $2



