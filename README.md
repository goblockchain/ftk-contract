# COPF
## _Dados Armazenados no Contrato_
Váriaveis Globais do Smart Contract 
| Nível | Variável | Type |
| ------ | ------ | ------ | 
| Smart Contract | localizações dos talhões | Array |
| Smart Contract | Imagens | Array |
| Smart Contract |Potencial total de m³ de madeira| Number |
| Smart Contract | Tipo de madeira| Enum |
| Smart Contract | Idade do talhão| Dates |
| Smart Contract | Ano de Plantio | Dates |
| Smart Contract | Ano de Corte| Dates |
| Smart Contract | % Máxima de Tokenização Universal | Number = 80% |
| Smart Contract | Nome da Floresta | Texto |
| Smart Contract | Matrícula do Imóvel | Texto |
| Smart Contract | Quantidade de talhões na floresta | Number |
| Smart Contract | % máxima de tokenização liberada p/ a floresta | Number |
| Smart Contract | link do data room | Texto |
| Smart Contract | link do contrato de compra e venda | Texto |
| Smart Contract | link do contrato de tokenização | Texto |

## Regras de Tokenização:
* _(1)_ Quantidade potencial de m³ de madeira (Decidido pela FTK). 
* _(2)_ Quantidade liberada pela FTK para ser tokenizada. (Decidido pela FTK).
* _(3)_ A quantidade liberada (pela FTK) e tokenizada (pelo proprietário) não pode passar dos 80% do tamanho da área com potencial de tokenização _(1)_.

## Definições
* **_Data Room_**: Link que contém informações sobre a floresta como, por exemplo, documentação do due diligence, matrícula, documentação do proprietário. O data room é usado pela FTK e comprador para acompanhar se a floresta está crescendo.
* **_Talhão_**: Área com potencial de ser tokenizada dentro de uma floresta e é sempre homogênea em relação à sua idade e em relação à espécie contida nela.
* **_Lote_**: Porcentagem do volume decidido pelo usuário a ser vendido/tokenizado dentro do volume total estimado e permitido pela FTK . 

## Exemplo Prático:
Suponha que a floresta tem 2 talhões, e a porcentagem do volume total de 2 talhões a ser tokenizada é 25%, e essa porcentagem foi decidida pela FTK (A FTK estipula a % a ser disponível para tokenização de acordo com alguns fatores, por exemplo, idade do plantio). O proprietário florestal, no entanto, decidiu tokenizar apenas 10% desssa floresta (primeiro lote). Imagine então que a figura abaixo representa o que o proprietário decidiu tokenizar. Dessa forma, no mesmo ano, o proprietário da floresta poderá, por exemplo, optar por tokenizar mais 15%, sendo esses 15% outro lote. Então cada um dos lotes será uma NFT. (Localização) O talhão é importante para que assegure que o material (madeira) a ser recolhida não seja de uma área diferente/qualidade inferior. Caso os dois talhões sejam homogêneos entre si, o proprietário poderá tokenizar um lote que pertença simultaneamente aos dois talhões. Caso os dois talhões sejam heterogêneos entre si,  o proprietário o lote fará então, **_necessariamente_**, parte de apenas um dos talhões.

Cada _struct_ Talhão e cada NFT, por si só, terão suas informações próprias: 
Talhão:
| Struct | Propriedade |
| ------ | ------ |
|  Talhão | Coordenadas geográficas |
| Talhão | Imagem |
| Talhão |Potencial total de m³ de madeira|
|  Talhão| Tipo de madeira|
| Talhão | Idade do talhão|
| Talhão | Ano de Plantio |
| Talhão | Ano de Corte| 

Lote/NFT:
| Struct | Propriedade |
| ------ | ------ |
|  Lote | Coordenadas geográficas |
| Lote | Imagem |
| Lote |Porcentagem tokenizada|
|  Lote | Tipo de madeira|
| Lote | Idade do talhão (MM/YYYY) |
| Lote | Ano de Plantio |
| Lote | Ano de Corte| 
| Lote | Tipo de Tokenização (TPF ou TPFF) |
| Lote | Valor de venda (vem da FTK) |
| Lote | Proprietário |
| Lote | Atual detentor da NFT |

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



