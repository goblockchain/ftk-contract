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
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "hardhat/console.sol";
//https://ethereum.stackexchange.com/questions/93062/troubles-with-import-in-remix-ide/93063#93063

contract COPF is Ownable, GoTokensRoles, ERC1155, ERC1155Burnable, ERC1155URIStorage {

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

bool isCurrentAssetAvailableForTransfer = false;

enum WoodType {PINUS, EUCALIPTO}
WoodType woodType;

enum AssetClassification {GREENFIELD, BROWNFIELD}
AssetClassification class;

enum NegociationType {TPR, TPFF}
NegociationType dealType;

uint32 public maxGlobalAllowedFlorestTokenizationPercentage = 80000; //it represents 80% => 80/100 = (for simplicity) 80000

string private _baseURI = "";
mapping (uint8 => string) private _tokenURIs;
//string private _baseURIextended;
mapping(uint16 => Plot[]) plotsInFlorest;
mapping(uint16 => Asset[]) public assetsInFlorest;
//assetId => florestId
mapping(uint16 => uint16) public assetsQuantityInFlorest;
mapping(uint16 => Florest) public florestsInProperty;
mapping(uint16 => uint32[]) public tokenizedPercentagesOfAssetsInFlorest;

struct Florest {
    uint32 tokenizedPercentage;
    WoodType woodTypeForFlorest; 
    uint16 plotsQuantityInCurrentFlorest;
    uint32[] tokenizationPercentageGivenToFlorest;
    AssetClassification class;
    uint8 plotId;
}

struct Plot {
    string localization;
    uint64 plotAge;
    uint64 plotPlantingYear;
    uint64 plotCutYear;
    WoodType woodTypeForPlot; 
}

struct Asset {
    string geographicLocation;
    WoodType woodTypeForAsset;
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
constructor(
    address _minter
    ) ERC1155("") GoTokensRoles(msg.sender, _minter) {
}

uint32 public woodPropertyMaxPotential;

    /*╔══════════════════════════════╗
      ║       CREATE FUNCTIONS       ║
      ╚══════════════════════════════╝*/

function createAFlorest(
    uint16 _plotsQuantityInCurrentFlorest,
    uint32 _tokenizationPercentageGivenToFlorest,
    //uint32 _tokenizedPercentage,
    WoodType _woodTypeForFlorest
) external onlyOwner returns(uint16) {
    require(_tokenizationPercentageGivenToFlorest <= 80000, "80% rule");
    
    Florest storage florest = florestsInProperty[florestId]; 
    florest.woodTypeForFlorest = _woodTypeForFlorest;
    florest.plotsQuantityInCurrentFlorest = _plotsQuantityInCurrentFlorest;
    florest.tokenizedPercentage = 0;
    florest.tokenizationPercentageGivenToFlorest.push(_tokenizationPercentageGivenToFlorest);
    florestId++; 
    return florestId;
}

function createAsset(uint32 _tokenizedPercentage, Asset memory asset, uint16 _correspondingFlorest, uint256[] memory ids, uint256[] memory amount, string calldata _tokenURI ) external {
    //validate woodTypeForAsset is equal of florest's
    Florest storage florest = florestsInProperty[_correspondingFlorest];
    require(asset.woodTypeForAsset == florest.woodTypeForFlorest, "diff wood");
    uint16 assetIdInCurrentFlorest = assetsQuantityInFlorest[_correspondingFlorest];
    //validade if percentage isn't bigger than one given to florest.
    require(_tokenizedPercentage <= getAllowedPercentagesOfTokenizationForAFlorest(_correspondingFlorest, assetIdInCurrentFlorest),"not allowed %");
    // validate if geographic location of different assets is the same
    if(assetIdInCurrentFlorest == 1){
    assetsInFlorest[_correspondingFlorest].push(Asset(asset.geographicLocation,asset.woodTypeForAsset,asset.buyOrSellContractLink, asset.assetTokenizationType,asset.initialOwner,asset.currentTokenOwner,asset.class,asset.isCurrentAssetAvailableForTransfer,asset.assetPropertyRegistration));
    tokenizedPercentagesOfAssetsInFlorest[_correspondingFlorest].push(uint32(_tokenizedPercentage));
    } else {
        for(uint8 i = 0; i < (assetsInFlorest[_correspondingFlorest].length); i++){
            string storage geo = assetsInFlorest[_correspondingFlorest][i].geographicLocation;
            require(keccak256(abi.enacodePacked(asset.geographicLocation)) != keccak256(abi.encodePacked(geo)),"asset exists");
        }
    assetsInFlorest[_correspondingFlorest].push(Asset(asset.geographicLocation,asset.woodTypeForAsset,asset.buyOrSellContractLink, asset.assetTokenizationType,asset.initialOwner,asset.currentTokenOwner,asset.class,asset.isCurrentAssetAvailableForTransfer,asset.assetPropertyRegistration));
    tokenizedPercentagesOfAssetsInFlorest[_correspondingFlorest].push(uint32(_tokenizedPercentage));
    }
    ////validate if asset tokenization amount doesn't overflow 80000
    require(doesPercentagesObeyUniversalRule(uint16(_correspondingFlorest)), "80%+");
    //mint
    _mintBatch(asset.currentTokenOwner, ids, amount,"");
    setApprovalToTransferAssets(asset.currentTokenOwner, msg.sender, true);
    //increase number of assets minted in property
    assetIdInCurrentFlorest++;
    _setURI(ids[0], _tokenURI);
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
        //validate plot's age and localization 
        require(plot.plotAge == _plot.plotAge, "plot age naif");
        for(uint8 i = 0; i < (plotsInFlorest[_correspondingFlorest].length); i++){
            string storage plotLocalization = plotsInFlorest[_correspondingFlorest][i].localization;
            console.log(plotLocalization);
            require(keccak256(abi.encodePacked(plotLocalization)) != keccak256(abi.encodePacked(plot.localization)),"plot exists");
    }
    //create plot
    plotsInFlorest[_correspondingFlorest].push(Plot(plot.localization,plot.plotAge,plot.plotPlantingYear,plot.plotCutYear,plot.woodTypeForPlot));
    florest.plotId++;
    }
}

//function to reset tokenization amount for a florest - to be increased over years.
function updateFlorest(
    uint16 _plotsQuantityInCurrentFlorest,
    uint32 _tokenizationPercentageGivenToFlorest,
    WoodType _woodTypeForFlorest,
    uint16 _florestToUpdate
) external onlyOwner returns(uint16) {
    require(_tokenizationPercentageGivenToFlorest <= 80000, "80% rule");
    Florest storage florest = florestsInProperty[_florestToUpdate]; 
    florest.woodTypeForFlorest = _woodTypeForFlorest;
    florest.plotsQuantityInCurrentFlorest = _plotsQuantityInCurrentFlorest;
    florest.tokenizedPercentage = getTokenizedPercentagesSumForAFlorest(_florestToUpdate); //function to get assets sum
    console.log(getTokenizedPercentagesSumForAFlorest(_florestToUpdate));
    florest.tokenizationPercentageGivenToFlorest.push(_tokenizationPercentageGivenToFlorest);
    require(getAllowedSumPercentagesOfTokenizationForAFlorest(_florestToUpdate) <= 80000,"80%");
}

    /*╔══════════════════════════════╗
      ║          URI FUNCTIONS       ║
      ╚══════════════════════════════╝*/
function setBaseURI(string memory _newBaseURI) public onlyOwner {
    _setBaseURI(_newBaseURI);
} 

function setEachURI(uint256 _id, string memory _newURI) public onlyOwner {
    _setURI(_id, _newURI);
}

function uri(uint256 tokenId) public view virtual override(ERC1155, ERC1155URIStorage) returns (string memory) {
    string memory tokenURI = _tokenURIs[uint8(tokenId)];
    // If token URI is set, concatenate base URI and tokenURI (via abi.encodePacked).
    return bytes(tokenURI).length > 0 ? string(abi.encodePacked(_baseURI, tokenURI)) : super.uri(tokenId);
    //return bytes(tokenURI).length > 0 ? tokenURI : _baseURI;
}

function getTokenizedPercentagesSumForAFlorest (uint16 _correspondingFlorest) internal view returns(uint32) {
    uint32[] storage percentages = tokenizedPercentagesOfAssetsInFlorest[_correspondingFlorest];
    uint32 sumOfPercentages;
    for (uint8 i=0; i<percentages.length; i++) {
    sumOfPercentages += tokenizedPercentagesOfAssetsInFlorest[_correspondingFlorest][i];
    }
    return sumOfPercentages;
}

// get tokenization percentage that WAS GIVEN to florest over each round of tokenization
// check that in that specific round, this is the max allowed % given.
function getAllowedPercentagesOfTokenizationForAFlorest(uint16 _correspondingFlorest, uint16 _assetId) internal view returns(uint32){
    Florest storage florest = florestsInProperty[_correspondingFlorest]; 
    uint32[] storage percentagesGiven = florest.tokenizationPercentageGivenToFlorest;
    return percentagesGiven[_assetId];
}

function getAllowedSumPercentagesOfTokenizationForAFlorest(uint16 _correspondingFlorest) internal view returns(uint32) {
    Florest storage florest = florestsInProperty[_correspondingFlorest];
    uint32[] storage percentagesGiven = florest.tokenizationPercentageGivenToFlorest;
    uint32 sumOfAllowedPercentages;
    for( uint8 i = 0; i < percentagesGiven.length; i++){
        sumOfAllowedPercentages += florest.tokenizationPercentageGivenToFlorest[i];
    }
    return sumOfAllowedPercentages;
}

function getExternalAllowedPercentagesOfTokenizationForAFlorest(uint16 _correspondingFlorest) external view returns(uint32[] memory) {
    Florest storage florest = florestsInProperty[_correspondingFlorest];
    uint32[] storage percentagesGiven = florest.tokenizationPercentageGivenToFlorest;
    return percentagesGiven;
}



function doesPercentagesObeyUniversalRule(uint16 _florest) internal view returns(bool) {
    Florest storage florest = florests[_florest];
    uint32[] storage percentages = tokenizedPercentagesOfAssetsInFlorest[_florest];
    uint32 sumOfPercentages;
    for (uint8 i=0; i<percentages.length; i++) {
        sumOfPercentages += tokenizedPercentagesOfAssetsInFlorest[_florest][i];
    }
    return (sumOfPercentages <= 80000);
}

function getAssetInFlorest(uint16 _correspondingFlorest, uint8 _assetId) external view returns(Asset memory){
    return assetsInFlorest[_correspondingFlorest][_assetId];
}

function getPlot(uint8 _correspondingFlorest, uint16 _correspondingPlot) external view returns(Plot memory) {
        Plot storage plot = plotsInFlorest[_correspondingFlorest][_correspondingPlot];
        return plot;
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
      
function checkOwnership() public view returns(address) {
    return owner();
}

function setCurrentYear(uint16 _currentYear) external onlyRole(MINTER_ROLE) {
        currentYear = _currentYear;
}

function setApprovalToTransferAssets(address holderAccount, address operator, bool approved)
    internal onlyRole(MINTER_ROLE)
{
    _setApprovalForAll(holderAccount, operator, approved);
} 

//function declared to avoid the below compilation error:
//TypeError: Derived contract must override function "supportsInterface". Two or more base classes define function with same name and parameter types.
function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
    return super.supportsInterface(interfaceId);
}

}