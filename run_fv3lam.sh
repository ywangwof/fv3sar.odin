#!/bin/bash

function usage {
    echo " "
    echo "    USAGE: $0 [options] VARDEFNS"
    echo " "
    echo "    PURPOSE: Run UFS SRWeather jobs on Odin based on ROCOTO workflow file: FV3LAM_wflow.xml "
    echo " "
    echo "    VARDEFNS - var_defns.sh file generated by FV3 regional workflow"
    echo " "
    echo "    OPTIONS:"
    echo "              -h              Display this message"
    echo "              -n              Show command to be run only"
    echo "              -v              Verbose mode"
    echo "              -r   run_fcst   Tasks to be run, one in (run_grid, run_orog, run_sfc, run_ics, run_lbc, run_fcst, run_post)"
    echo " "
    echo "                                     -- By Y. Wang (2020.10.21)"
    echo " "
    exit $1
}

#-----------------------------------------------------------------------
#
# Default values
#
#-----------------------------------------------------------------------

show=0
verb=0
task="run_fcst"
xmlparser="$(dirname $0)/read_xml.py"
VARDEFNS="./var_defns.sh"

#-----------------------------------------------------------------------
#
# Handle command line arguments
#
#-----------------------------------------------------------------------

while [[ $# > 0 ]]
    do
    key="$1"

    case $key in
        -h)
            usage 0
            ;;
        -n)
            show=1
            ;;
        -v)
            verb=1
            ;;
        -r)
            task=$2
            shift
            ;;
        -*)
            echo "Unknown option: $key"
            exit
            ;;
        *)
            if [[ -f $key ]]; then
                VARDEFNS=$key
            else
                echo ""
                echo "ERROR: unknown option, get [$key]."
                usage -2
            fi
            ;;
    esac
    shift # past argument or value
done

if [[ $task =~ run_(grid|orog|sfc|ics|lbc|fcst|post) ]]; then
    echo "Task     = $task"
else
    echo "ERROR: unsupport task - $task"
    usage -1
fi

if [[ -f $VARDEFNS ]]; then
    echo "VARDEFNS = $VARDEFNS"
else
    echo ""
    echo "ERROR: cannot find var_defns.sh - $VARDEFNS."
    usage -2
fi

#-----------------------------------------------------------------------
#
# Definitions
#
#-----------------------------------------------------------------------

VARDEFNS="$(realpath ${VARDEFNS})"
source ${VARDEFNS}

declare -A tasknames  queues wrappers
tasknames=(["run_grid"]="make_grid"     ["run_orog"]="make_orog"  \
           ["run_sfc"]="make_sfc_climo" ["run_ics"]="make_ics"    \
           ["run_lbc"]="make_lbcs"      ["run_fcst"]="run_fcst"   \
           ["run_post"]="run_post" )

queues=(["run_grid"]="${QUEUE_DEFAULT}" ["run_orog"]="${QUEUE_DEFAULT}" \
        ["run_sfc"]="${QUEUE_DEFAULT}"  ["run_ics"]="${QUEUE_DEFAULT}"  \
        ["run_lbc"]="${QUEUE_DEFAULT}"  ["run_fcst"]="${QUEUE_FCST}"    \
        ["run_post"]="${QUEUE_DEFAULT}")

wrappers=(["run_grid"]="run_make_grid.sh"     ["run_orog"]="run_make_orog.sh" \
          ["run_sfc"]="run_make_sfc_climo.sh" ["run_ics"]="run_make_ics.sh"   \
          ["run_lbc"]="run_make_lbcs.sh"      ["run_fcst"]="run_fcst.sh"      \
          ["run_post"]="run_post.sh" )


#---------------- Decode rocoto XML file -------------------------------

metatask=""
if [[ $task =~ "run_post" ]]; then
  metatask="-m"
fi

resources=$($xmlparser -t ${tasknames[$task]} $metatask -g nodes $EXPTDIR/FV3LAM_wflow.xml)
#echo $resources

nodes=${resources%%:ppn=*}
ppn=${resources##?:ppn=}
numprocess=$(( nodes*ppn ))
walltime=$($xmlparser -t ${tasknames[$task]} $metatask -g walltime $EXPTDIR/FV3LAM_wflow.xml)
queue=${queues[$task]}

if [[ $verb -eq 1 ]]; then
    echo "taskname = ${tasknames[$task]}"
    echo "nodes    = $nodes,   ppn = $ppn"
    echo "walltime = $walltime"
    echo "queue    = $queue"
fi

##================ Prepare job script ==================================

CODEBASE="${HOMErrfs}"

WRKDIR="${LOGDIR}"
if [[ ! -d $WRKDIR ]]; then
  mkdir $WRKDIR
fi

cd $WRKDIR

read -r -d '' taskheader <<EOF
#!/bin/sh -l
#SBATCH -A ${ACCOUNT}
#SBATCH -p ${queue}
#SBATCH -J ${tasknames[$task]}
#SBATCH --nodes=${nodes} --ntasks-per-node=${ppn}
#SBATCH --exclusive
#SBATCH -t ${walltime}
#SBATCH -o out.${tasknames[$task]}_%j
#SBATCH -e err.${tasknames[$task]}_%j

source /scratch/software/Odin/python/anaconda2/etc/profile.d/conda.sh
conda activate regional_workflow

export EXPTDIR=${EXPTDIR}

EOF

##@@@@@@@@@@@@@@@@@@@@@ Submit job script @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

jobscript="${tasknames[$task]}.job"

sed "1d" ${CODEBASE}/ush/wrappers/${wrappers[$task]}  > ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

if [[ $verb -eq 1 ]]; then
    echo "jobscript: $WRKDIR/$jobscript is created."
fi

if [[ $show -ne 1 ]]; then
    sbatch ${jobscript}
fi

exit 0
