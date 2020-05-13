#!/bin/bash

VARDEFNS="$(realpath ${1-var_defns.sh})"
source ${VARDEFNS}

#
# Decode ${EXPTDIR}/FV3SAR_wflow.xml
#
while read line; do
  if [[ $line =~ "<!ENTITY" ]]; then
    line=${line##<!ENTITY}
    line=${line%%>}
    #echo $line
    read var val <<<$line
    eval $var=$val
    #echo $var=$val
  fi
done < ${EXPTDIR}/FV3SAR_wflow.xml

nodes=${PROC_POST%%:*}
ppn=${PROC_POST##*=}
numprocess=$(( nodes*ppn ))

walltime=${RSRC_POST#<walltime>}
walltime=${walltime%</walltime>}

queue=${QUEUE_DEFAULT#<queue>}
queue=${queue%</queue>}

##@@@@@@@@@@@@@@@@@@@@@@@@@@@@

CODEBASE="${HOMErrfs}"
PDY="${DATE_FIRST_CYCL}"
HH="${CYCL_HRS}"
CYCLE_DIR="${EXPTDIR}/${PDY}${HH}"

WRKDIR="${LOGDIR}"

if [[ ! -d $WRKDIR ]]; then
  mkdir $WRKDIR
fi

cd $WRKDIR

declare -a fhrs=(${FHR})

for fhr in ${fhrs[@]}; do
  #echo $fhr

  fhr3=$(printf "%03d" ${fhr#0})

  dyn_file=${CYCLE_DIR}/dynf${fhr3}.nc
  phy_file=${CYCLE_DIR}/phyf${fhr3}.nc

  log_file=${CYCLE_DIR}/logf${fhr3}

  wtime=0
  while [[ ! -f ${log_file} ]]; do
    echo "Waiting ($wtime seconds) for ${log_file}"
    sleep 20
    wtime=$(( wtime += 20 ))
  done
  #while [[ ! -f ${dyn_file} ]]; do
  #  sleep 20
  #  wtime=$(( wtime += 20 ))
  #  echo "Waiting ($wtime seconds) for ${dyn_file}"
  #done
  #
  #while [[ ! -f ${phy_file} ]]; do
  #  sleep 10
  #  wtime=$(( wtime += 10 ))
  #  echo "Waiting ($wtime seconds) for ${phy_file}"
  #done

  jobscript="run_upp_${fhr3}.sh"

  read -r -d '' taskheader <<EOF
#!/bin/sh -l
#SBATCH -A ${ACCOUNT}
#SBATCH -p ${queue}
#SBATCH -J fv3sar
#SBATCH --nodes=${nodes} --ntasks-per-node=${ppn}
#SBATCH --exclusive
#SBATCH -t ${walltime}
#SBATCH -o out.upp_${fhr3}_%j
#SBATCH -e err.upp_${fhr3}_%j

export GLOBAL_VAR_DEFNS_FP="${VARDEFNS}"
export CYCLE_DIR="${CYCLE_DIR}"
export CDATE="${PDY}${HH}"
export PDY="${PDY}"

export NPROCS=${numprocess}
export cyc=${fhr#0}
export fhr=${fhr}

EOF

  cd $WRKDIR
  cp ${CODEBASE}/jobs/JREGIONAL_RUN_POST ${jobscript}

  sed -i "1d" ${jobscript}
  echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

  sbatch ${jobscript}

done

exit 0
