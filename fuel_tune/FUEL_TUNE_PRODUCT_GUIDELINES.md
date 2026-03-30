# Fuel Tune - Diretrizes Permanentes de Produto, UX e Implementação

## Visão do Produto
Fuel Tune é um app mobile Flutter, offline, sem login, voltado para usuários que desejam calcular mistura de combustível e registrar abastecimentos de forma simples, rápida e confiável.

O app deve ajudar o usuário a:
- calcular misturas como E50, E75, E85, E100 e personalizadas
- entender quanto abastecer de etanol e gasolina
- salvar abastecimentos localmente
- acompanhar gastos e consumo com praticidade

## Objetivo do Produto
O objetivo do Fuel Tune é:
- resolver um problema real
- ser útil no dia a dia
- ser recomendado pela comunidade
- transmitir confiança e acabamento
- futuramente poder gerar renda extra sem sacrificar a experiência

## Princípios do App
Sempre priorizar:
- simplicidade
- clareza
- rapidez
- confiabilidade
- experiência fluida
- baixo atrito
- funcionamento offline
- manutenção fácil

Evitar:
- complexidade desnecessária
- excesso de funcionalidades
- telas poluídas
- linguagem técnica demais
- fluxos longos
- fricção desnecessária

## Fluxo Principal
O principal valor do app é a mistura de combustível.

Por isso:
- o app deve abrir na área de Mistura
- a proposta principal deve ficar clara logo no primeiro contato
- o fluxo deve exigir o menor número possível de passos
- o resultado deve ser fácil de ler

## Linguagem
Usar linguagem simples, clara e humana.

Preferir:
- "Mistura desejada"
- "Quanto você vai abastecer?"
- "Preço do etanol"
- "Preço da gasolina"
- "Resultado"

Evitar:
- textos excessivamente técnicos
- nomes genéricos ou em inglês sem necessidade
- labels ambíguas

## Navegação
A navegação deve ser clara, curta e coerente com o produto.

Estrutura preferida:
- Mistura
- Consumo
- Histórico
- Configurações

Evitar:
- "Save"
- termos vagos
- nomenclaturas que não expliquem a função da aba

## Histórico
O histórico deve ser útil, não só armazenado.

Prioridades:
- mostrar data
- ordenar do mais recente para o mais antigo
- destacar a informação mais importante
- exibir números formatados
- usar textos claros para estado vazio

## Diretrizes Visuais
### Base Visual
Manter o design atual como base.

O visual do Fuel Tune deve continuar:
- limpo
- elegante
- refinado
- com sensação premium
- inspirado em layouts da Apple

### Estilo
Preservar:
- boa hierarquia visual
- espaçamento respirado
- componentes discretos
- interface limpa
- sensação de app moderno e bem acabado

Evitar:
- redesign completo
- visual carregado
- Material Design exagerado
- excesso de cores fortes
- excesso de bordas pesadas
- elementos chamativos sem necessidade

### Tema Claro e Escuro
O app deve suportar tema claro e escuro.

Diretrizes:
- manter consistência entre os dois temas
- preservar elegância visual
- garantir legibilidade
- usar contraste adequado
- evitar preto puro agressivo se prejudicar o acabamento
- evitar cores saturadas em excesso

A escolha de tema deve ser persistida localmente.

## Diretrizes Técnicas
### Arquitetura
Priorizar refatorações seguras e incrementais.

Preferir:
- separar lógica de UI quando fizer sentido
- criar utilitários reutilizáveis
- centralizar regras de mistura
- manter código legível
- reduzir acoplamento excessivo

Evitar:
- reescrever o app inteiro
- criar arquitetura complexa sem necessidade
- abstrações prematuras
- mudanças de stack

### Misturas
As misturas devem ser definidas de forma centralizada.

O app deve suportar:
- opções fixas relevantes
- E50
- E75
- E85
- E100
- mistura personalizada

A mistura personalizada deve:
- aceitar percentual de etanol entre 0 e 100
- validar entrada
- funcionar no cálculo por litros e por valor

### Entrada Numérica
O app deve lidar corretamente com números no padrão brasileiro.

Requisitos:
- aceitar vírgula e ponto
- funcionar bem para preço, litros, quilômetros e percentuais
- usar parsing consistente em todo o app
- formatar números para exibição de forma amigável

### Persistência
Manter persistência local.

Não adicionar:
- login
- backend
- nuvem

Se necessário, organizar persistência com um repositório local simples.

## Prioridades de Implementação
### P0
- abrir app em Mistura
- renomear abas
- implementar mistura personalizada
- adicionar E50
- corrigir parsing numérico pt-BR
- adicionar tema claro/escuro com persistência

### P1
- melhorar tela principal de mistura
- padronizar fluxo de cálculo
- melhorar histórico com data, formatação e ordenação
- melhorar textos e microcopy

### P2
- refatorar trechos acoplados
- limpar código morto
- melhorar testes básicos
- polimento de publicação

## Restrições Permanentes
Nunca fazer sem necessidade explícita:
- login
- backend
- sync em nuvem
- comunidade/social
- gamificação
- gráficos avançados
- múltiplos veículos
- recursos que desviem do core do app

## Como Decidir
Sempre que houver dúvida, priorizar a opção que:
1. reduz atrito
2. deixa o app mais claro
3. melhora a confiança
4. mantém o visual elegante
5. preserva simplicidade e foco

## Estado Atual Esperado do Projeto
No estado ideal atual do app:
- a home abre em Mistura
- a navegação principal usa Mistura, Consumo, Histórico e Configurações
- a tela de mistura oferece cálculo por litros e por valor
- as misturas são centralizadas em uma única fonte
- o app aceita entrada numérica em pt-BR
- o histórico mostra data, consumo, litros e valor quando disponível
- o tema escolhido fica salvo localmente

## Observação de Escopo
Estas diretrizes devem servir como referência permanente para evolução do produto e para futuras alterações no código.

Ao implementar novas mudanças:
- preservar o foco no core do app
- priorizar ajustes incrementais
- evitar desviar para recursos que aumentem complexidade sem melhorar a utilidade principal
