// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    address[] public whitelistedAddresses;
    uint256 maxMintAmount = 10;
    uint256 maxSupply = 75;
    string public baseExtension = ".json";
    string public baseURI = "";

    Counters.Counter public _tokenIdCounter;

    modifier mintCompliance(uint256 _mintAmount) {
        require(
            _mintAmount > 0 && _mintAmount <= maxMintAmount,
            "Invalid mint amount!"
        );
        require(
            _tokenIdCounter.current() + _mintAmount <= maxSupply + 1,
            "Max supply exceeded!"
        );
        _;
    }

    constructor(
        address[] memory _users,
        string memory _initBaseURI
    ) ERC721("RUN! By Axel Mishomaro", "RNU") {
        _tokenIdCounter.increment();
        baseURI = _initBaseURI;
        whitelistedAddresses = _users;
        mint(10);
        mint(5);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    // Mint one token for Owner

    function safeMint(address to) public onlyOwner mintCompliance(1) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    // Mint one token for WL

    function safeMintWL() public mintCompliance(1) {
        require(isWhitelisted(msg.sender), "user is not whitelisted");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    // Mass mint

    function mint(
        uint256 _mintAmount
    ) public payable mintCompliance(_mintAmount) {
        if (msg.sender != owner()) {
            require(isWhitelisted(msg.sender), "user is not whitelisted");          
        }
        for (uint256 i = 1; i <= _mintAmount; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(msg.sender, tokenId);
        }
    }

    // The following functions are overrides required by Solidity.

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    // Set new white list

    function setWhiteListUsers(address[] calldata _users) public onlyOwner {
        delete whitelistedAddresses;
        whitelistedAddresses = _users;
    }

    // Push new addres to white list

    function pushNewAddressToWhiteList(address _user) public onlyOwner {
        whitelistedAddresses.push(_user);
    }

    // Check, does user in white list?

    function isWhitelisted(address _user) public view returns (bool) {
        for (uint i = 0; i < whitelistedAddresses.length; i++) {
            if (whitelistedAddresses[i] == _user) {
                return true;
            }
        }
        return false;
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }
}
