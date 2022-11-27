# Guia de contribuíção (Desenvolvimento)

O desenvolvimento deste projeto segue algumas regras e convenções
básicas. Como 'estilo de formatação de código',

## Código de conduta ##
Detalhes em [docs/code_of_conduct.md](extra/code_of_conduct.md).

## Padrões aplicados ##
Este projeto segue as recomendações:
- [Python - A Linguagem de programação do projeto](http://www.python.org/doc)
- [Zen do Python - PEP20](extra/zenpy.md)
- [Estilo de codificação Python - PEP8](https://pep8.org/)
- [RST - Restructuredtext](https://docutils.sourceforge.io/docs/ref/rst/restructuredtext.html)
- [MD - Markedown](https://www.markdownguide.org/basic-syntax/)
- [Versionamento Semântico (SemVer)](https://semver.org/lang/pt-BR/)
- [GIT Conventional Commits](https://www.conventionalcommits.org/pt-br/v1.0.0/)
- [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## Prerequisitos ##
- Sistema Operacional (Linux preferencialmente)
- git client
- python 3.8+
- pyenv
- pip or poetry (preferencialmente)

## Qualidade de Código ##
É utilizado de ferramentas validadoras de qualidade de código estático,
também denominadas linters.
Há uso das seguintes:
- black
- isort
- mypy
- pydocstyle
- pylame
- pylint

## Segurança ##
Também há preocupação com a segurança do código implementado, o pacote
`safety` é utilizado para o monitoramento de pacotes.

### black ###
O `black` é classificado como Autoformator, são programas que
refatoram seu código para se adequar ao PEP 8 automaticamente.
```shell
black --check incolumepy tests
```
### pylama ###
O `pylama` é um envolucro que contém: PyFlakes, pycodestyle, McCabe.
```shell
pylama incolumepy tests
```
### isort ###
O `isort` é um utilitário para classificar as importações
em ordem alfabética e separadas automaticamente em seções e por tipo.
```shell
isort incolumepy tests
```
### mypy ###
O `Mypy` é essencialmente um analizador de código estático melhorado e com
verificador de tipos, que pode detectar muitos erros de programação
analisando o código, sem precisar executá-lo.
Ele possui um poderoso sistema de tipos com recursos como
inferência de tipos, digitação gradual, genéricos e tipos de união.
```shell
mypy incolumepy
```
### pydocstyle ###
O `pydocstyle` é uma ferramenta de análise estática para verificar a
conformidade com as convenções docstring do Python. Ele suporta a maior
parte do PEP 257, entretanto não deve ser considerado uma
implementação de referência.
```shell
pydocstyle incolumepy tests
```
### pylint ###
O `Pylint` é uma ferramenta de análise de código estático do Python
que procura erros de programação, ajuda a impor um padrão de codificação,
detecta cheiros de código e oferece sugestões simples de refatoração.
É altamente configurável, possuindo pragmas especiais para controlar
seus erros e avisos de dentro do seu código, bem como de um extenso
arquivo de configuração. Também é possível escrever seus próprios plugins
para adicionar suas próprias verificações ou para estender o `pylint`
de uma forma ou de outra.
```shell
pylint incolumepy tests
```
### safety ###
O `safety` verifica as dependências instaladas quanto a vulnerabilidades
de segurança conhecidas.
Por padrão, ele usa o banco de dados de vulnerabilidades Python aberto
[Safety DB](https://github.com/pyupio/safety-db).
```shell
safety check
```

## Ferramentas de Automação ##
Para facilitar o trabalho, várias das tarefas estão automatizadas pelo
githooks, e/ou Makefile, e/ou tox.

### Tox ###

#### Verificação básica ####

Na Verificação básica engloba:
- black
- isort
- pydocstyle
- pylama
- mypy
- pylint
- py36
- py37
- py38
- py39
- py310
- py311

```shell
tox
```
#### Verificação dos testes com as versões python disponíveis ####
```shell
tox -e py36,py37,py38,py39,py310,py311
```
#### Verificação de três linters apenas no em um módulo ####
```shell
tox -e pydocstyle,black,isort -- -k incolume/py/pack/module.py
```

#### Verificação de todos os linters configurados ####
```shell
tox -e linters
```

#### Verificação e relatório de cobertura ####
```shell
tox -e stats
```

#### Verificação resumida de segurança ####
```shell
tox -e safety
```

#### Execução completa ####
Executa todas as verificações diponíveis contidas no `tox`.
```shell
tox -e ALL
```

### Makefile ###
O `Makefile` foi personalizado para rodar com as opções necessárias.
Com o help você verá todas as opções.
```shell
make help
```
#### Iniciar ambiente dev ####
Através do `Makefile`, pode-se criar um ambiente virtual para o projeto,
conforme a versão python predefinida, instalando todas as dependências
necessárias, além de ativar as configurações em passos simples.

```shell
make setup
```

#### Limpeza básica do ambiente
Limpeza de arquivos temporários, logs, compilados e afins.
```shell
make clean
```

#### Limpeza profunda do ambiente
Além da limpeza básica, são removidos dist, build, htmlcov, .tox, *_cache,
e outros conteúdos gerados pelas ferramentas de desenvolvimento.
```shell
make clean-all
```

#### Gerar a documentação atualizada
```shell
make docsgen
```

#### Verificação de segurança e exposição de motivos
```shell
make safety
```
