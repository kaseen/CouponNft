// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC721A } from 'src/ERC721A.sol';

contract User {

    address testContractAddress;

    constructor(address addr) {
        testContractAddress = addr;
    }

    function transferTo(address to, uint256 tokenId) public {
        ERC721A(testContractAddress).transferFrom(address(this), to, tokenId);
    }

    function approveTo(address to, uint256 tokenId) public {
        ERC721A(testContractAddress).approve(to, tokenId);
    }

}