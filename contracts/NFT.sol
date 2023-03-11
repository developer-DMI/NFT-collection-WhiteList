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

    bool public onlyWhitelisted = true;
    address[] public whitelistedAddresses;
    uint256 maxMintAmount = 15;
    uint256 maxSupply = 75;
    string public baseExtension = ".json";
    string public baseURI;

    Counters.Counter private _tokenIdCounter;

    constructor(
        address[] memory _users,
        string memory _initBaseURI
    ) ERC721("NFT", "NFT") {
        setBaseURI(_initBaseURI);
        whitelistedAddresses = _users;
        mint(15);
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function safeMintWL(address to, string memory uri) public {
        require(isWhitelisted(msg.sender), "user is not whitelisted");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function mint(uint256 _mintAmount) public payable onlyOwner {
        uint256 supply = totalSupply();
        require(_mintAmount > 0, "need to mint at least 1 NFT");
        require(
            _mintAmount <= maxMintAmount,
            "max mint amount per session exceeded"
        );
        require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

        // if (msg.sender != owner()) {
        //     if (onlyWhitelisted == true) {
        //         require(whitelisted[msg.sender], "user is not whitelisted");
        //         uint256 ownerMintedCount = addressMintedBalance[msg.sender];
        //         require(
        //             ownerMintedCount + _mintAmount <= nftPerAddressLimit,
        //             "max NFT per address exceeded"
        //         );
        //     }

        //     require(msg.value >= cost * _mintAmount, "insufficient funds");
        // }

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

    // function tokenURI(
    //     uint256 tokenId
    // ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
    //     return super.tokenURI(tokenId);
    // }

    function whitelistUsers(address[] calldata _users) public onlyOwner {
        delete whitelistedAddresses;
        whitelistedAddresses = _users;
    }

    function setOnlyWhitelisted(bool _state) public onlyOwner {
        onlyWhitelisted = _state;
    }

    function isWhitelisted(address _user) public view returns (bool) {
        for (uint i = 0; i < whitelistedAddresses.length; i++) {
            if (whitelistedAddresses[i] == _user) {
                return true;
            }
        }
        return false;
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter.current();
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
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
