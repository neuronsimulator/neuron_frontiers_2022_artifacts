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
spack_prefix=/gpfs/bbp.cscs.ch/project/proj16/NEURONFrontiers2021/hippocampus
module purge
# Get modules from the local Spack install.
module use ${spack_prefix}/spack/opt/spack/modules/tcl/linux-rhel7-x86_64
module load unstable olfactory-bulb-3d/0.1.20211014
olfactory_prefix="$(pwd)/.."
working_dir="${olfactory_prefix}/olfactory-bulb-3d/sim"
output_dir="${olfactory_prefix}/run_neuron_simulation/${SLURM_JOBID}"
mkdir -p "${output_dir}"
cd $working_dir
srun dplace special -mpi -python bulb3dtest.py --tstop=1050 --filename="nrn_cpu" |& tee "${output_dir}/NRN.log"
cat nrn_cpu.spikes* | sort -k 1n,1n -k 2n,2n > "${output_dir}/NRN.spk"
rm nrn_cpu.*
