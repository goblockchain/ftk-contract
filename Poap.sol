// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./GoTokensRoles.sol";
import "./GoTokensRoyalties.sol";

contract GoTokensPOAP is ERC1155Burnable, ERC1155Holder, ReentrancyGuard, GoTokensRoyalties, GoTokensRoles {
    using Strings for uint256;
    string private _name = "";
    string private _symbol = "";
    // address public ownerContractFirstDistribution;
    string public baseTokenURI;
    uint256[] public nftsIDs;
    bool public openToSales = true;
    
    mapping(uint256 => uint256) public maxSupplyPerToken;
    mapping(uint256 => uint256) public totalMintedPerToken;

    event ItemMinted(address indexed to, uint256 tokenId, uint256 amount);
    event DefinedMaxSupplyPerToken();

    constructor(
        string memory _newName,
        string memory _newSymbol,
        string memory _baseTokenURI,
        address _admin,
        address _mintable,
        uint256[] memory _ids,
        uint256[] memory _amounts
        ) 
        ERC1155(_baseTokenURI)
        GoTokensRoles(_admin, _mintable)
        {
        baseTokenURI = _baseTokenURI;
        _name = _newName;
        _symbol = _newSymbol;
        _setMaxSupplyPerToken(_ids, _amounts);
    }

    modifier tokenOwnerOnly(uint256 tokenId) {
        require(this.balanceOf(msg.sender, tokenId) != 0, "You don't have any token");
        _;
    }

    modifier tokenExist(uint256 tokenId) {
        require(exists(tokenId), "Token don't exist");  
        _;
    }

    modifier whenNotPaused() {
        require(openToSales, "The contract is closed");  
        _;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function setNameAndSymbol(
        string memory _newName,
        string memory _newSymbol
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _name = _newName;
        _symbol = _newSymbol;
    }

    function setSalesStatus(bool status) public onlyRole(DEFAULT_ADMIN_ROLE) {
        openToSales = status;
    }

    /*
    * Defined the Max Supply per token to be used in lazy mint
    */
    function setMaxSupplyPerToken(uint256[] memory ids, uint256[] memory amounts) public
        whenNotPaused
        onlyRole(DEFAULT_ADMIN_ROLE)
        whenNotPaused
        nonReentrant {
        
        _setMaxSupplyPerToken(ids, amounts);
    }

    function _setMaxSupplyPerToken(uint256[] memory ids, uint256[] memory amounts) internal {
        require(ids.length == amounts.length, "Ids and amount is diferent");
        uint256 len = ids.length;
        for(uint256 i; i < len; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            maxSupplyPerToken[id] = amount;
            nftsIDs.push(ids[i]);
        }
        setApprovalForAll(address(this), true);
        emit DefinedMaxSupplyPerToken();
    }    

    /* Lazy minting */
    function mint(address to, uint256 tokenId, uint256 amount) public 
        onlyRole(MINTER_ROLE)
        whenNotPaused 
        nonReentrant {
        require(
            maxSupplyPerToken[tokenId] != 0,
            "No max supply set for this token id"
        );
        require(
            totalMintedPerToken[tokenId] + amount <= maxSupplyPerToken[tokenId],
            "The total amount of this token id bigger then the max supply"
        );
        totalMintedPerToken[tokenId] = totalMintedPerToken[tokenId] + amount;
        _mint(to, tokenId, amount, "mint");
        setApprovalForMarketPlace(to, _msgSender(), true);
        emit ItemMinted(to, tokenId, amount);
    } 

    // EIP2981 standard Interface return. Adds to ERC721 and ERC165 Interface returns.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, ERC1155, ERC1155Receiver, AccessControl)
        returns (bool)
    {
        return
        ERC1155.supportsInterface(interfaceId) || 
        AccessControl.supportsInterface(interfaceId) ||
        interfaceId == type(IERC2981).interfaceId;
    }

    // set a new URI if necessary 
    // newuri is necessary this partner = "ipfs://{hash}/{id}", 
    // ex: "ipfs://bafybeigarlunxuwrv2gjokz5iqp6esxpebrsoa267shetb4w6p2f6zxhq4/{id}"
    function setURI(string memory newuri) external whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) {
        baseTokenURI = newuri;
        _setURI(baseTokenURI);
    }

    /**
    * Return the token URI concatened with the id
    */
    function uri(uint256 _tokenId)
        public
        view
        tokenExist(_tokenId) 
        override
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(baseTokenURI, Strings.toString(_tokenId), ".json")
            );
    }

    /**
     * Set goBlockchain to realize transaction to user in second market
     */
    function setApprovalForMarketPlace(address holderAccount, address operator, bool approved)
        public whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE)
    {
        //The setApprovalForAll() function is used to assign or revoke the full approval rights to the given operator.
        //The caller of the function (msg.sender) is the approver.
        _setApprovalForAll(holderAccount, operator, approved);
    } 

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    } 

    /**
     * Set goBlockchain to realize transaction to user in second market
     */
    function setTokenRoyaltyByAdmin(address newAddress, uint256 percentage)
        public whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE)
    {
        setTokenRoyalty(newAddress, percentage);
    }
}
