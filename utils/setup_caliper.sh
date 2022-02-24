export CALI_CHANNEL_FLUSH_ON_EXIT=false
export CALI_MPIREPORT_FILENAME=caliper.json
export CALI_MPIREPORT_LOCAL_CONFIG="SELECT sum(sum#time.duration),
                                           inclusive_sum(sum#time.duration)
                                    GROUP BY prop:nested"
export CALI_MPIREPORT_CONFIG='SELECT annotation,
                                     mpi.function,
                                     min(sum#sum#time.duration) as "exclusive_time_rank_min",
                                     max(sum#sum#time.duration) as "exclusive_time_rank_max",
                                     avg(sum#sum#time.duration) as "exclusive_time_rank_avg",
                                     min(inclusive#sum#time.duration) AS "inclusive_time_rank_min",
                                     max(inclusive#sum#time.duration) AS "inclusive_time_rank_max",
                                     avg(inclusive#sum#time.duration) AS "inclusive_time_rank_avg",
                                     percent_total(sum#sum#time.duration) AS "Exclusive time %",
                                     inclusive_percent_total(sum#sum#time.duration) AS "Inclusive time %"
                                     GROUP BY prop:nested FORMAT json'
export CALI_SERVICES_ENABLE=aggregate,event,mpi,mpireport,nvtx,timestamp
# Everything not blacklisted is profiled. This list was stolen from Caliper...
export CALI_MPI_BLACKLIST="MPI_Comm_rank,MPI_Comm_size,MPI_Wtick,MPI_Wtime"
# Called after CoreNEURON has exited but in the context of the sbatch script
function augment_caliper_json {
  neurodamus_version="$1"
  configuration_slug="$2"
  working_directory="$3"
  coreneuron_input="$4"
  num_gpus="$5"
  module load jq
  module list
  jq_template="{\"data\": ."
  jq_template+=",\"neurodamus_version\": \"${neurodamus_version}\""
  jq_template+=",\"backend\": \"${configuration_slug}\""
  jq_template+=",\"coreneuron_input\": \"${coreneuron_input}\""
  jq_template+=",\"output_directory\": \"${working_directory}\""
  jq_template+=",\"gpus_per_node\": \"${num_gpus}\""
  jq_template+=",\"env\": {"
  first=1
  for slurm_var in "${!SLURM_@}" "${!NVCOMPILER_@}" "${!CALI_@}"
  do
    if [[ ${first} == 1 ]];
    then
      first=0
    else
      jq_template+=","
    fi
    jq_template+="\"${slurm_var}\": \"$(echo ${!slurm_var} | sed -e 's/\"/\\\"/g')\""
  done
  jq_template+="}}"
  mv caliper.json caliper.json.orig
  jq "${jq_template}" < caliper.json.orig > caliper-${SLURM_JOBID}.json
}
