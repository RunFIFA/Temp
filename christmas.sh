#!/bin/bash
#用shell编写一个圣诞树
#创建时间2021-12-21
trap "tput reset; tput cnorm; exit" 2
clear
tput civis
lin=2
col=$(($(tput cols) / 2))
c=$((col-1))
est=$((c-2))
color=0
tput setaf 2; tput bold

# 打印树叶
for ((i=1; i<20; i+=2))
{
    tput cup $lin $col
    for ((j=1; j<=i; j++))
    {
        echo -n \*
    }
    let lin++
    let col--
}

tput sgr0; tput setaf 3

# 打印树干
for ((i=1; i<=2; i++))
{
    tput cup $((lin++)) $c
    echo '||'
}
new_year=$(date +'%Y')
let new_year++
tput setaf 222; tput bold
tput cup $lin $((c - 10));  echo $new_year  圣 诞 节 快 乐！！！
color=122
tput setaf $color; tput bold
tput cup $((lin + 1)) $((c - 10)); echo 关注公众号:  一口Linux!
let c++
k=1

#装饰一下
while true; do
    for ((i=1; i<=35; i++)) {
        # Turn off the lights
        [ $k -gt 1 ] && {
            tput setaf 2; tput bold
            tput cup ${line[$[k-1]$i]} ${column[$[k-1]$i]}; echo \*
            unset line[$[k-1]$i]; unset column[$[k-1]$i] 
        }

        li=$((RANDOM % 9 + 3))
        start=$((c-li+2))
        co=$((RANDOM % (li-2) * 2 + 1 + start))
        tput setaf $color; tput bold
        tput cup $li $co
        echo o
        line[$k$i]=$li
        column[$k$i]=$co
        color=$(((color+1)%8))

        sh=1
        #for l in M O N E Y
        for l in  一 口 Li nu x!
        do
            tput cup $((lin+1)) $((c+sh))
            echo $l
            let sh++
            let sh++
            sleep 0.02
        done
    }
    k=$((k % 2 + 1))
done