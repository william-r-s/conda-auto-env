#!/bin/bash

# conda-auto-env automatically activates a conda environment when
# entering a folder with an environment.yml file.
#
# If the environment doesn't exist, conda-auto-env creates it and
# activates it for you.
#
# To install add this line to your .bashrc, .bash-profile, or .zshrc:
#
#       source /path/to/conda_auto_env.sh
#

function conda_auto_env() {
  if [ -e "environment.yml" ]; then
    # echo "environment.yml file found"
    ENV=$(head -n 1 environment.yml | cut -f2 -d ' ')
    # Check if the environment is already active.
    if [[ $PATH != */envs/*$ENV*/* ]]; then
      # Attempt to activate environment.
      CONDA_ENVIRONMENT_ROOT="" #For spawned shells
      source activate $ENV
      # Set root directory of active environment.
      CONDA_ENVIRONMENT_ROOT="$(pwd)"
      if [ $? -ne 0 ]; then
        # Create the environment and activate.
        echo "Conda environment '$ENV' doesn't exist: Creating."
        conda env create -q
        source activate $ENV
      fi
    fi
  # Deactivate active environment if we are no longer among its subdirectories.
  elif [[ $PATH = */envs/* ]]\
    && [[ $(pwd) != $CONDA_ENVIRONMENT_ROOT ]]\
    && [[ $(pwd) != $CONDA_ENVIRONMENT_ROOT/* ]]
  then
    CONDA_ENVIRONMENT_ROOT=""
    source deactivate
  fi
}

# Check active shell.
if [[ $(ps -p$$ -ocmd=) == *zsh* ]]; then
  # For zsh, use the chpwd hook.
  autoload -U add-zsh-hook
  add-zsh-hook chpwd conda_auto_env
  # Run for present directory as it does not fire the above hook.
  conda_auto_env
  # More aggressive option in case the above hook misses some use case:
  #precmd() { conda_auto_env; }
else
  # For bash, no hooks and we rely on the env. var. PROMPT_COMMAND:
  export PROMPT_COMMAND=conda_auto_env
fi
