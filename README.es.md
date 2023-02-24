# **Servidor de Jupyter para `shiva`**

[![gl](https://img.shields.io/badge/lang-gl-9cf.svg)](./README.md)
[![es](https://img.shields.io/badge/lang-es-red.svg)](./README.es.md)
[![en](https://img.shields.io/badge/lang-en-blue.svg)](./README.en.md)



¡Hola! Este repositorio permite la instalación de JupyterLab en un sistema con Python instalado o disponible a través de `module` y preparado para ser empleado mediante `ssh`.  

Una vez instalado, tendrás disponible un comando con el que iniciar el servidor y otro para conectarte a él desde un ordenador remoto.

# Requisitos
- SLURM: asumimos que existe este sistema de cola de trabajos para ejecutar el servidor de Jupyter con un comando de `sbatch`.
- Configuración de ssh del *HPC*: si tienes que pasar por un servidor previo para acceder al *HPC*, este debe estar configurado previamente en el archivo `~/.ssh/config`. Si no, el comando de `jupy_ssh` no funcionará.

Es recomendable que también tengas tu identificación de ssh copiada en el *HPC* para poder conectarte **y reconectarte** sin preocuparte por poner contraseñas.

# Instrucciones
## En el ordenador local

### Configuración de ssh
Es posible que tengas que conectarte a un servidor previo desde el que puedes acceder al *HPC*. Si no es tu caso porque estás trabajando desde un ordenador con acceso por ssh al *HPC*, puedes pasar al siguiente paso.
En el caso de `shiva`, para acceder desde fuera de la red tienes que pasar por `zeus`. Este paso intermedio se puede automatizar añadiendo las siguientes líneas al archivo `.ssh/config`:

```
Host zeus
    HostName zeus.upf.edu
    User ***

Host shiva
    HostName shiva.prib.upf.edu
    User ***
    ProxyJump zeus  # Omit this line if you can ssh to shiva
```
En `User`, donde pone `***`, debes poner tu nombre de usuario en el *HPC*. Si no tienes la carpeta `.ssh` o el archivo `config` dentro de ella, puedes crear ambos manualmente con tranquilidad:

```
mkdir ~/.ssh
touch ~/.ssh/config
```
Edítalo y añade las líneas anteriores con tu usuario:
```
nano ~/.ssh/config ## para editar en la consola
```


Ahora, `ssh shiva` equivale a
```
ssh user@zeus.upf.edu
ssh user@shiva.prib.upf.edu

## o
ssh -J user@zeus.upf.edu user@shiva.prib.upf.edu
```

<details>
  <summary>Ejemplo de .ssh/config</summary>

    Como ejemplo, mi archivo `.ssh/config` para conectarme a `shiva` es así:

    ```
    # Read more about SSH config files: https://linux.die.net/man/5/ssh_config

    Host zeus
        HostName zeus.upf.edu
        User xoel

    Host shiva
        HostName shiva.prib.upf.edu
        User xoel
</details>

## En el *HPC*
Ahora, conéctate al *HPC* en el que desees instalar Jupyter. Puedes usar estas instrucciones en el nodo de acceso, pero es recomendable que lo hagas en un nodo de computación.

0. Debes estar en el HPC:
```
ssh shiva
# Puedes iniciar una sesión interactiva en un nodo de computación con:
srun --pty --mpi=none bash
```

1. Clona o descarga este repositorio en tu carpeta de usuario.
```
cd ~

git clone https://github.com/EvolutionaryGenomics-GRIB/jupyter
```
2. Ejecuta el script `init.sh`.
```
bash ~/jupyter/init.sh
```
También puedes hacerlo en un nodo de computación (si no estás en uno) con
```
sbatch ~/jupyter/init.sh  # Espera a que termine
```
3. Actualiza el entorno para disponer de los nuevos comandos.
```
source ~/.bashrc
```

# Uso

## En el *HPC*
1. Inicia el servidor desde el *HPC*. **No lo hagas desde un nodo de computación**:
```
jupy_start
```
Si quieres configurar el trabajo de slurm en el que se ejecuta el servidor de Jupyter, siempre puedes iniciar el servidor manualmente e introduciendo la configuración que quieras con:
```
sbatch ~/jupyter/init.sh
```
2. Cuando el trabajo esté en ejecución, obtén el comando ssh de JupyterLab con
```
jupy_ssh
```
Copia el comando y ejecútalo en la computadora local.

3. Obtén la dirección del servidor con:
```
jupy_url
```
Por defecto, esta siempre es `http://localhost:15497`, pero si tienes problemas con este puerto, revisa los *outputs* de cualquier sesión del servidor en `~/jupyter/*.out`.

## En la computadora local
1. Ejecuta el comando mostrado por `jupy_ssh`.  
Si este comando te da error, es probable que tengas alguna sesión anterior de ssh empleando este puerto. Puedes comprobarlo con ayuda de `htop`, localizando (`F4`) el proceso de `ssh` y matándolo (`k`).
2. Abre en el navegador la dirección de `jupy_url`.


# Acceso con identidad (recomendado)
Con este paso podrás acceder al *HPC* sin contraseñas, empleando un archivo de identificación.

Si aún no tienes un archivo de identidad, puedes crearlo con:
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

El comando que proporciona `jupy_ssh` **no debe ser ejecutado en los nodos del HPC**, debe ser ejecutado en la computadora local desde la que te deseas conectarte.

Los outputs del servidor son redirigidos (con `sbatch --output --error`) a un log individual en la carpeta `~/jupyter`. Esto permite que se puedan ejecutar servidores de JupyterLab en paralelo como trabajos distintos sin que se interrumpan entre sí.

<details>
    <summary>Nota sobre puerto local y múltiples servidores</summary>
        Por defecto, el puerto local es `15497`. Si deseas ejecutar varias sesiones en la misma computadora local, necesitarás utilizar un puerto diferente para cada una. Para obtener más ayuda y obtener un comando de ssh con un puerto nuevo, revisa los outputs de cualquier sesión del servidor en `~/jupyter/*.out`.
</details>


# To do list:
- [ ] Crear kernels por defecto `biobox`
- [ ] Actualizar README:
  - [X] Hacer multilingüe
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
- Added `.gitignore`
- Added `ipywidgets`, `jupyterlab_slurm`, `jupyter-resource-usage`
- Added `jupy_big`, `jupy_big`, `jupy_clean`, `jupy_out`, `jupy_log`  
- Added translations (Credits to ChatGPT)