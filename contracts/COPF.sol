// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//imports
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/GoTokensRole.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

//ERC721URIStorage already inherits functions from ERC721
contract COPF is Ownable, GoTokensRoles, ERC1155, ERC1155Burnable {

//ESCOPO GLOBAL = FLORESTA.

string[] public plotsLocalization;
string[] public plotsImages;
uint32 public woodFlorestMaxPotential;
uint32 public maxAllowedFlorestTokenizationPercentage = 80000; //it represents 80% => 80/100 = (for simplicity) 80000
uint256 public florestRegistration; //matrícula
//create set functions for the following variables;
uint32 public woodFlorestMaxPotential;
string public florestName;
uint16 public plotsQuantityInCurrentFlorest;
uint32 public maxTokenizationGivenToFlorest;
string public dataRoomLink;
string public buyOrSellContractLink;
string public tokenizationContractLink;

//Keeps track of which asset of the florest is currently being minted
//max value of above declared florestValuation = 4.294.967.295 = 4 bilhões, 294 milhões, etc.
uint8 public assetId = 1;
uint16 public currentYear = 2023;

mapping (uint8 => string) private _tokenURIs;

bool isCurrentAssetAvailableForTransfer = false;

enum WoodType {PINUS, EUCALIPTO}
WoodType private assetType;

enum AssetClassification {GREENFIELD, BROWNFIELD}
AssetClassification private assetClassif;

enum NegociationType {TPR, TPFF}
NegociationType private dealType; 

struct Asset {
    //How much of the allowed percentage does this specific asset uses? For example: asset 1 takes 15% of 25% given to the whole COPF.
    //Numbers are going to be represented as 15% =  15000
    uint32 tokenizedPercentage; 
    string geographicLocation;
    string assetImage;
    WoodType woodTypeForAsset;
    bytes32 assetAge;
    uint16 assetPlantingYear;
    uint16 assetCutYear;
    NegociationType assetTokenizationType;
    uint256 soldByTheValueOf; //it comes from the FTK
    address initialOwner;
    address currentTokenOwner;
    AssetClassification class;
    uint32 AssetValuation;
    bool isCurrentAssetAvailableForTransfer;
    string florestRegistration;
}

struct Plot {
    string localization;
    string plotImage;
    AssetClassification class;
    WoodType woodTypeForPlot;
    uint16 plotAge;
    uint16 plotPlantingYear;
    uint16 plotCutYear;
    // Potencial total de m³ de madeira não deveria ficar no escopo do contrato?
}

mapping(uint8 => Asset) public assets;
mapping(uint8 => Plot) public plots;


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

modifier isAccountInitialAssetOwner(uint8 _assetId, address _initialOwner) {
    require(_initialOwner == assets[_assetId].initialOwner, "Only florest's initial owner is allowed for this tx");
    _;
}

modifier hasProjectEnded(uint8 _assetId){
    require(this.currentYear() <= assets[_assetId].projectEnd, "project is still ongoing!");
    _;
}
    /*╔═════════════════════════════╗
      ║             END             ║
      ║          MODIFIERS          ║
      ╚═════════════════════════════╝*/
    /**********************************/
constructor(
    address _minter,
    address _initialOwner,
    uint8 _maxAssetsQuantity,
    uint8 _assetType, 
    uint16 _projectStart, 
    uint16 _projectEnd, 
    uint8 _assetclass,
    uint256[] memory _ids,
    uint256[] memory _amount
    ) ERC1155("https://game.example/api/item/{id}.json") GoTokensRoles(msg.sender, _minter) {
   maxAssetsQuantity = _maxAssetsQuantity;

    assets[assetId] = (Asset(_initialOwner, AssetType(_assetType), _projectStart, _projectEnd, AssetClassification(_assetclass), 0, false, _initialOwner));

    assetId++;
    _mintBatch(_initialOwner, _ids, _amount, "mint");
    setApprovalToTransferAssets(_initialOwner, msg.sender, true);

}

    /*╔══════════════════════════════╗
      ║       SET FUNCTIONS          ║
      ╚══════════════════════════════╝*/
function setGlobalInfoAboutCurrentFlorest(
    uint32 _woodFlorestMaxPotential,
    string _florestName,
    string _florestRegistration,
    uint16 _plotsQuantityInCurrentFlorest,
    uint32 _maxTokenizationGivenToFlorest,
    string _dataRoomLink,
    string _buyOrSellContractLink,
    string _tokenizationContractLink  
) external onlyOwner {
    //checks if maxTokenizationGivenToFlorest isn't greater than 80000 = 80%
    require(_maxTokenizationGivenToFlorest <= 80000, "This florest can't infringe the universal rule");
    woodFlorestMaxPotential = _woodFlorestMaxPotential;
    florestName = _florestName;
    florestRegistration = _florestRegistration;
    plotsQuantityInCurrentFlorest = _plotsQuantityInCurrentFlorest;
    maxTokenizationGivenToFlorest = _maxTokenizationGivenToFlorest;
    dataRoomLink = _dataRoomLink;
    buyOrSellContractLink = _buyOrSellContractLink;
    tokenizationContractLink = _tokenizationContractLink;
}

    /*╔══════════════════════════════╗
      ║     CHECK FUNCTIONS          ║
      ╚══════════════════════════════╝*/
      
function checkOwnership() public view returns(address) {
    return owner();
}
    
function isAssetAvailableForTransfer(uint8 _assetId) internal view returns(bool){
        return assets[_assetId].isCurrentAssetAvailableForTransfer;
}

function hasAssetValuationBeenSet(uint8 _assetId) external view returns(bool){
        return assets[_assetId].AssetValuation == 0;
}

function setMaxQuantityForCurrentCOPF(uint8 _maxAssetsQuantity) 
    onlyRole(MINTER_ROLE)
    external {
        maxAssetsQuantity = _maxAssetsQuantity;
}


function setCurrentYear(uint16 _currentYear) external onlyRole(MINTER_ROLE) {
        currentYear = _currentYear;
}

function setAssetAvailabilityForTransfer(uint8 _assetId, bool _availability) external returns(bool) {
        assets[_assetId].isCurrentAssetAvailableForTransfer = _availability;
        return assets[_assetId].isCurrentAssetAvailableForTransfer;
}

// make the function available for future mints of other asset in the same florest 
function mint(
    _tokenizedPercentage,
    _geographicLocation,
    _assetImage,
    _woodTypeForAsset,
    _assetAge,
    _assetPlantingYear,
    _assetCutYear,
    _assetTokenizationType,
    _soldByTheValueOf,
    _initialOwner,
    _currentTokenOwner,
    _class,
    _AssetValuation,
    _isCurrentAssetAvailableForTransfer,
    uint256[] calldata ids, 
    uint256[] calldata amounts
    )
 onlyRole(MINTER_ROLE) 
 external {
    uint8 _assetId = assetId++;
    require(_assetId <= maxAssetsQuantity, "Sorry, you can't tokenize more assets");
    
    assets[_assetId] = (Asset(_initialOwner, AssetType(_assetType), _projectStart, _projectEnd, AssetClassification(_assetclass), _assetValuation, false, _initialOwner));

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

function setAssetValuation(uint8 _assetId, uint32 _assetValuation) onlyOwner external returns(uint32) {
    assets[_assetId].AssetValuation = _assetValuation;
    return assets[_assetId].AssetValuation;
}

//This function needs to be invoked whenever the TED  transfer has been done
function transferAsset(uint8 _assetId, address _newOwner, uint256 _amount) external {
    require(isAssetAvailableForTransfer(_assetId), "asset is currently not available for transfer");
    address pastOwner = assets[_assetId].tokenOwner;
    setApprovalToTransferAssets(pastOwner, msg.sender, true);
    safeTransferFrom(pastOwner, _newOwner, _assetId, _amount, "transfer");
    assets[_assetId].tokenOwner = _newOwner;
    emit AssetTransferred(_assetId, _newOwner, assets[_assetId].tokenOwner == _newOwner);
}

//function declared to avoid the below compilation error:
//TypeError: Derived contract must override function "supportsInterface". Two or more base classes define function with same name and parameter types.
function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
    return super.supportsInterface(interfaceId);
}

}