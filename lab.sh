#!/bin/sh

#SBATCH --job-name=JupyterLab
#SBATCH --output=jupyter/output.%j.out
#SBATCH --error=jupyter/output.%j.err


# Needed for a bug in jupyter 
unset XDG_RUNTIME_DIR


# Node info
node=$(hostname -s)
user=$(whoami)

loginnode=${SLURM_SUBMIT_HOST:?'error: you must use sbatch to submit this script'}


# Predefined port for localhost (the local machine)
port=15497
URL=http://localhost:$port


# Get random port for master node-node tunnel
# Check if available
while
  hostport=$(shuf -n 1 -i 49152-65535)
  ss -lpn  | grep -q "$hostport"
do
  continue
done



# print tunneling instructions too above output log
cat <<EOF
##########################################################

Use this command to create SSH tunnel:

ssh -f -N -L localhost:${port}:${node}:${hostport} ${user}@${loginnode}

You can change this --^port^-- if it is not available on your local machine
with the following code:

-------------------------------------------------------------------------------------------
while
  port=$(shuf -n 1 -i 49152-65535)
  ss -lpn  | grep -q "$port"
do
  continue
done


echo "ssh -f -N -L localhost:\${port}:${node}:${hostport} ${user}@${loginnode}"
-------------------------------------------------------------------------------------------



For Windows, use this info:

    Forwarded port: ${port} <--
    Remote server: ${node}
    Remote port: ${hostport}
    SSH server: ${loginnode}
    SSH login: ${user}
    SSH port: 22

Then use this URL to access Jupyter (NOT the one in the log below):

$URL
##########################################################
EOF


# Activate environment
. $( echo ~ )/jupyter/venv/bin/activate

# Run jupyter lab
echo 'Lauching Jupyter Server'
while [ 1 ]
do
nice -20 jupyter-lab \
        --no-browser \
        --ServerApp.token='' \
        --port=${hostport} \
        --ip=0.0.0.0 \
        --ServerApp.shutdown_no_activity_timeout=86400 \
        --ServerApp.iopub_data_rate_limit=1.0e10 \
        --ResourceUseDisplay.mem_warning_threshold=0.1 \
        --ResourceUseDisplay.track_cpu_percent=True \
        --ResourceUseDisplay.enable_prometheus_metrics=False
done

echo 'Exit...'
exit