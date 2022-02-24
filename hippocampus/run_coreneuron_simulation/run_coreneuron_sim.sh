#!/bin/bash
#SBATCH --account=proj16
#SBATCH --ntasks=80
#SBATCH --partition=prod
#SBATCH --time=8:00:00
#SBATCH --cpus-per-task=2
#SBATCH --constraint="cpu&clx"
#SBATCH --exclusive
#SBATCH --nodes=2
#SBATCH --mem=0
cnrn_input="$1"
model_suffix="$2"
hip_prefix=/gpfs/bbp.cscs.ch/project/proj16/NEURONFrontiers2021/hippocampus
cnrn_input_conf="${hip_prefix}/generate_coreneuron_input/${cnrn_input}/output/sim.conf"
module purge
# Get modules from the local Spack install.
module use ${hip_prefix}/spack/share/spack/modules/linux-rhel7-x86_64
neurodamus_version=neurodamus-hippocampus/1.5.0.20211008-3.3.2
module load unstable ${neurodamus_version}${model_suffix}
working_dir="${hip_prefix}/run_coreneuron_simulation/${SLURM_JOBID}-cpu${model_suffix}"
mkdir -p "${working_dir}"
cd "${working_dir}"
cp "${hip_prefix}/run_coreneuron_simulation/setup_caliper.sh" .
module list
env | grep SLURM_
. setup_caliper.sh
echo Launching CoreNEURON on CPU using input config ${cnrn_input_conf}
srun dplace special-core --read-config "${cnrn_input_conf}" --outpath .
augment_caliper_json ${neurodamus_version} cpu${model_suffix} "${working_dir}" "${cnrn_input_conf}"
mv ../slurm-${SLURM_JOBID}.out .
