#/bin/sh

#########################
# TO DO:
########
#
# 1. Add changeable path.
# 2. Check if venv is there or install
# 3. 
#
#########################


ENV_DIR="$(echo ~)/jupyter/venv"
UNLOAD=0


# Test if a conda env is enabled
if [  ! -z "$CONDA_PREFIX" ];
then
echo "Deactivating conda environment ($CONDA_PREFIX)"
conda deactivate
fi

# Test if a venv is enabled
if [ ! -z "$VIRTUAL_ENV" ];
then
echo "Deactivating venv environment ($VIRTUAL_ENV)"
deactivate
fi


# Check if python exists
PYTHON_BIN=$(which python)

if [ -z "$PYTHON_BIN" ];
then
# Load from modules
echo "Loading python from installed modules"
module load Python
PYTHON_BIN=$(which python)
UNLOAD=1
fi

echo "Using Python: $PYTHON_BIN"

# Create environment from current python
VENV_TEST=$(pip list | grep -F venv)
# We don't test for venv and just assume it's there and working.
echo "Creating environment in $ENV_DIR"
python -m venv $ENV_DIR


if [ $UNLOAD ];
then
echo "Unloading Python"
module unload Python
fi


echo "Activating enviroment"
source $ENV_DIR/bin/activate

echo "Updating enviroment"
pip install --upgrade pip

echo "Installing jupyter"
pip install jupyterlab


###########################
# Add aliases to .bashrc
cat >> ~/.bashrc <<EOF
alias jupy_ssh="cat \$(ls -r jupyter/*.out | head -1 ) | grep ssh | grep -v \""
alias jupy_start="sbatch ~/jupyter/init.sh"
alias jupy_url="cat \$(ls -r jupyter/*.out | head -1 ) | grep http://localhost "
EOF

