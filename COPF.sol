// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//imports
//import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract COPF is ERC721 {

// Keeps track of which asset of the florest is currently being minted
uint8 public assetId = 0;
//max value of above declared florestValuation = 4.294.967.295 = 4 bilhões, 294 milhões, etc.


//Bushido mentioned there is an ERC that makes the NFT go back to owner after x time?

bool isCurrentAssetAvailableForTransfer = false;
//uint32 public florestValuation = 0;

enum AssetType {PINUS, EUCALIPTO}
AssetType public assetType;

enum AssetClassification {GREENFIELD, BROWNFIELD}
AssetClassification public assetClassif;

struct Asset {
    //It is the florest's owner when tokenization happened
    address initialOwner;
    AssetType assetType;
    uint16 projectStart;
    uint16 projectEnd;
    AssetClassification assetClassification;
    uint32 AssetValuation;
    //uint32 FlorestValuation;
    bool isCurrentAssetAvailableForTransfer;
    //It is the current token owner after deals have been made
    address tokenOwner;
}

Asset[] public assets;

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
        uint8 tokenId
    );
    event AssetBurned(
        uint8 tokenId,
        bool wasBurned
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

modifier isSenderInitialAssetOwner(uint8 _assetId) {
    require(msg.sender == assets[_assetId].initialOwner, "Only florest's initial owner is allowed for this tx");
    _;
}

modifier hasProjectEnded(uint8 _assetId){
    require(this.getCurrentYear() <= assets[_assetId].projectEnd, "project is still ongoing!");
    _;
}
    /*╔═════════════════════════════╗
      ║             END             ║
      ║          MODIFIERS          ║
      ╚═════════════════════════════╝*/
    /**********************************/
constructor(
    uint8 _assetType, 
    uint16 _projectStart, 
    uint16 _projectEnd, 
    uint8 _assetclass
    ) ERC721("Certificate of PlantedFlorests", "COPF"){
   
    assets.push(Asset(msg.sender, AssetType(_assetType), _projectStart, _projectEnd, AssetClassification(_assetclass), 0, false, msg.sender));

    //first asset minted
    _mint(msg.sender, 0);
}

    /*╔══════════════════════════════╗
      ║     CHECK FUNCTIONS          ║
      ╚══════════════════════════════╝*/
    
function isAssetAvailableForTransfer(uint8 _assetId) internal view returns(bool){
        return assets[_assetId].isCurrentAssetAvailableForTransfer;
}

function hasAssetValuationBeenSet(uint8 _assetId) external view returns(bool){
        return assets[_assetId].AssetValuation == 0;
}

//https://ethereum.stackexchange.com/questions/132708/how-to-get-current-year-from-timestamp-solidity
function getCurrentYear() external view returns(uint) {
    uint currentYear = (block.timestamp / 31557600) + 1970;
    return currentYear;
}

function setAssetAvailabilityForTransfer(uint8 _assetId, bool _availability) external returns(bool) {
        assets[_assetId].isCurrentAssetAvailableForTransfer = _availability;
        return assets[_assetId].isCurrentAssetAvailableForTransfer;
}

// make the function available for future mints of other asset in the same florest 
function mint(AssetType _assetType, uint16 _projectStart, uint16 _projectEnd, AssetClassification _assetclass, uint32 _assetValuation) external {
    uint8 _assetId = assetId++;
    
    assets.push(Asset(msg.sender, AssetType(_assetType), _projectStart, _projectEnd, AssetClassification(_assetclass), _assetValuation, false, msg.sender));

    _mint(msg.sender, _assetId);
    
}

function burn(uint8 _assetId) 
    isSenderInitialAssetOwner(_assetId) 
    hasProjectEnded(_assetId)
    external
{
    _burn(_assetId);
}

function setAssetValuation(uint8 _assetId, uint32 _assetValuation) external returns(uint32) {
    assets[_assetId].AssetValuation = _assetValuation;
    return assets[_assetId].AssetValuation;
}

function transferAsset(uint8 _assetId) external {
    require(isAssetAvailableForTransfer(_assetId), "asset is currently not available for transfer");
}

}