#!/bin/bash

function run()
{
  sudo pkill python
  for f in /home/luo/Work/Always/*.py
  do 
    sudo python -B "$f" &
	echo $f has start
  done
}

function push()
{
  while true
  do
    arg=${1:-main}
    time=`date '+%F %T'`
    
    result=`git status 2>&1`
    if [[ "$result" =~ "Changes" || "$result" =~ "push" ]]
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
    log "------------------start to pull------------------!"
    pull
    log "------------------start to push------------------!"
    push
    log "------------------start to wait------------------!"
    date=`date '+%F %T' --date="+6 hour"`
    echo "waiting for 6 hour ..."
    echo  $date will sync again
    sleep 6h
  done
}

function update()
{
  sudo apt update -y && sudo apt upgrade -y
  sudo apt autoclean -y && sudo apt autoremove -y
}


function setproxy()
{
  git config --local http.proxy 'socks5://127.0.0.1:1081'
  git config --local https.proxy 'socks5://127.0.0.1:1081'
  log "setproxy done"
}

function unsetproxy()
{
  git config --local --unset http.proxy
  git config --local --unset https.proxy
  log "unsetproxy done"
}

log(){ echo -e "\e[32m$1 \e[0m"; }
warn(){ echo -e "\e[31m$1 \e[0m"; }
