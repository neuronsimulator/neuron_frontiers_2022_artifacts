#!/bin/bash
#SBATCH --account=proj16
#SBATCH --ntasks=80
#SBATCH --partition=prod_p2
#SBATCH --time=8:00:00
#SBATCH --cpus-per-task=2
#SBATCH --constraint="cpu&clx"
#SBATCH --exclusive
#SBATCH --mem=0
#SBATCH --nodes=2
olfactory_prefix="$(pwd)/.."
module purge
# Get modules from the local Spack install.
spack_prefix=/gpfs/bbp.cscs.ch/project/proj16/NEURONFrontiers2021/hippocampus
module use ${spack_prefix}/spack/opt/spack/modules/tcl/linux-rhel7-x86_64
module load unstable olfactory-bulb-3d/0.1.20211014 
output_dir="${olfactory_prefix}/generate_coreneuron_input/coredat_${SLURM_NTASKS}"
working_dir="${olfactory_prefix}/olfactory-bulb-3d/sim"
mkdir -p "${output_dir}"
cd "${working_dir}"
srun dplace special -mpi -python bulb3dtest.py --dump_model --filename="nrn_cpu"
mv coredat $output_dir
