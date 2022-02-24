coreneuron_input=2658706
coreneuron_input=2733632 # generated with 100ms set in neurodamus
submitted_jobs=""
function run_sbatch {
  new_jobid=$(sbatch --parsable "$@")
  submitted_jobs+=",${new_jobid}"
}
#run_sbatch run_coreneuron_sim.sh ${coreneuron_input} -ispc-nmodl-sympy
#'-nmodl-sympy-sympyopt'
for translator in '-nmodl-sympy' '' '-nmodl'
do
  run_sbatch run_coreneuron_sim.sh ${coreneuron_input} ${translator}
  for ngpus_per_node in 2 4
  do
    for accsync in asynchronous synchronous
    do
      run_sbatch --gres=gpu:${ngpus_per_node} run_coreneuron_gpu_sim.sh "${coreneuron_input}" "${translator}" "${accsync}"
    done
  done
done
echo "Submitted Slurm jobs {${submitted_jobs:1}}"
echo "Once the jobs have finished, you might like to download the results with something like:"
echo "  scp 'bbpv2:$(pwd -P)/{${submitted_jobs:1}}/caliper-*.json' \${HOME}/build/neuron-frontiers-2021-paper/data/"
