# script used to install pre-configured spack package.
#

# 解析命令行参数
if [ $# -eq 0 ]; then
    echo "Usage: $0 <spack_environment>"
    exit 1
fi

SPACK_ENV=("$@")

install_stage() {
  local stage_dir=$1
  echo "Installing $stage_dir"
  if [ -d "$stage_dir" ]; then
    rm -r "$stage_dir"
  fi
  spack env create -d $stage_dir
  cp environments/$stage_dir/* $stage_dir
  spack -e $stage_dir concretize || { echo "$stage_dir failed"; exit 1; }
  #spack env activate $stage_dir
  #echo "activated spack environment $stage_dir"
  #spack concretize || { echo "$stage_dir failed"; exit 1; }
  spack -e $stage_dir install || { echo "$stage_dir failed"; exit 1; }
  #despacktivate
}

for env in "${SPACK_ENV[@]}"; do
    install_stage $env
done

