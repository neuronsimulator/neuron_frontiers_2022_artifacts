#!/bin/bash
#SBATCH --account=proj16
#SBATCH --ntasks=80
#SBATCH --partition=prod
#SBATCH --time=8:00:00
#SBATCH --cpus-per-task=2
#SBATCH --constraint="cpu&clx"
#SBATCH --exclusive
#SBATCH --mem=0
#SBATCH --nodes=2
model_suffix="$1"
netpyne_m1_prefix="$(pwd)/.."
cnrn_input_data="${netpyne_m1_prefix}/generate_coreneuron_input/coredat_${SLURM_NTASKS}/coredat"
module purge
# Get modules from the local Spack install.
spack_prefix=/gpfs/bbp.cscs.ch/project/proj16/NEURONFrontiers2021/hippocampus
module use ${spack_prefix}/spack/opt/spack/modules/tcl/linux-rhel7-x86_64
netpyne_m1_version=netpyne-m-one/0.1-20211206
module load unstable ${netpyne_m1_version}${model_suffix}
working_dir_prefix="$(pwd)"
working_dir="${working_dir_prefix}/${SLURM_JOBID}-cpu${model_suffix}"
mkdir -p "${working_dir}"
cd "${working_dir}"
cp "${working_dir_prefix}/setup_caliper.sh" .
module list
env | grep SLURM_
. setup_caliper.sh
echo Launching CoreNEURON on CPU using input data ${cnrn_input_data}
srun dplace special-core --datpath "${cnrn_input_data}" --tstop 1000 --mpi --voltage=1000.
augment_caliper_json ${netpyne_m1_version} cpu${model_suffix} "${working_dir}" "${cnrn_input_data}" 0
mv ../slurm-${SLURM_JOBID}.out .
