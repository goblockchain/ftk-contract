// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

//imports
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/GoTokensRole.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "hardhat/console.sol";
//https://ethereum.stackexchange.com/questions/93062/troubles-with-import-in-remix-ide/93063#93063

contract COPF is Ownable, GoTokensRoles, ERC1155, ERC1155Burnable {

//ESCOPO GLOBAL = PROPRIEDADE

uint256 public propertyRegistration; //matrícula
string public dataRoomLink;
string public tokenizationContractLink;
uint16 public florestsQuantity;
mapping(uint16 => Florest) florests;
uint8 public assetId = 1;
//uint8 public plotId = 0;
uint8 florestId = 1;
uint16 public currentYear = 2023;

//mapping (uint8 => string) private _tokenURIs;

bool isCurrentAssetAvailableForTransfer = false;

enum WoodType {PINUS, EUCALIPTO}
WoodType woodType;

enum AssetClassification {GREENFIELD, BROWNFIELD}
AssetClassification class;

enum NegociationType {TPR, TPFF}
NegociationType dealType;

uint32 public maxGlobalAllowedFlorestTokenizationPercentage = 80000; //it represents 80% => 80/100 = (for simplicity) 80000

mapping(uint16 => Plot[]) plotsInFlorest;
mapping(uint16 => Asset[]) public assetsInFlorest;
//mapping(uint16 => Asset[]) public assetsInPlots;
mapping(uint8 => Florest) public florestsInProperty;

struct Florest {
    uint32 tokenizedPercentage;
    WoodType woodTypeForFlorest; 
    uint16 plotsQuantityInCurrentFlorest;
    uint32 tokenizationPercentageGivenToFlorest;
    AssetClassification class;
    uint8 plotId;
}

struct Plot {
    string localization;
    uint16 plotAge;
    uint16 plotPlantingYear;
    uint16 plotCutYear;
    WoodType woodTypeForPlot; 
}

struct Asset {
    string geographicLocation;
    string buyOrSellContractLink;
    NegociationType assetTokenizationType;
    address initialOwner;
    address currentTokenOwner;
    AssetClassification class;
    bool isCurrentAssetAvailableForTransfer;
    string assetPropertyRegistration;
}

    /*╔═════════════════════════════╗
      ║           EVENTS            ║
      ╚═════════════════════════════╝*/
    event AssetValuationWevent(
        uint32 value,
        bool valuationSet
    );
    event AssetAvailabilityUpdated(
        bool availability
    );
    event AssetMinted(
        uint32 AssetId,
        address tokenOwner,
        uint8 assetId
    );
    event AssetBurned(
        uint8 assetId,
        bool wasBurned
    );
    event AssetTransferred(
        uint8 assetId,
        address newOwner,
        bool transferred
    );

    /**********************************/
    /*╔═════════════════════════════╗
      ║             END             ║
      ║            EVENTS           ║
      ╚═════════════════════════════╝*/
    /**********************************/
    /*╔═════════════════════════════╗
      ║          MODIFIERS          ║
      ╚═════════════════════════════╝*/
    /**********************************/

//modifier isAccountInitialAssetOwner(uint8 _assetId, address _initialOwner) {
//    require(_initialOwner == assets[_assetId].initialOwner, "Only florest's initial owner is allowed for this tx");
//    _;
//}

// modifier hasProjectEnded(uint8 _assetId){
//     require(this.currentYear() <= plots[_assetId].projectEnd, "project is still ongoing!");
//     _;
// }
    /*╔═════════════════════════════╗
      ║             END             ║
      ║          MODIFIERS          ║
      ╚═════════════════════════════╝*/
    /**********************************/
constructor(
    address _initialOwner,
    address _minter,
    uint256[] memory _ids,
    uint256[] memory _amount
    ) ERC1155("https://game.example/api/item/{id}.json") GoTokensRoles(msg.sender, _minter) {
    //console.log(assetId);
    //_mintBatch(_initialOwner, _ids, _amount, "mint");
    //setApprovalToTransferAssets(_initialOwner, msg.sender, true);
}

uint32 public woodPropertyMaxPotential;

    /*╔══════════════════════════════╗
      ║       SET FUNCTIONS          ║
      ╚══════════════════════════════╝*/

function createAFlorest(
    uint16 _plotsQuantityInCurrentFlorest,
    uint32 _tokenizationPercentageGivenToFlorest,
    //uint32 _tokenizedPercentage,
    WoodType _woodTypeForFlorest
) external onlyOwner returns(uint16) {
    require(_tokenizationPercentageGivenToFlorest <= 80000, "This florest can't infringe the universal rule");
    
    Florest storage florest = florestsInProperty[florestId]; 
    florest.woodTypeForFlorest = _woodTypeForFlorest;
    florest.plotsQuantityInCurrentFlorest = _plotsQuantityInCurrentFlorest;
    florest.tokenizedPercentage = 0;
    florest.tokenizationPercentageGivenToFlorest = _tokenizationPercentageGivenToFlorest;

    return florestId;
}

// uma floresta pode ter vários assets dentro dela.
// um asset pode estar dividido entre vários plots
// não se tokeniza plots, mas sim florests
// um asset não pode estar em duas florestas, pois florestas diferentes não têm a mesma idade.
// como o asset já tem sua localização especificada, o resto é dispensável
// pelas regras acima, numa propriedade, há várias florestas e podemos dar um push dentro
// de cada floresta, não importando se essa contém um ou mais plots, pq os assets conterão 
// as coordenadas do asset - que pode estar dentro, ou englobar vários plots.
function createAsset(Asset memory asset, uint16 _correspondingFlorest, uint256[] memory ids, uint256[] memory amount) external {
    //Florest storage florest = florestsInProperty[_correspondingFlorest];
    //validate if asset tokenization amount doesn't overflow florest's
    // validate if geographic location of different assets is the same
    if(assetId == 1){
    assetsInFlorest[_correspondingFlorest].push(Asset(asset.geographicLocation,asset.buyOrSellContractLink, asset.assetTokenizationType,asset.initialOwner,asset.currentTokenOwner,asset.class,asset.isCurrentAssetAvailableForTransfer,asset.assetPropertyRegistration));
    } else {
        for(uint8 i = 0; i <= assetId; i++){
            string storage geo = assetsInFlorest[_correspondingFlorest][i].geographicLocation;
            require(keccak256(abi.encodePacked(asset.geographicLocation)) != keccak256(abi.encodePacked(geo)),"asset exists");
        }
    }
    //mint
    _mintBatch(asset.currentTokenOwner, ids, amount,"");
    setApprovalToTransferAssets(asset.currentTokenOwner, msg.sender, true);
    //increase number of assets minted in property
    assetId++;
}

//create florest
//create asset
//check balanceOf
//try to transfer using safeTransferFrom
// struct Asset {
//     string geographicLocation;
//     string buyOrSellContractLink;
//     NegociationType assetTokenizationType;
//     address initialOwner;
//     address currentTokenOwner;
//     AssetClassification class;
//     bool isCurrentAssetAvailableForTransfer;
//     string assetPropertyRegistration;
// }

// function createAsset(Asset memory _asset) internal {
    
//     Asset storage asset = assetsInPlots[][assetId];
//     asset.geographicLocation = _asset.geographicLocation;
//     asset.buyOrSellContractLink = _asset.buyOrSellContractLink;
//     asset.assetTokenizationType = _asset.assetTokenizationType;
//     asset.initialOwner = _asset.initialOwner;
//     asset.currentTokenOwner = _asset.currentTokenOwner;
//     asset.class = _asset.class;
//     asset.isCurrentAssetAvailableForTransfer = _asset.isCurrentAssetAvailableForTransfer;
//     asset.assetPropertyRegistration = _asset.assetPropertyRegistration;
//     //mint function
// }

function tokenizeAssetInFlorest(Asset memory _asset,uint32 _tokenizePercentage, uint8 _correspondingFlorest) external {
    //get florest
    Florest storage florest = florestsInProperty[_correspondingFlorest];
    //checks tokenization is smaller than universal rule
    //checks tokenization is smaller than allowed tokenization
    require(_tokenizePercentage <= florest.tokenizationPercentageGivenToFlorest, "florest not allowed to tokenize this amount");
    florest.tokenizedPercentage = _tokenizePercentage;
    //create an asset with the tokenizePercentage
    //call another function to create the asset
    //createAsset(_asset);
}

function getPlot(uint8 _correspondingFlorest, uint16 _correspondingPlot) external view returns(Plot memory) {
        //Florest storage correspondingFlorest = florestsInProperty[_correspondingFlorest];
        Plot storage plot = plotsInFlorest[_correspondingFlorest][_correspondingPlot];
        return plot;
}

function createAPlot(
    Plot memory plot,
    uint8 _correspondingFlorest
) external returns(Plot memory)
{
    Florest storage florest = florestsInProperty[_correspondingFlorest];
    //validate florest's number of plots
    require((florest.plotId + 1) <= florest.plotsQuantityInCurrentFlorest,"exceeded");
    require(florest.woodTypeForFlorest == plot.woodTypeForPlot,"diffwood");
    //validate type of florest's wood type with plot's wood type
    if(florest.plotId == 0) {
        plotsInFlorest[_correspondingFlorest].push(Plot(plot.localization,plot.plotAge,plot.plotPlantingYear,plot.plotCutYear,plot.woodTypeForPlot));
        florest.plotId++;
    } else {
        Plot storage _plot = plotsInFlorest[_correspondingFlorest][0];
        //validate plot's wood with florest's wood
        require(plot.woodTypeForPlot == _plot.woodTypeForPlot, "wood type naif"); //naif = not accepted in florest
        //validate plot's age and woodType
        require(plot.plotAge == _plot.plotAge, "plot age naif");
        //create plot
        plotsInFlorest[_correspondingFlorest].push(Plot(plot.localization,plot.plotAge,plot.plotPlantingYear,plot.plotCutYear,plot.woodTypeForPlot));
        florest.plotId++;
    }
}

// function to reset number of plots in florest
function resetPlotQuantityinFlorest(uint8 _correspondingFlorest, uint16 _newPlotQuantityInFlorest) external onlyOwner {
    Florest storage florest = florestsInProperty[_correspondingFlorest];
    florest.plotsQuantityInCurrentFlorest = _newPlotQuantityInFlorest;
}

//getter for number of plots in florest.
function getCurrentPlotNumberinFlorest(uint8 _correspondingFlorest) external view returns(uint8) {
    Florest storage florest = florestsInProperty[_correspondingFlorest];
    return florest.plotId;
}

function getDefaultPlot( uint8 _correspondingFlorest) external view returns(Plot memory) {
    Plot storage _plot = plotsInFlorest[_correspondingFlorest][0];
    return _plot;
}
    /*╔══════════════════════════════╗
      ║     CHECK FUNCTIONS          ║
      ╚══════════════════════════════╝*/
//function getPlotsInFlorest(uint16 _florestId) external view returns(Plot[] memory) {
//    return florests[_florestId].plotsInFlorest;
//}

//function getAgeAndWoodTypeForAFlorest(uint8 _correspondingFlorest) external view returns(uint16, uint16){
//    Florest storage correspondingFlorest = florests[_correspondingFlorest];
//
//    uint16 correctAgeForPlotsInFlorest = correspondingFlorest.plotsInFlorest[0].plotAge;
//    uint16 correctWoodTypeForPlotsInFlorest = uint16(correspondingFlorest.plotsInFlorest[0].woodTypeForPlot);
//    return (correctAgeForPlotsInFlorest, correctWoodTypeForPlotsInFlorest);
//}
      
function checkOwnership() public view returns(address) {
    return owner();
}
    
// function isAssetAvailableForTransfer(uint8 _assetId) internal view returns(bool){
//         Asset[] storage asset = assetsInPlots[_assetId];
//         return asset[assetId].isCurrentAssetAvailableForTransfer;
// }

function setCurrentYear(uint16 _currentYear) external onlyRole(MINTER_ROLE) {
        currentYear = _currentYear;
}

// function setAssetAvailabilityForTransfer(uint8 _assetId, bool _availability) external returns(bool) {
//         Asset[] storage asset = assetsInPlots[_assetId];
//         asset[assetId].isCurrentAssetAvailableForTransfer = _availability;
//         assetId++;
//         return asset[_assetId].isCurrentAssetAvailableForTransfer;
// }

// make the function available for future mints of other asset in the same florest 
function mint(
    // _tokenizedPercentage,
    // _geographicLocation,
    // _assetImage,
    // _woodTypeForAsset,
    // _assetAge,
    // _assetPlantingYear,
    // _assetCutYear,
    // _assetTokenizationType,
    // _soldByTheValueOf,
    address _initialOwner,
    // _currentTokenOwner,
    // _class,
    // _AssetValuation,
    // _isCurrentAssetAvailableForTransfer,
    uint256[] calldata ids, 
    uint256[] calldata amounts
    )
 onlyRole(MINTER_ROLE) 
 external {
    uint8 _assetId = assetId++;
    

    //
    _mintBatch(_initialOwner, ids, amounts, "minting");
    
    setApprovalToTransferAssets(_initialOwner, msg.sender, true);
}

function setApprovalToTransferAssets(address holderAccount, address operator, bool approved)
    internal onlyRole(MINTER_ROLE)
{
    //The setApprovalForAll() function is used to assign or revoke the full approval rights to the given operator.
    //The caller of the function (msg.sender) is the approver.
    _setApprovalForAll(holderAccount, operator, approved);
} 


//This function needs to be invoked whenever the TED  transfer has been done
//function transferAsset(uint8 _assetId, address _newOwner, uint256 _amount) external {
    //require(isAssetAvailableForTransfer(_assetId), "asset is currently not available for transfer");
    //address pastOwner = assets[_assetId].tokenOwner;
    //setApprovalToTransferAssets(pastOwner, msg.sender, true);
    //safeTransferFrom(pastOwner, _newOwner, _assetId, _amount, "transfer");
    //assets[_assetId].tokenOwner = _newOwner;
    //emit AssetTransferred(_assetId, _newOwner, assets[_assetId].tokenOwner == _newOwner);
//}

//function declared to avoid the below compilation error:
//TypeError: Derived contract must override function "supportsInterface". Two or more base classes define function with same name and parameter types.
function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
    return super.supportsInterface(interfaceId);
}

}