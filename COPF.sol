// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//imports
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/GoTokensRole.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

//ERC721URIStorage already inherits functions from ERC721
contract COPF is Ownable, GoTokensRoles, ERC721URIStorage {


//Keeps track of which asset of the florest is currently being minted
//max value of above declared florestValuation = 4.294.967.295 = 4 bilhões, 294 milhões, etc.
uint8 public assetId = 0;

mapping (uint8 => string) private _tokenURIs;
string private _baseURIextended;

bool isCurrentAssetAvailableForTransfer = false;

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
    string tokenURI;
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
    require(this.getCurrentYear() <= assets[_assetId].projectEnd, "project is still ongoing!");
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
    uint8 _assetType, 
    uint16 _projectStart, 
    uint16 _projectEnd, 
    uint8 _assetclass,
    string memory _baseURI,
    string memory tokenURI_
    ) ERC721("Certificate of PlantedFlorests", "COPF") GoTokensRoles(msg.sender, _minter) {
   
    assets.push(Asset(_initialOwner, AssetType(_assetType), _projectStart, _projectEnd, AssetClassification(_assetclass), 0, false, _initialOwner, tokenURI_));
    _baseURIextended = _baseURI;

    //first asset minted
    _mint(_initialOwner, 0);
    setApprovalToTransferAssets(_initialOwner, msg.sender, true);
    _setTokenURI(0, tokenURI_);

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

//https://ethereum.stackexchange.com/questions/132708/how-to-get-current-year-from-timestamp-solidity
function getCurrentYear() external view returns(uint) {
    uint currentYear = (block.timestamp / 31557600) + 1970;
    return currentYear;
}

    /*╔══════════════════════════════╗
      ║     OTHER FUNCTIONS          ║
      ╚══════════════════════════════╝*/

function setBaseURI(string memory baseURI_) external onlyOwner() {
            _baseURIextended = baseURI_;
}


//Setting the tokenURI for a specific assetId, we only 
function setTokenURI(uint8 tokenId, string memory _tokenURI) external virtual {
        super._setTokenURI(tokenId, _tokenURI);
}

function _baseURI() internal view virtual override returns (string memory) {
            return _baseURIextended;
}

function setAssetAvailabilityForTransfer(uint8 _assetId, bool _availability) external returns(bool) {
        assets[_assetId].isCurrentAssetAvailableForTransfer = _availability;
        return assets[_assetId].isCurrentAssetAvailableForTransfer;
}

// make the function available for future mints of other asset in the same florest 
function mint(address _initialOwner, AssetType _assetType, uint16 _projectStart, uint16 _projectEnd, AssetClassification _assetclass, uint32 _assetValuation, string memory tokenURI_)
 onlyRole(MINTER_ROLE)
 external {
    uint8 _assetId = assetId++;
    
    assets.push(Asset(_initialOwner, AssetType(_assetType), _projectStart, _projectEnd, AssetClassification(_assetclass), _assetValuation, false, _initialOwner, tokenURI_));

    _mint(_initialOwner, _assetId);
    
    setApprovalToTransferAssets(_initialOwner, msg.sender, true);
    _setTokenURI(_assetId, tokenURI_);
}

function burn(uint8 _assetId, address _initialOwner) 
    isAccountInitialAssetOwner(_assetId, _initialOwner) 
    hasProjectEnded(_assetId)
    external
{
    _burn(_assetId);
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
function transferAsset(uint8 _assetId, address _newOwner) external {
    require(isAssetAvailableForTransfer(_assetId), "asset is currently not available for transfer");
    address pastOwner = assets[_assetId].tokenOwner;
    setApprovalToTransferAssets(pastOwner, msg.sender, true);
    safeTransferFrom(pastOwner, _newOwner, _assetId);
    assets[_assetId].tokenOwner = _newOwner;
    emit AssetTransferred(_assetId, _newOwner, assets[_assetId].tokenOwner == _newOwner);
}

//function declared to avoid the below compilation error:
//TypeError: Derived contract must override function "supportsInterface". Two or more base classes define function with same name and parameter types.
function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
    return super.supportsInterface(interfaceId);
}

}