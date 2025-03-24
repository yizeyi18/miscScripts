#!/bin/bash
#
# Setting up work environment with spack stepwise.
# needs: gcc 4.8.5+.
#
# Stage 1:
#   install binutils & gcc
# Stage 2:
#   add newly installed gcc into spack compilers, install python and 
#   its dependencies: zlib-ng, cmake
# Stage 3:
#   install llvm & rust and their dependencies: hwloc, ninja
# Stage 4:
#   install tools for running a mpi-driven software: ucx for
#   communication, numactl, pmix and openmpi
# Stage 5:
#   install mathlibs: blas, lapack, scalapack, fftw, elpa
# Stage 6:
#   install hpc basic software: libxc, libint, hdf5 and their 
#   dependencies: eigen, boost
# 
#
# ISSUES to be considered:
#   - Using system munge/slurm/pmix implementation instead of 
#     installing in user space? pmix can be combined with munge, 
#     what would happen if munge present?
#   - Should a manually installed glibc present in the setting up?
#     Some old system quite needs a new glibc, but spack provides 
#     little options for customization. If do so, in which step should
#     the new glibc be introduced - before Stage 1 (the whole stack
#     installed would be linked with this glibc), between Stage 3 & 4(
#     only use it for computing runtimes), or at any stage else?
#   - gcc-driven stack or llvm-driven? Currently gcc, as no 
#     accelerator used in my workspace. If accelerator present, from
#     which stage should llvm being used? Runtime could be installed
#     with spack or not, driver must not. Should the script consider
#     runtime installation or expect them being shipped with drivers?
#   - How to deal with openacc? vasp uses it but never heard of from
#     compiler. would gcc be ok with drivers present for amd gpu?
#
# ISSUES to be noticed setting up spack environment spec:
#   - bt-stage1: None.
#   - bt-stage2: +tkinter would yield concretizer error,
#     due to circular dependency.
#   - bt-stage3: hwloc+cairo would bring glib@2.78 into spec tree
#     which requires python@:3.11
#   - bt-stage4: knem should be knem@master according to its
#     official website. New versioned had been not released
#     since ~10 yrs ago.
#   - bt-stage5: elpa +autotune have type mismatch issue
#     and needed fortran flag had not been added to spack repo.
#     openblas may be better with fixed target & no parallel
#     for HPC-software with OpenMP implemented.
#   - bt-stage6: libint builds very slow. Take care!
#     boost required cxxstd=17 in one concretize, but fails
#     to be repeated. No idea about why.

# Function to install a stage
install_stage() {
  local stage_dir=$1
  echo "Installing $stage_dir"
  if [ -d "$stage_dir" ]; then
    rm -r "$stage_dir"
  fi
  spack env create -d $stage_dir
  cp environments/$stage_dir/* $stage_dir
  spack env activate $stage_dir
  spack concretize || { echo "$stage_dir failed"; exit 1; }
  spack install || { echo "$stage_dir failed"; exit 1; }
  spack env deactivate 
}

install_stage bt-stage1
spack install gcc
spack compiler find

install_stage bt-stage2
install_stage bt-stage3
install_stage bt-stage4
install_stage bt-stage5
install_stage bt-stage6
bash ./install_preconfigured_soft.sh cp2k
