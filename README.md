Contrato COPF:

# Como Utilizar:
<ol>
<li>1. Clone o reposítório.</li>
<li> 2. No terminal, use o comando:
![remix3](https://user-images.githubusercontent.com/79999985/217089820-9edc73a6-4c3a-4003-bedf-9e70fccf16f0.png)
<li> 3. No site https://remix.ethereum.org/, selecione `connect to localhost` como mostrado na imagem abaixo: </li>
</ol>

![remix2](https://user-images.githubusercontent.com/79999985/217088827-f0e2ec6d-1b7b-449c-b82b-80609eeba846.png)

4. Compile o arquivo COPF.sol e faça o deploy na testnet do remix.
5. Use as funções na seguinte orderm:
<ol>
<ul> 5.1: `Deploy()`: It deploys the contract and all the information given in the constructor is then associated with assetId = 0. </ul>
<ul> 5.2: `setAssetValuation()`:  It sets the asset (lote) valuation by the (MINTER_ROLE) = FTK. </ul>
<ul> 5.3: `setAssetAvailabilityForTransfer()`: It sets the asset availability to true for assetId = 0.
This function is here because the tokenizator will need to make an asset available to negotiations, but by default the assets are in the `Indisponível` state </ul>
![hml](https://user-images.githubusercontent.com/79999985/217090843-36b91f8a-4746-44dd-914a-63bdc62974ce.png)
<ul> 5.4: `transferAsset()`: to transfer assetId = 0 to another account so that the *tokenOwner* can change. </ul>
<ul> 5.5: `assets()`: to view asset information for assetId = 0. </ul>
</ol>

# OBS:
Nesse contexto, o termo asset se refere a um *lote* de uma fazenda, não à fazenda completa. Logo, *asset = lote*.
Cada tokenId mintado no contrato representa então um lote diferente da fazenda.
**MINTER_ROLE** is the FTK company. Assim como na goTokens, o responsável pelas txs será a conta da company. 

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

![assett](https://user-images.githubusercontent.com/79999985/217091133-5eb9bba7-db3d-41df-9dc1-f0c8364cfd4c.png)

O dono da floresta definirá quantos talhões a floresta terá e o máximo será de 255 talhões. **(Deve ser ajustado?)**
<! --- Quantidade de talhões a serem mintados -->
Uint8 public assetId = 0;

Os assets individuais poderão ter suas informaçõs acessadas por meio do mapping público entre um tokenId e seu asset do tipo Asset.
![assets](https://user-images.githubusercontent.com/79999985/216135099-fc5c3be5-fc71-497e-99f0-e933a3cabd44.png)

O dono inicial da floresta será armazenado, mesmo que ela tenha várias transferências em seu ciclo de vida. O dono será armazenado no constructor a fim de que ele seja autorizado a queimar a floresta futuramente. **(A ser definido como isso exatamente funcionará.)**

Cada lote terá um número associado a ele p/ diferenciá-lo
*Cada Asset é um lote da floresta.* Não existirá informações sobre a floresta inteira, APENAS se a mesma for o único lote disponível.



No constructor, as características do asset são informadas, assim como o *minter* para a ROLE: **MINTER_ROLE**, a baseURI dos lotes, assim como o tokenURI do primeiro asset de id = 0. 

Cada floresta será um único contrato ERC721 sendo única por ter um endereço único na Ethereum/Polygon. Cada talhão será único ao ser um id único de uma NFT dentro de um 721 único.

# Vulnerabilidades
**No issues found** quando usado o KARL
![karl](https://user-images.githubusercontent.com/79999985/217381032-0ea01148-bd8d-4c39-91e8-8c16f8453c0f.png)


# A Fazer 
Definir se o máximo de talhões será 255 mesmo.
Definir se o ERC20 ficará em um arquivo separado ou serão dois contratos nesse mesmo arquivo .sol?

Depois que paga a negociação por meio de (TED/Foxbit?) (A Definir), o ativo é transferido por meio do MINTER_ROLE.
1.1 O ADMIN_ROLE será o *msg.sender* que fará o deploy do contrato na blockchain.
1. Este contrato já suporta múltiplas transferências do asset para diferentes contas usando a função `transferAsset()`
