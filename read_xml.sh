#!/bin/bash

read_dom () {
    local IFS=\>
    read -d \< ENTITY CONTENT
    local ret=$?
    TAG_NAME=${ENTITY%% *}
    ATTRIBUTES=${ENTITY#* }
    echo "$TAG_NAME, $ATTRIBUTES"
    return $ret
}

parse_entity () {
    if [[ $TAG_NAME == "!ENTITY" ]] ; then
        if [[ $ATTRIBUTES =~ "$1" ]]; then
          #echo $ATTRIBUTES
          local a=${ATTRIBUTES##* \"}
          local b=${a%%\"}
          #echo $b
          eval ${1}=$b
        fi
    fi
}

while read line; do
  if [[ $line =~ "<!ENTITY" ]]; then
    line=${line##<!ENTITY}
    line=${line%%>}
    #echo $line
    read var val <<<$line
    eval $var=$val
    #echo $var=$val
  fi
done < /scratch/ywang/comFV3SAR/test_runs/GDAS0530/FV3SAR_wflow.xml
echo $RSRC_POST

echo ${PROC_MAKE_SFC_CLIMO%%:*}
echo ${PROC_MAKE_SFC_CLIMO##*=}
