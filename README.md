# Promalaria Shiny Server

Esse repositório contém os Apps Shiny sendo utilizados pelo projeto promalaria.

Essa é uma aplicação que se utiliza de ShinyApps, escritos em R, rodando dentro de um container docker. No ambiente de produção, a aplicação fica por trás de um proxy Apache2 rodando em um servidor Ubuntu Server 20.04. 

## Dependências do projeto

- Webserver (Apache2 ou Nginx);
- Docker
- docker-compose

É possível realizar o deployment com outras ferramentas da mesma categoria, mas seria necessário adaptar o processo para tais ferramentas. Essa documentação não ira cobrir esse caso de uso.

## Estrutura do repositório

O repositório está estruturado da seguinte forma:

- Pasta `.github/`: Contém arquivos de configuração específicos do Github, como a definição das pipelines utilizadas pelo projeto
- Pasta `conf`: Contém arquivos de configuração utilizados no servidor. Utilizamos a versão do Apache, porém está disponível uma versão para o `nginx`.
- Pasta `src`: Contém os ShinyApps, qualquer applicação que queria que esteja disponível para o usuário precisa estar contida dentro dessa pasta, inicialmente populada com apps exemplo do projeto Shiny.
- Arquivo `docker-compose.local.yml`: Arquivo docker-compose para deploy e execução local da aplicação
- Arquivo `docker-compose.yml`: Arquivo docker-compose utilizado no servidor para deploy.

## Execução local

> Importante! Para execução local do projeto como um todo assumimos que você possua o docker e docker-compose configurados na sua máquina. Instruções sobre esse processo podem ser encontradas no [site oficial](https://docs.docker.com/engine/install/) 

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


### Deployment Secrets

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

#### Aplicação está offline?

Acesse o servidor e verifique se alguém erro aconteceu com o serviço utilizando o comando `docker-compose logs`.

Se nada parece anormal, entre em contato com a administração do projeto se não houve algum bloqueio no firewall ou algum tipo de falha de roteamento ao servidor.

#### Desejo gerar uma nova chave SSH apra deploy da aplicação, como faço?

O seguinte comando pode ser usado para gerar uma nova chave para o deploy.

```bash
ssh-keygen -t ed25519 -f <caminho_para_salvar_a_chave> -C "<email_relacionado_a_chave>"
```

Isso irá geram um novo par de chaves pública (extensão `.pub`) e privada.

Uma vez realizado, atualize o secret `SSH_DEPLOY_KEY` com o novo valor (obtido com o comando `cat <chave_nova>`).

#### A aplicação não refletiu as últimas mudanças que foram feitas na `master`

Verifique se a última execução da pipeline foi bem sucedida, se foi, verifique se o seu navegador está realizando o cache dos dados da aplicação, se possível remova. Se nenhuma das auternativas anterior funcionar, realize ou solicite a conexão ssh com o servidor, navegue ao diretório da aplicação e realize um restart nos serviço docker com `docker-compose up -d`

#### Desejo fazer o deploy em um novo servidor, como fazer?

Primeiramente é necessário que um webserver (Apache2 ou Nginx por exemplo) esteja propriamente configurado com um dos arquivos de configuração providos na pasta `conf`.

Certifique-se que a configuração do repositório com os secrets mencionados na sessão [**Deployment Secrets**](#deployment-secrets) foi realizada. Se novas chaves de acesso foram geradas, tenha certeza que o repositório teve esse valor atualizado.

#### É possível fazer deploy de outras branches além da `master`?

No momento não, porém utilizando hosts virtuais similares aos que são utilizados hoje essa capacidade pode ser adquirida.

## Authors

- [@deadpyxel](https://www.github.com/deadpyxel) - Robson Cruz

