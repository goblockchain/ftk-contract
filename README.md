Contrato COPF:

# OBS:
Nesse contexto, o termo asset se refere a um lote de uma fazenda, não à fazenda completa.

# REQUISITOS COPF:
Armazenar AssetType {PINUS, EUCALIPTO}
Armazenar AssetClassification {GREENFIELD, BROWNFIELD}
Função para settar o asset VALUATION
Proprietário e Detentor do asset são armazenados no COPF
Só quem tokenizou inicialmente o ativo (proprietário) pode fazer o burn

Constructor receives all the information stored in BD by folllowing tokenization steps.

Lista of assets inside the contract can be called by the front-end by retrieving the current uint8 assetId and looping till assetId on assets array.

Haverá uma struct que armazenará todas as informações necessárias sobre um Lote específico. 
`
struct Asset {
    //It is the florest's owner when tokenization happened
    address initialOwner;
    AssetType assetType;
    uint16 projectStart;
    uint16 projectEnd;
    AssetClassification assetClassification;
    uint32 AssetValuation;
    bool isCurrentAssetAvailableForTransfer;
    //It is the current token owner after deals have been made
    address tokenOwner;
}
`
O dono da floresta definirá quantos talhões a floresta terá.

<! --- Quantidade de talhões a serem mintados -->
Uint8 public assetId = 0;

O dono inicial da floresta será armazenado, mesmo que ela tenha várias transferências em seu ciclo de vida. O dono será armazenado no constructor a fim de que ele seja autorizado a queimar a floresta futuramente. (A ser definido como isso exatamente funcionará.)

Cada lote terá um número associado a ele p/ diferenciá-lo
Cada Asset é um lote da floresta. Não existirá informações sobre a floresta inteira, APENAS se a mesma for o único lote disponível.

//máximo de 255 talhões numa floresta
Mapping (uint8 => Talhão) TalhãoNFT;

constructor(){
	Assim como na goTokens, o responsável pelas txs será a conta da company. 
}

Cada floresta será um único contrato ERC721 sendo única por ter um endereço único na Ethereum/Polygon. Cada talhão será único ao ser um id único de uma NFT dentro de um 721 único.

# A Fazer 
Armazenar tokenization_type: Própria ou Terceiros
Armazenar contractType: TPF ou TPFF

Depois que paga a negociação por meio de (TED/Foxbit?) (A Definir), o ativo é transferido...Mas quem fará tal transação?
1. Caso estivermos mintando para as contas individuais dos usuários, apenas os mesmos podem transferir - e, dessa forma, precisariam de gas. 
2. Caso estivermos mintando para a conta da company, as NFTs não serão mostradas nas contas dos usuários.
