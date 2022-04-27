// SPDX-License-Identifier: MIT

pragma solidity >0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTContractMaker is ERC721URIStorage, Ownable {
    // addres folder from IPFS
    string private baseURI;

    constructor() ERC721("NFT Token", "ART") {}

    function mintNft(string memory _baseUri, uint256 quantity)
        external
        onlyOwner
        returns (uint256)
    {
        setBaseURI(_baseUri);
        // mint the requested quantity

        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = totalSupply();
            _safeMint(msg.sender, tokenId);
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _baseUri) internal {
        baseURI = _baseUri;
    }
}
