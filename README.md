# **Servidor de Jupyter para `shiva`**


Boas! Este repositorio permite a instalación de JupyterLab nun sistema con Python instalado ou dispoñível a través de `module` e prepárao para ser empregado mediante `ssh`.  

Unha vez instalado, terás dispoñible unha comanda coa que iniciar o servidor e outra para te conectares a el dende unha computadora remota.

# Requisitos
- SLURM: asumimos que hai este sistema de cúa de traballos para executar o servidor de Jupyter cunha comanda de `sbatch`. 
- Configuración de ssh do *HPC*: se tes que pasar por un servidor previo para accederes ó *HPC*, este ten que estar configurado previamente no ficheiro `~/.ssh/config`. Se non, o comando de `jupy_ssh` non funcionará.

É recomendable que tamén teñas a túa identificación de ssh copiada no *HPC* para poder conectarte **e reconectarte** sen te preocupar por póres contrasinais.

# Instrucións
## Na computadora local

### Configuración de ssh
É posible que te teñas que conectar a un servidor previo dende o que podes acceder ó *HPC*. Se non é o teu caso porque estás traballando dende un ordenador con acceso por ssh ó *HPC*, podes pasar ó seguinte paso.  
No caso do `shiva`, para accederes dende fóra da rede tes que pasar por `zeus`. Este paso intermedio pódese automatizar engadindo as seguintes liñas ó ficheiro `.ssh/config`:

```
Host zeus
    HostName zeus.upf.edu
    User ***

Host shiva
    HostName shiva.prib.upf.edu
    User ***
    ProxyJump zeus  # Omit this line if you can ssh to shiva
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


Agora, `ssh shiva` equivale a 
```
ssh user@zeus.upf.edu
ssh user@shiva.prib.upf.edu

## ou
ssh -J user@zeus.upf.edu user@shiva.prib.upf.edu
```

<details>
  <summary>Exemplo de .ssh/config</summary>
  
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
  
</details>

## No *HPC*
Agora, conéctate ó *HPC* no que queiras instalar Jupyter. Podes empregar estas instrucións no nodo de acceso, mais é recomendable que o fagas nun nodo de computación

0. Debes estar no HPC:
```
ssh shiva
# Podes iniciar unha sesión interactiva nun nodo de computación con:
srun --pty --mpi=none bash
```

1. Clona ou descarga este repositorio no teu cartafol de usuario.
```
cd ~

git clone https://github.com/EvolutionaryGenomics-GRIB/jupyter
```
2. Executa o script `init.sh`.
```
bash ~/jupyter/init.sh
```
Tamén podes facelo nun nodo de computación (se non estás nun xa) con
```
sbatch ~/jupyter/init.sh  # Agarda a que remate
```
3. Actualiza a entorna para dispór das novas comandas.
```
source ~/.bashrc
```

# Uso

## No *HPC*
1. Inicia o servidor dende o *HPC*. **Non o fagas dende un nodo de computación**:
```
jupy_start
```
Se queres configurar o traballo de slurm no que se executa o servidor de Jupyter, sempre podes iniciar o servidor manualmente e introducindo a configuración que queiras con:
```
sbatch ~/jupyter/init.sh
```
2. Cando o traballo estea en execución, obtén o comando ssh do JupyterLab con
```
jupy_ssh
```
Copia o comando e execútao na computadora local

3. Obtén a dirección do servidor con:
```
jupy_url
```
Por defecto, esta sempre é `http://localhost:15497`, pero se tes problemas con este porto, revisa os *outputs* de calquera sesión do servidor en `~/jupyter/*.out`.

## Na computadora local
1. Executa o comando amosado por `jupy_ssh`.  
Se este comando che dá erro, é probable que teñas algunha sesión anterior de ssh empregando este porto. Podes comprobalo con axuda de `htop`, localizando (`F4`) o proceso de `ssh` e matándoo (`k`).
2. Abre no navegador á dirección de `jupy_url`


# Acceso con identidade (recomendado)
Con este paso poderás acceder ó *HPC* sen contrasinais, empregando un ficheiro de identificación. 

Se ainda non tes un ficheiro de identidade, podes crealo con:
```
ssh-keygen
```

Unha vez creado, podes enviar esta identidade ó teu usuario no *HPC* para que recoñeza a túa computadora local empregando este ficheiro automáticamente.  
Queremos facer isto tanto no *HPC* coma no servidor intermedio (se temos que pasar por un). É dicir, querémolo facer en `shiva` e en `zeus`. Isto faise co comando:
```
ssh-copy-id -i ~/.ssh/id_rsa.pub user@zeus
ssh-copy-id -i ~/.ssh/id_rsa.pub user@shiva
```
**Cambia `user` polo teu nome de usuario.**  
Por outra parte, se o teu ficheiro de identidade non está na ruta por defecto `~/.ssh/id_rsa.pub`, pon `ssh-copy-id -i` na consola e preme `TAB`. Debería autocompletarse coa ruta correcta.

Proba a conectarte sen contrasinal con:
```
ssh shiva
```


# Funcionamento
O *script* `init.sh` emprega o Python dispoñible no sistema para crear unha entorna virtual mediante `venv` na que instalar JupyterLab. Este *script* ten que ser executado nun nodo de computación ou, asumindo que comparten o sistema de ficheiros, no nodo de acceso do *cluster* ou *HPC* no que traballas.  

O *script* comproba se algunha entorna de `conda` ou de `venv` están activadas previamente e desactívaas se fose o caso. Tamén comproba que haxa Python dispoñible e, de non o haber, intenta cargalo con `module load Python`. A ruta da entorna que crea é `~/jupyter/venv`, sendo `~` o directorio do teu usuario.     
  
Tras a instalación, terás unha serie de comandos dispoñibles para controlares o Jupyter:
- `jupy_start`: envía á cúa de SLURM o script `lab.sh` que pon en marcha un servidor de JupyterLab.
- `jupy_ssh`: amósache o comando de `ssh` para conectar unha computadora remota ó servidor iniciado.
- `jupy_url`: amósache a direción url na que se executa o servidor de Jupyter.

O comando que facilita `jupy_ssh` **non é para executar nos nodos do *HPC*,** ten que ser executado na computadora remota que queres conectar.

Os *outputs* do servidor son redireccionados (con `sbacth --output --error`) a un *log* individual no cartafol `~/jupyter`. Isto permite que se poidan executar servidores de JupyterLab en paralelo como traballos distintos sen se interrupiren uns a outros.  
<details>
    <summary>Nota sobre porto local e múltiples servidores</summary>
        Por defecto, o porto local é `15497`. Se queres executar varias sesións na mesm computadora local, precisarás empregar cadanseu porto. Para máis axuda e obter un comando de ssh cun porto novo, revisa os outputs de calquera sesión do servidor en `~/jupyter/*.out`.
</details>


# To do list:
- [ ] Crear kernels por defecto `biobox`
- [ ] Actualizar README:
  - [ ] Facer multilingua
- [X] Pór instrucións sobre `ssh .config`
- [ ] Pór instrucións sobre `kernels`
- [ ] Modificables:
  - [ ] nome e ruta da entorna creada
  - [ ] desactivación de entornas 
  - [ ] creación de alias
  - [ ] porto local
  - [ ] porto remoto
