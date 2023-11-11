// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { NeonMarket } from './NeonMarket.sol';
import { ERC721 } from 'src/ERC721.sol';
import { ERC721A } from 'src/ERC721A.sol';
import { ERC721Psi } from 'src/ERC721Psi.sol';
import { Test } from 'forge-std/Test.sol';

contract DeploymentsTest is Test {

    function test__deployNeonMarket() public {
        new NeonMarket();
    }

    function test__deployERC721() public {
        new ERC721('Test', 'Test', 86400);
    }

    function test__deployERC721A() public {
        new ERC721A('Test', 'Test', 86400);
    }

    function test__deployERC721Psi() public {
        new ERC721Psi('Test', 'Test', 86400);
    }
}