# Promalaria Shiny Server

Esse repositório contém os Apps Shiny sendo utilizados pelo projeto promalaria.

Essa é uma aplicação que se utiliza de ShinyApps, escritos em R, rodando dentro de um container docker. No ambiente de produção, a aplicação fica por trás de um proxy Apache2 rodando em um servidor Ubuntu Server 20.04. 

## Estrutura do repositório

O repositório está estruturado da seguinte forma:

- Pasta `.github/`:
- Pasta `conf`
- Pasta `src`
- Arquivo `docker-compose.local.yml`
- Arquivo `docker-compose.yml`

## Execução local

> Importante! PAra execução local do projeto como um todo assumimos que você possua o docker e docker-compose configurados na sua máquina. Instruções sobre esse processo podem ser encontradas no [site oficial](https://docs.docker.com/engine/install/) 

1. Clone o projeto

```bash
  git clone https://github.com/pvd-malaria/shiny-server.git 
  # ou git clone git@github.com:pvd-malaria/shiny-server.git se estiver usando SSH
```

1. Navegue até o diretório do projeto

```bash
  cd shiny-server
```

1. Inicialize o server

```bash
  docker-compose -f docker-compose.local.yml up -d
```

## Deployment

Todo o processo de deployment da aplicação está automatizado utilizando Github Actions, cuja pipeline é definida em `.github/workflows/deploy-r-apps.yml`.

> WIP


## Deployment Secrets

Para o deploy ter sucesso são necessários que dois SECRETS tenha sido definidos para o repositório:

`SSH_HOST`, o endereço do servidor aonde desejeamos fazer esse deploy utilizando rsync

`SSH_DEPLOY_KEY`, é uma chave privada SSH ED25519 utilizada apenas para deploy no servidor. Caso essa chave mude será necessário atualizar esse secret utilizando o painel de configurações do repositório.

## FAQ

Problemas comuns e possíveis soluções

#### Como acessar o servidor?

Para acessar o servidor é necessário que seja utilizada a chave de acesso SSH remota (a mesma possui uma senha associada). É necessário solicitar tais credenciais para os administradores do projeto. Uma vez que isso tenha sido feito, é possível realizar o login com o comando:

```bash
ssh dev@promalaria.nepo.unicamp.br -i <caminho_da_chave_ssh>
```

E digitar a senha associada a chave.

#### A aplicação não refletiu as últimas mudanças que foram feitas na `master`

Verifique se a última execução da pipeline foi bem sucedida, se foi, verifique se o seu navegador está realizando o cache dos dados da aplicação, se possível remova. Se nenhuma das auternativas anterior funcionar, realize ou solicite a conexão ssh com o servidor, navegue ao diretório da aplicação e realize um restart nos serviço docker com `docker-compose up -d`

#### É possível fazer deploy de outras branches além da `master`?

No momento não, porém utilizando hosts virtuais similares aos que são utilizados hoje essa capacidade pode ser adquirida.

## Authors

- [@deadpyxel](https://www.github.com/deadpyxel) - Robson Cruz

