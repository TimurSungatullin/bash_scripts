#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: $0 [--path dirpath] [--mask mask] [--number number] command"
  exit 1
fi

dirpath="."
mask="*"
number=$(nproc)
command=""

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
  --path)
    dirpath="$2"
    shift
    ;;
  --mask)
    mask="$2"
    shift
    ;;
  --number)
    number="$2"
    shift
    ;;
  *)
    command="$1"
    shift
    ;;
  esac
done

if ! [ -d "$dirpath" ]; then
    echo "$dirpath is not a directory."
    exit 1
fi

COMMAND=${@:$OPTIND:1}
if ! command -v $COMMAND &> /dev/null;
then
  echo "$COMMAND not found"
  exit 1
fi

files=($dirpath/$mask)

for file in "${files[@]}"; do
  "$command" "$file" &

  running_processes=$(jobs -p)
  while [ ${#running_processes[@]} -ge $number ]; do
    wait -n
    running_processes=$(jobs -p)
  done
done

wait