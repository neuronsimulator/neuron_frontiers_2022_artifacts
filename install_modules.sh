#!/bin/bash
set -e
SPACK_ARGS="--config-scope spack-config/"
echo HOME=$(pwd)  # to try and avoid spack looking for .spack and my own config
module purge
module load unstable python gcc git
export SPACK_INSTALL_PREFIX=/gpfs/bbp.cscs.ch/project/proj16/NEURONFrontiers2021/hippocampus/spack/opt/spack
. spack/share/spack/setup-env.sh
NEURON_VERSION="neuron@8.0.0.20211015"
NEURON_VARIANT="+caliper~rx3d~legacy-unit"
NEURODAMUS_VERSION="neurodamus-hippocampus@1.5.0.20211008-3.3.2"
NEURODAMUS_VARIANT="+coreneuron"
OLFACTORY_VERSION="olfactory-bulb-3d@0.1.20211014"
NVHPC_VERSION="nvhpc@21.2"
PY_NETPYNE_VERSION="py-netpyne@v1.0.0.2-20211124"
NETPYNE_M1_VERSION="netpyne-m-one@0.1-20211206"

# Extra constraints that are desirable for NVHPC builds and that we might as
# well use for everything.
EXTRA_CONSTRAINTS="  ^cuda@11.0.2"
EXTRA_CONSTRAINTS+=" ^caliper%gcc+adiak+cuda~fortran+gotcha~ipo+libdw~libpfm+libunwind+mpi+papi+sampler+shared~sosflow cuda_arch=70"
EXTRA_CONSTRAINTS+=" ^gettext%gcc"
EXTRA_CONSTRAINTS+=" ^hpe-mpi@2.25.hmpt%gcc"
EXTRA_CONSTRAINTS+=" ^py-cython%gcc"
EXTRA_CONSTRAINTS+=" ^py-numpy%gcc"
EXTRA_CONSTRAINTS+=" ^readline%gcc"
EXTRA_CONSTRAINTS+=" ^m4%gcc"
EXTRA_CONSTRAINTS+=" ^pkgconf%gcc"
EXTRA_CONSTRAINTS+=" ^libiconv%gcc"
EXTRA_CONSTRAINTS+=" ^bison%gcc"
EXTRA_CONSTRAINTS+=" ^flex%gcc"
EXTRA_CONSTRAINTS+=" ^ninja%gcc"
EXTRA_CONSTRAINTS_NEURODAMUS=" ^hdf5%gcc"
EXTRA_CONSTRAINTS_NEURODAMUS+=" ^py-mvdtool%gcc"
EXTRA_CONSTRAINTS_NEURODAMUS+=" ^reportinglib%gcc"
EXTRA_CONSTRAINTS_NEURODAMUS+=" ^spdlog%gcc"
EXTRA_CONSTRAINTS_NEURODAMUS+=" ^synapsetool%gcc"
EXTRA_CONSTRAINTS_NEURODAMUS+=" ^libsonata-report%gcc"
EXTRA_CONSTRAINTS_NETPYNE="^py-matplotlib%gcc"
EXTRA_CONSTRAINTS_NETPYNE+="^py-matplotlibscalebar%gcc"
EXTRA_CONSTRAINTS_NETPYNE+="^py-scipy%gcc"
#EXTRA_CONSTRAINTS+=" ^/jgmkyfa" # hdf5%gcc that's already installed

spack ${SPACK_ARGS} spec -IL jq
spack ${SPACK_ARGS} install jq
for nmodl in '~nmodl' '+nmodl' '+nmodl+sympy' #'+nmodl+sympy+sympyopt'
do
  CORENEURON_VERSION="coreneuron@1.0.0.20211020"
  CORENEURON_VARIANT="+caliper~report~legacy-unit${nmodl}"
  if [[ ${nmodl} == *"+nmodl"* ]]
  then
    NMODL_SPEC=" ^nmodl@0.3.0.20220110%gcc~legacy-unit ^py-jinja2%gcc ^py-sympy%gcc ^py-pyyaml%gcc"
  else
    unset NMODL_SPEC
  fi
  # Build with Intel.
  NEURODAMUS_SPEC="${NEURODAMUS_VERSION}%intel${NEURODAMUS_VARIANT}"
  OLFACTORY_SPEC="${OLFACTORY_VERSION}%intel"
  SPACK_SPEC=" ^${NEURON_VERSION}%intel${NEURON_VARIANT}"
  SPACK_SPEC+=" ^${CORENEURON_VERSION}%intel${CORENEURON_VARIANT}${NMODL_SPEC}"
  SPACK_SPEC+="${EXTRA_CONSTRAINTS}"
  NEURODAMUS_SPEC+="${SPACK_SPEC}${EXTRA_CONSTRAINTS_NEURODAMUS}"
  OLFACTORY_SPEC+="${SPACK_SPEC}"
  NETPYNE_M1_SPEC="${NETPYNE_M1_VERSION}%intel${SPACK_SPEC}"
  spack ${SPACK_ARGS} spec -IL ${NEURODAMUS_SPEC}
  spack ${SPACK_ARGS} install ${NEURODAMUS_SPEC}
  spack ${SPACK_ARGS} spec -IL ${OLFACTORY_SPEC}
  spack ${SPACK_ARGS} install ${OLFACTORY_SPEC}
  spack ${SPACK_ARGS} spec -IL ${NETPYNE_M1_SPEC}
  spack ${SPACK_ARGS} install ${NETPYNE_M1_SPEC}
  # Build with ISPC too for Intel+NMODL+Sympy
  #if [[ "${nmodl}" == "+nmodl+sympy"* ]]
  #then
  #  NEURODAMUS_SPEC="${NEURODAMUS_VERSION}%intel${NEURODAMUS_VARIANT}"
  #  OLFACTORY_SPEC="${OLFACTORY_VERSION}%intel"
  #  SPACK_SPEC=" ^${NEURON_VERSION}%intel${NEURON_VARIANT}"
  #  SPACK_SPEC+=" ^${CORENEURON_VERSION}%intel+ispc${CORENEURON_VARIANT}${NMODL_SPEC}"
  #  SPACK_SPEC+="${EXTRA_CONSTRAINTS}"
  #  NEURODAMUS_SPEC+="${SPACK_SPEC}${EXTRA_CONSTRAINTS_NEURODAMUS}"
  #  OLFACTORY_SPEC+="${SPACK_SPEC}"
  #  spack ${SPACK_ARGS} spec -IL ${NEURODAMUS_SPEC}
  #  spack ${SPACK_ARGS} install ${NEURODAMUS_SPEC}
  #  spack ${SPACK_ARGS} spec -IL ${OLFACTORY_SPEC}
  #  spack ${SPACK_ARGS} install ${OLFACTORY_SPEC}
  #fi
  # Build with NVHPC/GPU support.
  NEURODAMUS_SPEC="${NEURODAMUS_VERSION}%${NVHPC_VERSION}${NEURODAMUS_VARIANT}"
  OLFACTORY_SPEC="${OLFACTORY_VERSION}%${NVHPC_VERSION}"
  SPACK_SPEC=" ^${NEURON_VERSION}%${NVHPC_VERSION}${NEURON_VARIANT}"
  SPACK_SPEC+=" ^${CORENEURON_VERSION}%${NVHPC_VERSION}${CORENEURON_VARIANT}+gpu${NMODL_SPEC}"
  SPACK_SPEC+="${EXTRA_CONSTRAINTS}"
  NEURODAMUS_SPEC+="${SPACK_SPEC}${EXTRA_CONSTRAINTS_NEURODAMUS}"
  OLFACTORY_SPEC+="${SPACK_SPEC}"
  NETPYNE_M1_SPEC="${NETPYNE_M1_VERSION}%${NVHPC_VERSION}${SPACK_SPEC}${EXTRA_CONSTRAINTS_NETPYNE}"
  spack ${SPACK_ARGS} spec -IL ${NEURODAMUS_SPEC}
  spack ${SPACK_ARGS} install ${NEURODAMUS_SPEC}
  spack ${SPACK_ARGS} spec -IL ${OLFACTORY_SPEC}
  spack ${SPACK_ARGS} install ${OLFACTORY_SPEC}
  spack ${SPACK_ARGS} spec -IL ${NETPYNE_M1_SPEC}
  spack ${SPACK_ARGS} install ${NETPYNE_M1_SPEC}
done
spack ${SPACK_ARGS} config blame modules
spack ${SPACK_ARGS} module tcl refresh -y --latest
