submitted_jobs=""
function run_sbatch {
  new_jobid=$(sbatch --parsable "$@")
  submitted_jobs+=",${new_jobid}"
}
#run_sbatch run_coreneuron_sim.sh ${coreneuron_input} -ispc-nmodl-sympy
#'-nmodl-sympy-sympyopt'
for i in {0..9}
do
    for translator in '' '-nmodl-sympy' '-nmodl'
    do
      run_sbatch run_coreneuron_sim.sh ${translator}
      for ngpus_per_node in 2 4
      do
        for accsync in asynchronous synchronous
        do
          run_sbatch --gres=gpu:${ngpus_per_node} run_coreneuron_gpu_sim.sh "${translator}" "${accsync}" "${ngpus_per_node}"
        done
      done
    done
done
echo "Submitted Slurm jobs {${submitted_jobs:1}}"
echo "Once the jobs have finished, you might like to download the results with something like:"
echo "  scp 'bbpv2:$(pwd -P)/{${submitted_jobs:1}}/caliper-*.json' \${HOME}/build/neuron-frontiers-2021-paper/data/"
