Contrato COPF:

Requisitos:
REQUISITOS COPF:
Armazenar field_type
Armazenar plant_type
Armazenar tokenization_type: Própria ou Terceiros
Set Função para armazenamento de VALUATION
Constructor receives all the information stored in BD by folllowing tokenization
steps.
Proprietário e Detentor armazenado no COPF
Só quem tokenizou pode burn a NFT
Depois que paga a negociação, o ativo é transferido (Verificar como o contrato saberia disso: lembrando que de início talvez seja feito manualmente.)
Cada fazenda tem vários talhões => validações de soma dos m³ dos talhões não 
ultrapassar m³ total da floresta.

Global:
Nome da Floresta
Localização
Dono
CNPJ
Capacidade total de metros cúbicos
Lista de lotes criados
Mapping do id do lote e informações 1 => struct

total


Haverá uma str
uct que armazenará todas as informações necessárias sobre um talhão específico. 

Struct Talhão{
    //Key: example
    ownerId: '63bc94195ae1d7b3de34ae6d'
    assetType: pinus/eucalipto
    projectStart: 2023 
    projectEnd:2047
    assetClassification: Greenfield/Brownfield
    ValuationofTalhão: R$100,00 m³
    deve mostrar valor total: decidido pelo dono
    deve mostrar asset_owner:
    deve transferir asset_owner when valor total is paid;    
Quantidade de metros cúbicos 
}

O dono da floresta definirá quantos talhões a floresta terá.

//Quantidade de talhões a serem mintados
Uint8 public talhãoID = 0;

O dono inicial da floresta será armazenado, mesmo que ela tenha várias transferências em seu ciclo de vida. O dono será armazenado no constructor a fim de que ele seja autorizado a queimar a floresta. (A ser definido como isso exatamente funcionará)

Só quem tokenizou pode burn a NFT
//Dono inicial do contrato
Address owner;

// Cada talhão terá um número associado a ele p/ diferenciá-los
//máximo de 255 talhões
Mapping (uint8 => Talhão) TalhãoNFT;

Constructor receives all the information stored in BD by folllowing tokenization
steps.
constructor(){
	Owner = msg.sender? O dono da floresta interagiria com a blockchain? Provavelmente, aqui entraria o worker.
}


function _mint(uint256 talhãoID ) public {
	//o número do talhão será acrescido
	talhãoID++
        _safeMint(msg.sender, talhãoID);
}

function tokenURI(uint256 talhãoID)
        public
        view
        virtual tokenExist(tokenId)
        returns (string memory)
    {
        return uri(tokenId);
    }

   function totalSupply() public view returns (uint256) {
        Return talhãoID;
    }

   Function burn() public onlyOwner returns (bool) {
	_burn(talhãoID)
} 

Cada floresta será um único contrato ERC721 sendo única por ter um endereço único na Ethereum/Polygon. Cada talhão será único ao ser um id único de uma NFT dentro de um 721 único.
