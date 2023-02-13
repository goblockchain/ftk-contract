# COPF
## _Dados Armazenados no Contrato_
Váriaveis Globais do Smart Contract 
| Nível | Variável | Type | Done |
| ------ | ------ | ------ | ------ | 
| Smart Contract | localizações dos talhões | Array | ☑ |
| Smart Contract | Imagens | Array | ☑ |
| Smart Contract |Potencial total de m³ de madeira| Number | ☑ |
| Smart Contract | Tipo de madeira| Enum | ☑ |
| Smart Contract | Idade do talhão| Dates | ☑ |
| Smart Contract | Ano de Plantio | Dates | ☑ |
| Smart Contract | Ano de Corte| Dates | ☑ |
| Smart Contract | % Máxima de Tokenização Universal | Number = 80% | ☑ |
| Smart Contract | Nome da Floresta | Texto | ☑ |
| Smart Contract | Matrícula do Imóvel | Número | ☑ |
| Smart Contract | Quantidade de talhões na floresta | Number | ☑ |
| Smart Contract | % máxima de tokenização liberada p/ a floresta | Number | ☑ |
| Smart Contract | link do data room | Texto | ☑ |
| Smart Contract | link do contrato de compra e venda | Texto | ☑ |
| Smart Contract | link do contrato de tokenização | Texto | ☑ |
| Smart Contract |  | Bijeção | ☑ |

## Funções do Smart Contract:
O smart contract representa a floresta e as estruturas de Lote e Talhão ficam dentro da floresta:

Aqui segue a descrição técnica do que algumas funçoes do smart contract farão:

| Nome da Função | Descrição | Visibilidade | Done |
| ------ | ------ | ------ | ------ |
| setGlobalInfoAboutCurrentFlorest | Define propriedades da floresta | onlyOwner |  |
| setAssetAvailabilityForTransfer | Torna o ativo disponível para transfer | onlyOwner | |
| mint | Cria um lote = NFT | onlyOwner | |


## Regras de Tokenização:
* _(1)_ Quantidade potencial de m³ de madeira (Decidido pela FTK). 
* _(2)_ Quantidade liberada pela FTK para ser tokenizada. (Decidido pela FTK).
* _(3)_ A quantidade liberada (pela FTK) e tokenizada (pelo proprietário) não pode passar dos 80% do tamanho da área com potencial de tokenização _(1)_.

## Definições
* **_Data Room_**: Link que contém informações sobre a floresta como, por exemplo, documentação do due diligence, matrícula, documentação do proprietário. O data room é usado pela FTK e comprador para acompanhar se a floresta está crescendo.
* **_Talhão_**: Área com potencial de ser tokenizada dentro de uma floresta e é sempre homogênea em relação à sua idade e em relação à espécie contida nela.
* **_Lote_**: Porcentagem do volume decidido pelo usuário a ser vendido/tokenizado dentro do volume total estimado e permitido pela FTK . 
* **_Floresta_**: Agrupamento de talhões! Dessa forma, uma propriedade pode ter várias florestas, pois a floresta não é uma propriedade, mas sim um agrupamento de talhões de mesmo ano de plantio e espécie.

## Exemplo Prático:
Exemplo:
Vamos supor que eu tenho uma matrícula que corresponde a minha propriedade. A minha propriedade contém 10 talhões de acordo com a análise da FTK. (Floresta 1)  5 talhões são todos de 2021 e são todos de mesma espécie: Pinus. (Floresta 2)  Os outros 5 talhões são do ano de 2023  e são de mesma espécie: Eucalipto.
Devido a alguns fatores, a FTK me permitiu tokenizar até 40% da floresta 1. Decidi tokenizar 30% desse total liberado. Esse será meu primeiro Lote.
Para a floresta 2 de talhões, a FTK me liberou 25%. Decidi tokenizar 10% desse agrupamento. Esse é meu segundo Lote.

Primeira Rodada:
1° Floresta = 40% liberado ✓
2° Floresta = 25% liberado ✓ 

Ano que vem, decidi começar outra rodada de tokenizacão. A FTK me liberou 20% a mais em cada floresta. Dessa forma, no primeira floresta, terei 60% liberado para tokenizacão e, para a segunda floresta, 45% liberado para tokenização.

Ano 2:
1° Floresta = 20% liberado ✓
2° Floresta = 20% liberado ✓
 
Numa terceira rodada de tokenizacão, a FTK
liberou mais 25% de tokenizacão para a primeira floresta. 🟥 Opa, mas isso é IMPOSSÍVEL, pois eu já estaria, no total, tokenizando 85% da minha primeira floresta (40+20+25= 85%). Para a segunda floresta, foi liberado também 25%, o que faz com que o segundo talhão tenha 45+25=70%, no total, liberado para tokenização.

Ano 3:
1° Floresta = 25% liberado ✓  🟥  (Impossível)
2° Floresta = 25% liberado ✓

Cada _struct_ Talhão e cada NFT, por si só, terão suas informações próprias: 
Talhão:
| Struct | Propriedade | Done |
| ------ | ------ | ------ |
|  Talhão | Coordenadas geográficas | ☑ |
| Talhão | Imagem | ☑ |
| Talhão |Potencial total de m³ de madeira|
|  Talhão| Tipo de madeira| ☑ |
| Talhão | Idade do talhão| ☑ |
| Talhão | Ano de Plantio | ☑ |
| Talhão | Ano de Corte| ☑ |
| Talhão | Greenfield/Brownfield| ☑ |

Lote/NFT:
| Struct | Propriedade | Done
| ------ | ------ | ------ |
|  Lote | Coordenadas geográficas | ☑ |
| Lote | Imagem | ☑ |
| Lote |Porcentagem tokenizada| ☑ |
|  Lote | Tipo de madeira| ☑ |
| Lote | Idade do lote (MM/YYYY) | |
| Lote | Ano de Plantio | ☑ |
| Lote | Ano de Corte| ☑ |
| Lote | Tipo de Tokenização (TPF ou TPFF) | |
| Lote | Valor de venda (vem da FTK) | ☑ |
| Lote | Proprietário | ☑ |
| Lote | Atual detentor da NFT | ☑ |
| Lote | Greenfield/Brownfield| ☑ |

## Localização do Lote
### Lote constituído de pedaços diferentes de vários talhões 
Lote = conjunto de %s de n talhões {1,2,...,n} de mesmo ano e mesma espécie (homogêneos).
NFT = lote. 

### Lote constituído de pedaço de um único talhão
Lote = % de um talhão que é integralmente do mesmo ano e mesma espécie (homogêneo).

### _Regra_: 
Talhões heterogêneos sempre farão parte de lotes diferentes.
#### Exemplos da regra acima:
Na imagem abaixo, os dois talhões devem ser obrigatoriamente **homogêneos** para que a área vermelha seja um lote só.

![Captura de tela 2023-02-09 224910 (1)](https://user-images.githubusercontent.com/79999985/218179809-0e674780-8ded-4a33-ae34-80c641b300d2.png)


Na imagem abaixo, a localização do lote poderá pertencer apenas ao talhão 1 **ou** 2, pois os talhões adjacentes são heterogêneos quanto à idade e espécie.

![Captura de tela 2023-02-09 224722 (1)](https://user-images.githubusercontent.com/79999985/218180013-1a6ee098-97f1-4d8e-a8da-60bdbc954633.png)

### Regras de Negócio:
Volume máximo tokenizado pode ser até 80% do volume total estimado pela FTK.

## Regra universal

- Volume máximo tokenizado = 80% do volume total de floresta (soma dos talhões) estimado pela FTK.

## Regras complementares

- É definido pela FTK o volume a ser tokenizado AGORA.
    - Não pode ser superior ao volume máximo tokenizado e vai ser atrelado à idade do plantio
- Máximo de tokenização por idade:

| Ano | Idade |
| ------ | ------ |
| Ano 1  | 30% |
| Ano 2 | 40% |
| Ano 3 | 50% |
| Ano 4 | 60% |
| Ano 5 | 70% |
| Ano 6 e 7 | 80% |

 Exemplo:
 Usuário tokenizou 30% da sua floresta no Ano1! No ano 2, ele poderá tokenizar apenas mais 10%, no máximo.
        
- Para o marketplace, é necessária a existência de um filtro que limite a capacidade do usuário de expôr seu asset; (NÃO ENTENDI)
- Valor de venda será determinado pelo próprio detentor do token no momento da transação;
- 3% do valor de venda deve ser transferido para a ForesToken para que a plataforma monetize em cima das transações.

### Necessidade da plataforma

- API quem será responsável por se conectar com um banco, gerando uma conta que cuidará do fluxo monetário.

### Perguntas:

O que significa: "Para o marketplace, é necessária a existência de um filtro que limite a capacidade do usuário de expôr seu asset?"
Cada NFT terá uma matrícula ou haverá uma matrícula só em relação ao COPF?
O link do Data Room terá o link do valuation ou serão links independentes?



