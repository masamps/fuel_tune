# AGENTS.md

Este arquivo orienta agentes e colaboradores que fizerem mudanças no projeto Fuel Tune.

## Missão do Produto
Fuel Tune é um app Flutter mobile, offline e sem login, focado em:
- calcular mistura de combustível
- mostrar quanto abastecer de etanol e gasolina
- salvar abastecimentos localmente
- acompanhar consumo e gasto com baixo atrito

O app deve ser:
- simples
- rápido
- confiável
- elegante
- fácil de manter

## Fonte Permanente de Referência
Antes de propor ou implementar mudanças, use também:
- [FUEL_TUNE_PRODUCT_GUIDELINES.md](/Users/matheussampaio/Documents/Pessoal/Projetos/fuelTune/fuel_tune/FUEL_TUNE_PRODUCT_GUIDELINES.md)

Se houver dúvida de direção, seguir o documento acima e preservar o foco no core do app.

## Regras Não Negociáveis
Nunca adicionar sem necessidade explícita:
- login
- backend
- sync em nuvem
- recursos sociais
- gamificação
- gráficos avançados
- múltiplos veículos
- features que desviem do valor central de mistura e abastecimento

Sempre priorizar:
- clareza
- baixo atrito
- linguagem simples
- uso offline
- refatoração incremental
- UX fluida

## Fluxo Principal Esperado
O app deve abrir em `Mistura`.

A navegação principal deve permanecer:
- `Mistura`
- `Consumo`
- `Histórico`
- `Configurações`

Evitar nomes vagos ou em inglês desnecessário como:
- `Save`

## Diretrizes de UX
Preferir textos como:
- `Mistura desejada`
- `Quanto você vai abastecer?`
- `Preço do etanol`
- `Preço da gasolina`
- `Resultado`

Evitar:
- linguagem excessivamente técnica
- rótulos ambíguos
- telas longas sem necessidade
- excesso de elementos visuais chamativos

O resultado da mistura deve ser:
- rápido de entender
- visualmente destacado
- legível em tema claro e escuro

O histórico deve:
- mostrar data
- mostrar números formatados
- ordenar do mais recente para o mais antigo
- destacar consumo e dados principais

## Diretrizes Visuais
Preservar a base visual atual:
- limpa
- refinada
- com sensação premium
- inspirada em apps com acabamento mais contido

Evitar:
- redesign completo sem necessidade
- Material exagerado
- excesso de bordas pesadas
- uso excessivo de cores saturadas

Tema claro e escuro devem:
- manter consistência
- ter bom contraste
- evitar preto puro agressivo quando prejudicar acabamento

## Diretrizes Técnicas
Preferir:
- separar UI e regra de negócio quando fizer sentido
- centralizar regras de mistura
- reutilizar parsing e formatação
- manter persistência local simples
- reduzir acoplamento

Evitar:
- reescrever o app inteiro
- criar arquitetura complexa sem ganho real
- abstrações prematuras

## Estrutura Atual Importante
Ao alterar o app, respeitar estes pontos de centralização:

- Misturas:
  [lib/models/fuel_blend.dart](/Users/matheussampaio/Documents/Pessoal/Projetos/fuelTune/fuel_tune/lib/models/fuel_blend.dart)

- Cálculo de mistura:
  [lib/services/calculo_combustivel.dart](/Users/matheussampaio/Documents/Pessoal/Projetos/fuelTune/fuel_tune/lib/services/calculo_combustivel.dart)

- Parsing e formatação numérica pt-BR:
  [lib/utils/number_utils.dart](/Users/matheussampaio/Documents/Pessoal/Projetos/fuelTune/fuel_tune/lib/utils/number_utils.dart)

- Persistência local de abastecimentos:
  [lib/repositories/fuel_record_repository.dart](/Users/matheussampaio/Documents/Pessoal/Projetos/fuelTune/fuel_tune/lib/repositories/fuel_record_repository.dart)

- Persistência de tema:
  [lib/repositories/local_preferences_repository.dart](/Users/matheussampaio/Documents/Pessoal/Projetos/fuelTune/fuel_tune/lib/repositories/local_preferences_repository.dart)

- Tema:
  [lib/theme/app_theme.dart](/Users/matheussampaio/Documents/Pessoal/Projetos/fuelTune/fuel_tune/lib/theme/app_theme.dart)
  [lib/theme/theme_controller.dart](/Users/matheussampaio/Documents/Pessoal/Projetos/fuelTune/fuel_tune/lib/theme/theme_controller.dart)

- Navegação principal:
  [lib/screens/home.dart](/Users/matheussampaio/Documents/Pessoal/Projetos/fuelTune/fuel_tune/lib/screens/home.dart)

## Misturas
O app deve suportar:
- E50
- E75
- E85
- E100
- mistura personalizada

A mistura personalizada deve:
- aceitar percentual de etanol entre 0 e 100
- validar entrada
- funcionar no cálculo por litros e por valor

Não espalhar regra de percentual por vários widgets.

## Entrada Numérica
Todo input numérico deve aceitar:
- vírgula
- ponto

Usar utilitário central para parsing e formatação.
Não duplicar lógica de `double.tryParse` em telas.

## Persistência
Manter tudo local.

Se for preciso evoluir armazenamento:
- preferir repositório local simples
- evitar backend
- evitar sync

## Prioridades
### P0
- abrir em Mistura
- renomear abas corretamente
- manter mistura personalizada
- manter E50
- garantir parsing pt-BR
- manter tema persistido

### P1
- melhorar continuamente a tela principal de mistura
- reduzir passos do cálculo
- melhorar histórico
- polir microcopy

### P2
- refatorar trechos acoplados
- remover código morto
- melhorar testes
- polir publicação

## Checklist Antes de Encerrar Mudanças
- o fluxo principal continua abrindo em `Mistura`
- a navegação continua coerente com o produto
- inputs numéricos aceitam pt-BR
- histórico continua funcional e ordenado
- tema claro/escuro permanece consistente
- nenhuma feature fora do escopo foi introduzida
- `flutter analyze` passa
- `flutter test` passa

## Como Decidir
Quando houver dúvida, escolher a opção que:
1. reduz atrito
2. deixa o app mais claro
3. aumenta a confiança
4. mantém o visual elegante
5. preserva simplicidade e foco
