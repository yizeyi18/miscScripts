#!/bin/bash

install_stage() {
  local stage=$1
  echo "Installing $stage"
  if [ -d "$stage" ]; then
    rm -r "$stage"
  fi
  spack env create -d $stage environments/${stage}.yaml
  spack env activate $stage
  spack concretize || { echo "$stage failed"; exit 1; }
  spack install || { echo "$stage failed"; exit 1; }
  spack env deactivate
}

install_stage new_stage1
install_stage new_stage2
install_stage new_stage3
