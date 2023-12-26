#!/bin/bash
declare -a pids
completed=0
toDo=0

while getopts ":path:m:number:" option
do
  case $option in
    path) dirpath="$OPTARG";;
    m) mask="$OPTARG";;
    number) number="$OPTARG";;
  esac
done

echo "Маска вот"
echo $mask
if [ -z ${mask} ];
  echo "Маски нет"
  then mask="*";
fi
if [ -z "$dirpath" ]; then dirpath="."; fi
if [ -z "$number" ]; then
  cpu_coint=$(nproc)
  number=$cpu_coint
fi
echo $mask

if ! [ -d "$dirpath" ]; then
    echo "$dirpath is not a directory."
    exit 1
fi

COMMAND=${@:$OPTIND:1}

echoCompleted(){
  echo $completed
}

echoTodo(){
  echo $toDo
}

trap echoCompleted SIGUSR1
trap echoTodo SIGUSR2

get_abs_filename() {
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

files=($dirpath/$mask)

for file in ${files[*]}
do
  abs_path=$(get_abs_filename $file)
  if ! [ -f "$abs_path" ]; then
    continue
  fi
  if (( $toDo > $number ))
  then
    wait -n ${pids[*]}
    completed=$((completed + 1))
    toDo=$((toDo - 1))
  fi
    ($COMMAND $(get_abs_filename $file);) &
    toDo=$((toDo + 1))
    pids+=($!)
done

while (( $completed != ${#files[@]} ))
do
  wait -n ${pids[*]}
  completed=$((completed + 1))
  toDo=$((toDo - 1))
done