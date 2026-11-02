# Sistema Genesis

Sistema pessoal para organizar projetos, clientes, agenda e fluxo financeiro da empresa.

## Direção técnica (padrão Cormex)

- Flutter Web com experiência PWA para instalar no notebook.
- `get_it` para dependências, `go_router` para navegação e `signals` para estado reativo.
- Dio para chamadas HTTP e integração com Back4App/Parse.
- Arquitetura offline-first: persistir primeiro no armazenamento local do navegador; sincronizar com Back4App quando houver conexão.
- Fila de sincronização idempotente, com identificador único por registro e tratamento explícito de conflitos.
- A Master Key e a REST API Key do Parse nunca devem ser incluídas no cliente.

## Módulos previstos

1. Painel: projetos ativos, atrasos, vencimentos de domínio e valores a receber.
2. Clientes: contatos e informações vinculadas aos projetos.
3. Projetos: negociação, planejado, em andamento, atrasado e concluído; valor, escopo, datas e links.
4. Ativos digitais: domínios, hospedagem e serviços associados, com datas e custos recorrentes.
5. Agenda: apresentações, reuniões e tarefas com data e horário.
6. Financeiro: receitas, despesas, categorias, vencimentos e situação de pagamento.
7. Sincronização: estado da conexão, itens pendentes, último envio e conflitos para revisão.

## Plano de implementação

- [x] Registrar o escopo e a arquitetura inicial.
- [ ] Criar a base Flutter Web/PWA seguindo a organização do Cormex.
- [ ] Implementar armazenamento local persistente e migrações.
- [ ] Implementar clientes, projetos, agenda e financeiro.
- [ ] Conectar ao Back4App com autenticação e permissões restritas.
- [ ] Implementar sincronização e recuperação de conflitos.
- [ ] Validar o ciclo: cadastrar offline, reabrir o app, reconectar e confirmar sincronização.

## Segurança

O App ID e a Client Key do Parse são identificadores do cliente, não controles de acesso. Configurar CLPs/ACLs para permitir acesso apenas à conta autenticada e validar operações sensíveis no Cloud Code. Nunca distribuir a Master Key ou a REST API Key no aplicativo.

## Observação sobre uso offline

O PWA pode trabalhar sem conexão depois que seus arquivos forem armazenados no navegador. Os dados de negócio precisam de armazenamento local persistente e sincronização própria. Como os dados offline ficam no dispositivo, o sistema também precisa orientar o usuário a sincronizar e manter cópia central no Back4App.

## Estado

Repositório iniciado do zero. A próxima entrega é a base de navegação e layout; em seguida implementamos o armazenamento local e o primeiro ciclo de sincronização.
