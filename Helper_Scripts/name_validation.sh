#! /usr/bin/bash


# Get the name from the first argument
name=${1}

# Check if the name is empty
if [[ -z "$name" ]]; then
    echo "no"
    exit 1
fi

# Validate the name format
case $name in
    [0-9]*)
        echo "no"
        ;;
    *' '*)
        echo "no"
        ;;
    *[!A-Za-z0-9_-]*)
        echo "no"
        ;;
    *)
        echo "yes"
        ;;
esac
