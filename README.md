To run FV3SAR forecast on Odin/Stampede that replaces Rocoto

Step 0: Edit file config.sh following instructions on Google drive, Community Workflow Instruction,
        https://docs.google.com/document/d/1vVIge70v6Em1imsfbXEx_N0mcfU_QtghZy5AaPKwIuA/edit

Step 1: run ush/generate_FV3SAR_wflow.sh
        and link/copy ${EXPTDIR}/var_defns.sh to the script directory

Step 2: run run_fv3lam.sh following these steps one by one

    2.1: get_files.sh  var_defns.sh
    2.2: run_fv3lam.sh -r run_grid var_defns.sh
    2.3: run_fv3lam.sh -r run_orog var_defns.sh
    2.4: run_fv3lam.sh -r run_sfc  var_defns.sh
    2.5: run_fv3lam.sh -r run_ics  var_defns.sh
    2.6: run_fv3lam.sh -r run_lbc  var_defns.sh
    2.7: run_fv3lam.sh -r run_fcst var_defns.sh
    2.8: run_fv3lam.sh -r run_post var_defns.sh

Note: Step 2.2 - 2.8 will generate job script (SLURM) and then submit the job.
      Step 0, 1 and 2.1 will run the scripts on the front node.
