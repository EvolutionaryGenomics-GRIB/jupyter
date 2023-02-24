# **Jupyter server for `shiva`**

[![gl](https://img.shields.io/badge/lang-gl-blue.svg)](./README.md)
[![es](https://img.shields.io/badge/lang-es-red.svg)](./README.es.md)
[![en](https://img.shields.io/badge/lang-en-black.svg)](./README.en.md)

Hello! This repository allows you to install JupyterLab on a system with Python installed or available through `module`, and ready to be used through `ssh`.

Once installed, you will have a command available to start the server and another to connect to it from a remote computer.

# Requirements
- SLURM: We assume that this job queue system exists to run the Jupyter server with an `sbatch` command.
- ssh configuration for the *HPC*: if you have to go through a previous server to access the *HPC*, this must be previously configured in the `~/.ssh/config` file. Otherwise, the `jupy_ssh` command will not work.

It is also recommended that you have your ssh identification copied to the *HPC* so that you can connect **and reconnect** without worrying about passwords.

# Instructions
## On the local computer

### ssh configuration
You may need to connect to a previous server from which you can access the *HPC*. If this is not your case because you are working from a computer with ssh access to the *HPC*, you can move on to the next step.
In the case of `shiva`, to access from outside the network you have to go through `zeus`. This intermediate step can be automated by adding the following lines to the `.ssh/config` file:

```
Host zeus
    HostName zeus.upf.edu
    User ***

Host shiva
    HostName shiva.prib.upf.edu
    User ***
    ProxyJump zeus  # Omit this line if you can ssh to shiva
```
In `User`, where it says `***`, you must put your username on the *HPC*. If you do not have the `.ssh` folder or the `config` file inside it, you can create both manually:

```
mkdir ~/.ssh
touch ~/.ssh/config
```
Edit it and add the previous lines with your username:
```
nano ~/.ssh/config ## to edit in console
```


Now, `ssh shiva` is equivalent to
```
ssh user@zeus.upf.edu
ssh user@shiva.prib.upf.edu

## or
ssh -J user@zeus.upf.edu user@shiva.prib.upf.edu
```

<details>
  <summary>Example of .ssh/config</summary>

    As an example, my `.ssh/config` file to connect to `shiva` looks like this:

    ```
    # Read more about SSH config files: https://linux.die.net/man/5/ssh_config

    Host zeus
        HostName zeus.upf.edu
        User xoel

    Host shiva
        HostName shiva.prib.upf.edu
        User xoel
</details>

## On the *HPC*
Now, connect to the *HPC* where you want to install Jupyter. You can use these instructions on the login node, but it is recommended to do it on a compute node.

0. You must be on the HPC:
```
ssh shiva
# You can start an interactive session on a compute node with:
srun --pty --mpi=none bash
```

1. Clone or download this repository into your user folder.
```
cd ~

git clone https://github.com/EvolutionaryGenomics-GRIB/jupyter
```
2. Execute the `init.sh` script.
```
bash ~/jupyter/init.sh
```
You can also do it on a compute node (if you are not on one) with
```
sbatch ~/jupyter/init.sh  # Wait for it to finish
```
3. Update the environment to have the new commands available.
```
source ~/.bashrc
```

# Usage

## On the *HPC*
1. Start the server from the *HPC*. **Do not do it from a compute node**:
```
jupy_start
```
If you want to configure the slurm job in which the Jupyter server runs, you can always start the server manually and enter the configuration you want with:
```
sbatch ~/jupyter/init.sh
```
2. When the job is running, get the JupyterLab ssh command with
```
jupy_ssh
```
Copy the command and run it on the local computer.

3. Get the server address with:
```
jupy_url
```
By default, this is always `http://localhost:15497`, but if you have problems with this port, check the *outputs* of any server session in `~/jupyter/*.out`.

## On the local computer
1. Run the command shown by `jupy_ssh`.  
If this command gives you an error, you probably have some previous ssh session using this port. You can check it with the help of `htop`, locating (`F4`) the `ssh` process and killing it (`k`).
2. Open the `jupy_url` address in the browser.


# Identity access (recommended)
With this step, you can access the *HPC* without passwords, using an identity file.

If you don't have an identity file yet, you can create it with:
```
ssh-keygen
```


Una vez creado, puedes enviar esta identidad a tu usuario en el *HPC* para que reconozca tu computadora local empleando este archivo automáticamente.  
Queremos hacer esto tanto en el *HPC* como en el servidor intermedio (si tenemos que pasar por uno). Es decir, queremos hacerlo en `shiva` y en `zeus`. Esto se hace con el comando:
```
ssh-copy-id -i ~/.ssh/id_rsa.pub user@zeus
ssh-copy-id -i ~/.ssh/id_rsa.pub user@shiva
```
**Cambia `user` por tu nombre de usuario.**  
Por otro lado, si tu archivo de identidad no está en la ruta por defecto `~/.ssh/id_rsa.pub`, pon `ssh-copy-id -i` en la consola y presiona `TAB`. Debería autocompletarse con la ruta correcta.

Prueba a conectarte sin contraseña con:
```
ssh shiva
```
# Funcionamiento
El script `init.sh` utiliza Python disponible en el sistema para crear un entorno virtual a través de `venv` en el que se instala JupyterLab. Este script debe ser ejecutado en un nodo de computación o, asumiendo que comparten el sistema de archivos, en el nodo de acceso del cluster o HPC en el que trabajas.

El script comprueba si ya hay algún entorno `conda` o `venv` activado y los desactiva en caso de que sea necesario. También comprueba si Python está disponible y, en caso contrario, intenta cargarlo con `module load Python`. La ruta del entorno que crea es `~/jupyter/venv`, siendo `~` el directorio de tu usuario.

Después de la instalación, tendrás una serie de comandos disponibles para controlar Jupyter:
- `jupy_start`: envía a la cola de SLURM el script `lab.sh` que inicia un servidor de JupyterLab.
- `jupy_ssh`: muestra el comando de `ssh` para conectar una computadora remota al servidor iniciado.
- `jupy_url`: muestra la dirección url en la que se ejecuta el servidor de Jupyter.

El comando que proporciona `jupy_ssh` **no debe ser ejecutado en los nodos del HPC**, debe ser ejecutado en la computadora remota a la que deseas conectarte.

Los outputs del servidor son redirigidos (con `sbatch --output --error`) a un log individual en la carpeta `~/jupyter`. Esto permite que se puedan ejecutar servidores de JupyterLab en paralelo como trabajos distintos sin que se interrumpan entre sí.

<details>
    <summary>Nota sobre puerto local y múltiples servidores</summary>
        Por defecto, el puerto local es `15497`. Si deseas ejecutar varias sesiones en la misma computadora local, necesitarás utilizar un puerto diferente para cada una. Para obtener más ayuda y obtener un comando de ssh con un puerto nuevo, revisa los outputs de cualquier sesión del servidor en `~/jupyter/*.out`.
</details>


# To do list:
- [ ] Crear kernels por defecto `biobox`
- [ ] Actualizar README:
  - [ ] Hacer multilingüe
- [X] Poner instrucciones sobre `ssh .config`
- [ ] Poner instrucciones sobre `kernels`
- [ ] Modificables:
  - [ ] nombre y ruta del entorno creado
  - [ ] desactivación de entornos
  - [ ] creación de alias
  - [ ] puerto local
  - [ ] puerto remoto
- [ ] Hacer instalador interactivo
- [ ] Poner al día la documentación


# Changelog
### 23 de febrero de 2023
- Añadido `.gitignore`
- Añadido `ipywidgets`, `jupyterlab_slurm`, `jupyter-resource-usage`
- Añadido `jupy_big`, `jupy_big`, `jupy_clean`, `jupy_out`, `jupy_log`

Once created, you can send this identity to your user on the *HPC* so that they can recognize your local computer automatically using this file. 
We want to do this both on the *HPC* and on the intermediate server (if we have to go through one). That is, we want to do it on `shiva` and `zeus`. This is done with the command:
```
ssh-copy-id -i ~/.ssh/id_rsa.pub user@zeus
ssh-copy-id -i ~/.ssh/id_rsa.pub user@shiva
```
**Change `user` to your username.** 
On the other hand, if your identity file is not in the default path `~/.ssh/id_rsa.pub`, put `ssh-copy-id -i` in the console and press `TAB`. It should autocomplete with the correct path.

Try to connect without a password with:
```
ssh shiva
```

# Functionality
The `init.sh` script uses Python available on the system to create a virtual environment through `venv` in which JupyterLab is installed. This script should be run on a compute node or, assuming that you share the file system, on the access node of the cluster or HPC you are working on.

The script checks if there is already a `conda` or `venv` environment activated and deactivates them if necessary. It also checks if Python is available and, if not, attempts to load it with `module load Python`. The path of the environment it creates is `~/jupyter/venv`, with `~` being your user directory.

After installation, you will have a series of commands available to control Jupyter:
- `jupy_start`: sends the `lab.sh` script that starts a JupyterLab server to the SLURM queue.
- `jupy_ssh`: displays the `ssh` command to connect a remote computer to the initiated server.
- `jupy_url`: shows the URL at which the Jupyter server is running.

The command provided by `jupy_ssh` **should not be run on the HPC nodes**, it should be run on the remote computer you want to connect to.

The server outputs are redirected (with `sbatch --output --error`) to an individual log in the `~/jupyter` folder. This allows JupyterLab servers to be run in parallel as separate jobs without interrupting each other.

<details>
    <summary>Note about local port and multiple servers</summary>
        By default, the local port is `15497`. If you want to run multiple sessions on the same local computer, you will need to use a different port for each one. For more help and to get an ssh command with a new port, check the outputs of any server session in `~/jupyter/*.out`.
</details>


# To do list:
- [ ] Create default kernels `biobox`
- [ ] Update README:
  - [X] Multilingual support
- [X] Put instructions on `ssh .config`
- [ ] Put instructions on `kernels`
- [ ] Configurable:
  - [ ] name and path of created environment
  - [ ] deactivation of environments
  - [ ] alias creation
  - [ ] local port
  - [ ] remote port
- [ ] Make an interactive installer
- [ ] Update documentation


# Changelog
### February 23, 2023
- Added `.gitignore`
- Added `ipywidgets`, `jupyterlab_slurm`, `jupyter-resource-usage`
- Added `jupy_big`, `jupy_big`, `jupy_clean`, `jupy_out`, `jupy_log`
- Added translations (Credits to ChatGPT)