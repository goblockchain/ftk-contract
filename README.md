Contrato COPF:

# OBS:
Nesse contexto, o termo asset se refere a um *lote* de uma fazenda, não à fazenda completa. Logo, *asset = lote*.
Cada tokenId mintado no contrato representa então um lote diferente da fazenda.

# REQUISITOS COPF:
```
Armazenar AssetType {PINUS, EUCALIPTO}
Armazenar AssetClassification {GREENFIELD, BROWNFIELD}
Função para settar o asset VALUATION
Proprietário e Detentor do asset são armazenados no COPF
Só quem tokenizou inicialmente o ativo (proprietário) pode fazer o burn
```
De acordo com o exame da plataforma e consulta ao Allan, John e Rodolfo, algumas definições:
O que será negociado na plataforma será um lote de uma floresta, não a floresta inteira.
A floresta inteira será negociada como um todo apenas se a mesma não tiver nenhum lote e for, por si só, o único lote.
O worket pode ser futuramente adaptado ao projeto a fim de executar a transação de transferência de uma NFT quando um evento for emitido pela confirmação da transferência em dinheiro feita por TED ou usando a FoxBit.

Haverá uma struct que armazenará todas as informações necessárias sobre um Lote específico. 
```
struct Asset {
    //It is the florest's owner when tokenization happened
    address initialOwner;
    AssetType assetType;
    uint16 projectStart;
    uint16 projectEnd;
    AssetClassification assetClassification;
    uint32 AssetValuation;
    bool isCurrentAssetAvailableForTransfer;
    //It is the current token owner after negotiations have been made
    address tokenOwner;
}
```

![struct](https://user-images.githubusercontent.com/79999985/216133976-41b8cfff-b443-4bfe-9f2b-f6db12c7a6f8.png)

O dono da floresta definirá quantos talhões a floresta terá e o máximo será de 255 talhões. **(Deve ser ajustado?)**
<! --- Quantidade de talhões a serem mintados -->
Uint8 public assetId = 0;

Os assets individuais poderão ter suas informaçõs acessadas por meio do mapping público entre um tokenId e seu asset Asset.
![assets](https://user-images.githubusercontent.com/79999985/216135099-fc5c3be5-fc71-497e-99f0-e933a3cabd44.png)

O dono inicial da floresta será armazenado, mesmo que ela tenha várias transferências em seu ciclo de vida. O dono será armazenado no constructor a fim de que ele seja autorizado a queimar a floresta futuramente. (A ser definido como isso exatamente funcionará.)

Cada lote terá um número associado a ele p/ diferenciá-lo
Cada Asset é um lote da floresta. Não existirá informações sobre a floresta inteira, APENAS se a mesma for o único lote disponível.

Haverá um máximo de 255 talhões numa floresta

Assim como na goTokens, o responsável pelas txs será a conta da company.

Cada floresta será um único contrato ERC721 sendo única por ter um endereço único na Ethereum/Polygon. Cada talhão será único ao ser um id único de uma NFT dentro de um 721 único.

# A Fazer 
Armazenar tokenization_type: Própria ou Terceiros
Armazenar contractType: TPF ou TPFF

Depois que paga a negociação por meio de (TED/Foxbit?) (A Definir), o ativo é transferido...Mas quem fará tal transação?
1. Caso estivermos mintando para as contas individuais dos usuários, apenas os mesmos podem transferir - e, dessa forma, precisariam de gas. 
2. Caso estivermos mintando para a conta da company, as NFTs não serão mostradas nas contas dos usuários.
