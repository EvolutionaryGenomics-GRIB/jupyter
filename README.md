# **Servidor de Jupyter para `shiva`**

Boas! Este repositorio permite a instalación de JupyterLab nun sistema con Python instalado ou dispoñível a través de `module` e prepárao para ser empregado mediante `ssh`.  

Unha vez instalado, terás dispoñible unha comanda coa que iniciar o servidor e outra para te conectares a el dende unha computadora remota.

# Funcionamento
O *script* `init.sh` emprega o Python dispoñible no sistema para crear unha entorna virtual mediante `venv` na que instalar JupyterLab. Este *script* ten que ser executado nun nodo de computación ou, asumindo que comparten o sistema de ficheiros, no nodo de acceso do *cluster* ou *HPC* no que traballas.  

O *script* comproba se algunha entorna de `conda` ou de `venv` están activadas previamente e desactívaas se fose o caso. Tamén comproba que haxa Python dispoñible e, de non o haber, intenta cargalo con `module load Python`. A ruta da entorna que crea é `~/jupyter/venv`, sendo `~` o directorio do teu usuario.     
  
Tras a instalación, terás unha serie de comandos dispoñibles para controlares o Jupyter:
- `jupy_start`: envía á cúa de SLURM o script `lab.sh` que pon en marcha un servidor de JupyterLab.
- `jupy_ssh`: amósache o comando de `ssh` para conectar unha computadora remota ó servidor iniciado.
- `jupy_url`: amósache a direción url na que se executa o servidor de Jupyter.

O comando que facilita `jupy_ssh` **non é para executar nos nodos do *HPC*,** ten que ser executado na computadora remota que queres conectar.
  
# Requisitos
- SLURM: asumimos que hai este sistema de cúa de traballos para executar o servidor de Jupyter cunha comanda de `sbatch`. 
- Configuración de ssh do *HPC*: se tes que pasar por un servidor previo para accederes ó *HPC*, este ten que estar configurado previamente no ficheiro `~/.ssh/config`. Se non, o comando de `jupy_ssh` non funcionará.

É recomendable que tamén teñas a túa identificación de ssh copiada no *HPC* para poder conectarte **e reconectarte** sen te preocupar por póres contrasinais.

# Instrucións

## Configuración de ssh
É posible que te teñas que conectar a un servidor previo dende o que podes acceder ó *HPC*. No caso do `shiva`, para accederes dende fóra da rede tes que pasar por `zeus`. Este paso intermedio pódese automatizar engadindo as seguintes liñas ó ficheiro `.ssh/config`:

```
Host zeus
    HostName zeus.upf.edu
    User ***

Host shiva
    HostName shiva.prib.upf.edu
    User ***
    ProxyJump zeus
```
En `User`, onde pon `***` tes que pór o teu nome de usuario no *HPC*. Se non tes o cartafol `.ssh` ou o ficheiro `config` dentro del, podes crear ambos manualmente con tranquilidade:

```
mkdir ~/.ssh
touch ~/.ssh/config
```
Edítao e engade as liñas anteriores co teu usuario:
```
nano ~/.ssh/config ## to edit on console
```
Como exemplo, o meu ficheiro `.ssh/config` para me conectar ó `shiva` é así:
```
# Read more about SSH config files: https://linux.die.net/man/5/ssh_config

Host zeus
    HostName zeus.upf.edu
    User xoel

Host shiva
    HostName shiva.prib.upf.edu
    User xoel
    ProxyJump zeus

Host palermo
    HostName palermo.prib.upf.edu
    User xoel
    ProxyJump zeus
```

## Acceso con identidade (recomendado)
...


## No *HPC*
Primeiro, conéctate o *HPC* no que queiras instalar Jupyter. Podes empregar estas instrucións no nodo de acceso, mais é recomendable que o fagas nun nodo de computación

0. Debes estar no HPC

1. Clona ou descarga este repositorio no teu cartafol de usuario.
```
cd ~
# Clone repo
...
```
2. Executa o script `init.sh`.
```
sh ~/jupyter/init.sh
```
Tamén podes facelo nun nodo de computación con
```
sbatch ~/jupyter/init.sh
```
3. Actualiza a entorna para dispór das novas comandas.
```
source ~/.bashrc
```
4. Proba o servidor
```
jupy_start
```


# Uso




### To do list:
- [ ] Actualizar README:
  - [ ] Facer multilingua
- [ ] Pór instrucións sobre `ssh .config`
- [ ] Modificables:
  - [ ] nome e ruta da entorna creada
  - [ ] desactivación de entornas 
  - [ ] creación de alias
  - [ ] porto local
  - [ ] porto remoto
