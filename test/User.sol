// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { CouponClassic } from 'src/CouponClassic.sol';
import { ERC721 } from 'src/ERC721.sol';
import { ERC721A } from 'src/ERC721A.sol';
import { ERC721Psi } from 'src/ERC721Psi.sol';

contract User {

    address testContractAddress;

    constructor(address addr) {
        testContractAddress = addr;
    }

    // For testing CouponClassic
    function __Classic__transferTo(address to, address couponAddress) public {
        CouponClassic(couponAddress).changeOwnerTo(to);
    }

    function __Classic__burn(address couponAddress) public {
        CouponClassic(couponAddress).redeem();
    }

    // For testing ERC721
    function __ERC721__transferTo(address to, uint256 tokenId) public {
        ERC721(testContractAddress).transferFrom(address(this), to, tokenId);
    }

    function __ERC721__operatorApproval(address to) public {
        ERC721(testContractAddress).setApprovalForAll(to, true);
    }

    // For testing ERC721A
    function __ERC721A__transferTo(address to, uint256 tokenId) public {
        ERC721A(testContractAddress).transferFrom(address(this), to, tokenId);
    }

    function __ERC721A__operatorApproval(address to) public {
        ERC721A(testContractAddress).setApprovalForAll(to, true);
    }

    // For testing ERC721Psi
    function __ERC721Psi__transferTo(address to, uint256 tokenId) public {
        ERC721Psi(testContractAddress).transferFrom(address(this), to, tokenId);
    }

    function __ERC721Psi__operatorApproval(address to) public {
        ERC721Psi(testContractAddress).setApprovalForAll(to, true);
    }
}