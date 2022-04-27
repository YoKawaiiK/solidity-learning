// SPDX-License-Identifier: MIT

pragma solidity >0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTContractMaker is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("NFT Token", "ART") {}

    function mintNft(string memory tokenURI) external onlyOwner returns (uint256) {
        _tokenIds.increment();
        uint256 newNftTokenId = _tokenIds.current();
        _safeMint(msg.sender, newNftTokenId);
        _setTokenURI(newNftTokenId, tokenURI);
        return newNftTokenId;
    }
}
