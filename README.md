# Sistema Genesis

Sistema pessoal para organizar projetos, clientes, agenda e fluxo financeiro da empresa.

## Direção técnica

- Aplicativo Flutter para uso no notebook.
- Arquitetura offline-first: os dados são gravados localmente antes de qualquer tentativa de rede.
- Back4App/Parse como cópia central para sincronização e recuperação dos dados.
- Fila de sincronização idempotente, com identificação única por registro e tratamento explícito de conflitos.
- A Master Key do Parse nunca deve ser incluída no aplicativo.

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
- [ ] Criar a base Flutter para desktop e validar a plataforma alvo.
- [ ] Implementar armazenamento local e migrações.
- [ ] Implementar clientes, projetos, agenda e financeiro.
- [ ] Conectar ao Back4App com autenticação e permissões restritas.
- [ ] Implementar sincronização e recuperação de conflitos.
- [ ] Validar o ciclo: cadastrar offline, fechar e reabrir, reconectar e confirmar sincronização.

## Segurança

O App ID e a Client Key do Parse podem estar no cliente, mas não substituem as permissões do servidor. Configurar CLPs/ACLs para permitir acesso apenas à conta autenticada e validar operações sensíveis no Cloud Code. Nunca distribuir a Master Key ou a REST API Key no executável.

## Estado

Repositório iniciado. O primeiro marco é validar a base Flutter desktop e o armazenamento local antes de depender de sincronização com a nuvem.
