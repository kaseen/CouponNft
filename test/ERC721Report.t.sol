// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC721 } from 'src/ERC721.sol';
import { User } from './User.sol';
import 'forge-std/Test.sol';
import 'forge-std/console.sol';

contract ERC721Test is ERC721, Test {

    constructor() ERC721('Test', 'Test'){}

    User public user1;
    User public user2;

    function setUp() public {
        user1 = new User(address(this));
        user2 = new User(address(this));

        // Setup
        super._mint(address(user1), false, 10, 100);
        super._mint(address(user2), false, 10, 100);

        user1.__ERC721__operatorApproval(address(user2));
        user2.__ERC721__operatorApproval(address(user1));
    }

    function testMintSingle() public {
        super._mint(msg.sender, true, 10, 50);
    }

    function testMintMultiple() public {
        uint256 n = 5;
        for(uint256 i; i < n; ++i)
            super._mint(msg.sender, true, 10, 50);
    }

    function testTransferSingle() public {
        //user1.__ERC721__transferTo(address(user2), 0);
    }
}
