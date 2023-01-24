#!/bin/bash

log(){ echo -e "\e[32m$1 \e[0m"; }
warn(){ echo -e "\e[31m$1 \e[0m"; }

function push()
{
  while true
  do
    arg=${1:-main}
    time=`date '+%F %T'`
    
    result=`git status 2>&1`
    if [[ "$result" =~ "Changes" || "$result" =~ "push" || "$result" =~ "add" ]]
    then
      echo "$result"
    else
      echo "$result"
      break
    fi
    
    git add .
    git commit -m "modify at $time"
    result=`git push origin -u $arg 2>&1`
    if [[ $result =~ "fatal" ]]
    then
      echo "$result"
      warn "git push failed, try again..."
      sleep 3s
    else
      echo "$result"
      break
    fi
    
  done
}

function pull()
{
  while true
  do
    result=`git pull 2>&1`
    if [[ $result =~ "fatal" ]]
    then
      echo "$result"
      warn "git pull failed, try again..."
      sleep 3s
    else    
      echo "$result"
      break
    fi
  done
}

function autopush()
{
  while true
  do
    log "--------------------------start to upgrade-------------------------!"
    log "------------------start to pull------------------!"
    pull
    log "------------------start to push------------------!"
    push
    log "------------------start to wait------------------!"
    date=`date '+%F %T' --date="+4 hour"`
    echo "waiting for 4 hour ..."
    echo  $date will sync again
    sleep 4h
  done
}

autopush
