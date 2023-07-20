// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC721A } from 'src/ERC721A.sol';
import 'forge-std/Test.sol';

contract ERC721ATest is ERC721A, Test {

    constructor() ERC721A('Test', 'Test'){}

    function testMintSingle() public {
        super._mint(msg.sender, 1, true, 10, 50);
    }

    function testMintMultiple() public {
        super._mint(msg.sender, 6, true, 10, 50);
    }
}
