#!/bin/bash

defaults=$1
add=$2
all=("${defaults[@]}" "${add[@]}")

#simulating map-kinda structure(only bash4.0 natively supports map structure)
declare -i key=0
declare -i key1=0
declare -i i=0
declare -i k=0
declare -a dummy_all
declare -a error
declare -a all_lasttime
put()
{
    key=$key+1
    options=("${options[@]}" "$1")
    options_needs=("${options_needs[@]}" "$2")
    options_excludes=("${options_excludes[@]}" "$3")

}

put_not()
{
    key1=$key1+1
    options1=("${options1[@]}" "$1") ;
    options_needs1=("${options_needs1[@]}" "$2")
    options_excludes1=("${options_excludes1[@]}" "$3");

}

option_check()
{   
      #this checks if required options in "presence" of certain option are present and excluding option are absent
      #if conflict arises, the option which is in default is removed but if both conflicting option is in add or required by any option in add then gives error 

    j="$1";
    needed=("${options_needs[${j}]}")
    excluded=("${options_excludes[${j}]}")

    for item in ${needed[@]};do
      if ! echo ${all[@]} | grep -w -q "$item";then
        all=("${all[@]}" "$item")
        add=("${add[@]}" "$item")
      fi
    done

    for item in ${excluded[@]};do
      if echo ${defaults[@]} | grep -w -q "$item";then
        #code to remove conflicting default item from all provided options
       
        for index in ${all[@]};do
          [[ $index != "$item" ]] && dummy_all+=($index)
        done
        all=("${dummy_all[@]}")
        unset dummy_all
      fi
      if echo ${add[@]} | grep -w -q "$item";then
        if echo ${defaults[@]} |  grep -w -q "$options[$j]";then
         for index in ${all[@]};do
          [[ $index != "$options[$j]" ]] && dummy_all+=($index)
        done
        all=("${dummy_all[@]}")
        unset dummy_all
        break
        else
        error=("added option $item (either given by user explicitly or required as dependency) is incompatible with ${options[${i}]}")
        fi
      fi 
    done

}

option_check1()
{      # this checks if required options in "absence" of certain option are present and excluding options are absent
       # if excluding options are in add array, then this gives error

    j="$1";
    needed1=("${options_needs1[${j}]}")
    excluded1=("${options_excludes1[${j}]}")

    for item in ${needed1[@]};do
      if ! echo ${all[@]} | grep -w -q "$item";then
        all=("${all[@]}" "$item")
        add=("${add[@]}" "$item")
      fi
    done

    for item in ${excluded1[@]};do
      if echo ${defaults[@]} | grep -w -q "$item";then
        #code to remove conflicting default item from all provided options
        for index in ${all[@]};do
          [[ $index != "$item" ]] && dummy_all+=($index)
        done
        all=("${dummy_all[@]}")
        unset dummy_all
      fi
      if echo ${add[@]} | grep -w -q "$item";then
        error=("added option $item (either given by user explicitly or required as dependency) is incompatible with absence of ${options1[${i}]}")
      fi 
    done

}


#add new cases below as::  put "option" "needed dependencies" "exclusions"
#put empty parenthesis("") if no exclusions or dependencies(this is important for avoiding worng indexing)

put "hdf5" "collimat" ""
put "bonic" "cpss" ""
put "beamgas""collimat" "bignblz hugenblz"
put "hugenblz" "" "bignblz"
put "da" "" "collimat cpss bpm"
put "collimat" "" "da cpss bpm cr crlibm"
put "cpss" "crlibm cr" "cernlib" 
put "m64" "" "ifort nagfor pgf90 g95 lf95 cernlib bonic m32"

# add below the case which are to be followed in absence of certain options
#as put_not "option" "needed dependencies" "exclusions"

put_not "da" "" "naglib"
put_not "m64" "m32" ""

while [[ $k -lt 10  && ${all_lasttime[@]} != ${all[@]} ]];do             #running test max 10 times just to ensure no new conflict arise in items added
unset error
all_lasttime=${all[@]}
while [ $i -lt $key ];do                         
 for index in ${all[@]};do
     [[ $index = "${options[$i]}" ]] && option_check "$i"
done
i=$i+1 
done
i=0
while [ $i -lt $key1 ];do                         
 if ! echo ${all[@]} | grep -w -q "${options1[$i]}";then
  option_check1 "$i"
 fi
i=$i+1 
done
i=0
k=$k+1
done
if echo ${error} | grep -w -q "incompatible";then
echo ${error}
else
echo ${all[@]}
fi