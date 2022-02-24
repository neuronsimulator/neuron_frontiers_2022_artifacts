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
hip_prefix=/gpfs/bbp.cscs.ch/project/proj16/NEURONFrontiers2021/hippocampus
module purge
# Get modules from the local Spack install.
module use ${hip_prefix}/spack/share/spack/modules/linux-rhel7-x86_64
module load unstable neurodamus-hippocampus/1.5.0.20210917-3.3.2 py-neurodamus
working_dir="${hip_prefix}/run_neuron_simulation/${SLURM_JOBID}"
mkdir -p "${working_dir}"
cd "${working_dir}"
cp "${hip_prefix}/blueconfigs/quick-hip-multipopulation/BlueConfig" .
sed -i -e 's/Simulator CORENEURON/Simulator NEURON/' BlueConfig
sed -i -e 's/Duration 1\s*$/Duration 100/' BlueConfig
srun dplace special -mpi -python $NEURODAMUS_PYTHON/init.py --verbose
