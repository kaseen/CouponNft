// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC721 } from 'src/ERC721.sol';
import { ERC721A } from 'src/ERC721A.sol';

contract User {

    address testContractAddress;

    constructor(address addr) {
        testContractAddress = addr;
    }

    function __ERC721__transferTo(address to, uint256 tokenId) public {
        ERC721(testContractAddress).transferFrom(address(this), to, tokenId);
    }

    function __ERC721__operatorApproval(address to) public {
        ERC721(testContractAddress).setApprovalForAll(to, true);
    }

    function __ERC721A__transferTo(address to, uint256 tokenId) public {
        ERC721A(testContractAddress).transferFrom(address(this), to, tokenId);
    }

    function __ERC721A__operatorApproval(address to) public {
        ERC721A(testContractAddress).setApprovalForAll(to, true);
    }
}