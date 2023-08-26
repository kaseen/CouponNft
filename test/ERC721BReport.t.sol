// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC721B } from 'src/ERC721B.sol';
import { User } from './User.sol';
import 'forge-std/Test.sol';

contract ERC721Test is ERC721B, Test {

    constructor() ERC721B('Test', 'Test'){}

    User public user1;
    User public user2;

    function setUp() public {
        user1 = new User(address(this));
        user2 = new User(address(this));

        // Setup
        super._mint(address(user1), 5, false, 10, 100);
        super._mint(address(user2), 5, false, 10, 100);
    }

    function test__ERC721B_Mint_1() public {
        super._mint(msg.sender, 1, false, 10, 100);
    }

    function test__ERC721B_Mint_5() public {
        super._mint(msg.sender, 5, true, 10, 50);
    }

    function test__ERC721B_Mint_10() public {
        super._mint(msg.sender, 10, true, 10, 50);
    }

    function test__ERC721B_Mint_50() public {
        super._mint(msg.sender, 50, true, 10, 50);
    }

    function test__ERC721B_Mint_100() public {
        super._mint(msg.sender, 100, true, 10, 50);
    }
}
