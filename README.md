# Genesis Business OS

Sistema privado e offline-first para administrar projetos, clientes, agenda,
domínios e fluxo financeiro. Construído em Flutter Web/PWA e preparado para
sincronização com Back4App.

## O que já funciona

- Login exclusivo, sem cadastro público.
- Sessão persistente e proteção de rotas.
- Dashboard com indicadores calculados a partir dos dados reais.
- Pipeline Kanban com seis etapas e movimentação por arrastar e soltar.
- CRUD completo de clientes, projetos, agenda e financeiro.
- Controle de domínio, vencimento, endereço publicado e repositório por projeto.
- Persistência local no navegador para continuar trabalhando sem conexão.
- Interface responsiva para desktop e celular.
- Manifesto PWA, ícones `any` e `maskable` e instalação na tela inicial.
- Cliente REST do Parse, fila de alterações, exclusões pendentes e sincronização
  manual com o Back4App.

## Acesso local temporário

Enquanto as chaves do Back4App não estiverem configuradas, o build publicado
entra em modo local:

- E-mail: `admin@genesis.local`
- Senha: `Genesis@2026`

Esse acesso serve apenas para validar e usar os dados no próprio dispositivo.
Quando `PARSE_APPLICATION_ID` e `PARSE_JAVASCRIPT_KEY` forem fornecidos, o modo
local é desativado e o login passa a usar a classe `_User` do Parse.

## Conectar ao Back4App

1. Crie um app no Back4App.
2. Crie somente um usuário em **Database > `_User`**, usando o e-mail como
   `username`. Não habilite cadastro público.
3. Adicione os secrets abaixo no repositório GitHub:
   - `PARSE_APPLICATION_ID`
   - `PARSE_JAVASCRIPT_KEY`
4. Execute novamente o workflow **Publicar Genesis no GitHub Pages**.

O aplicativo utiliza estas classes:

| Classe | Conteúdo |
| --- | --- |
| `GenesisClient` | Clientes |
| `GenesisProject` | Projetos e ativos digitais |
| `GenesisAgenda` | Compromissos e tarefas |
| `GenesisFinance` | Receitas e despesas |

Na primeira sincronização, o Parse pode criar as classes se a criação via
cliente estiver permitida. Em produção, prefira criar as quatro classes no
painel e configurar as CLPs para exigir usuário autenticado. Cada registro novo
recebe ACL exclusiva do usuário logado.

> Nunca coloque a Master Key ou a REST API Key no Flutter, no GitHub Pages ou
> em `--dart-define`. Elas devem existir apenas em Cloud Code/ambiente servidor.

## Estrutura

```text
lib/Src/
├── Config/       tema, identidade e variáveis de ambiente
├── Connection/   cliente HTTP e Parse REST
├── Dependencies/ injeção com get_it
├── Models/       modelos e serialização local/remota
├── Pages/        login, shell, dashboard e módulos de negócio
├── Routes/       go_router e proteção de sessão
└── Services/     autenticação, persistência e sincronização
```

## Desenvolvimento

```bash
flutter pub get
flutter run -d chrome
```

Build conectado ao Back4App:

```bash
flutter build web --release \
  --dart-define=PARSE_APPLICATION_ID=SEU_APP_ID \
  --dart-define=PARSE_JAVASCRIPT_KEY=SUA_JAVASCRIPT_KEY
```

## Segurança antes de dados reais

- Restrinja `Find`, `Get`, `Create`, `Update` e `Delete` das classes a usuários
  autenticados.
- Mantenha o cadastro público desativado e crie apenas a conta administrativa.
- Use ACL por registro, já enviada pelo app nas criações.
- Ative autenticação multifator no GitHub e no Back4App.
- Troque a senha temporária ao conectar o banco.
- Não trate o PWA instalado como barreira de segurança: a proteção real é feita
  pela autenticação, CLPs, ACLs e validação no servidor.
