// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC721A } from 'src/ERC721A.sol';
import { User } from './User.sol';
import 'forge-std/Test.sol';
import 'forge-std/console.sol';

contract ERC721ATest is ERC721A, Test {

    constructor() ERC721A('Test', 'Test'){}

    User public user1;
    User public user2;

    function setUp() public {
        user1 = new User(address(this));
        user2 = new User(address(this));

        // Setup
        super._mint(address(user1), 2, false, 10, 100);
        super._mint(address(user2), 1, false, 10, 100);

        user1.__ERC721A__operatorApproval(address(user2));
        user2.__ERC721A__operatorApproval(address(user1));
    }

    // TODO: relationship between minting multiple and transfering (sstore cost)

    function testMintSingle() public {
        super._mint(msg.sender, 1, true, 10, 50);
    }

    function testMintMultiple() public {
        super._mint(msg.sender, 6, true, 10, 50);
    }

    function testTransferInitialized() public {
        user2.__ERC721A__transferTo(address(user1), 2);
    }

    function testTransferNotInitialized() public {
        user1.__ERC721A__transferTo(address(user2), 0);
    }

    function testBurnInitialized() public {
        super._burn(2);
    }

    function testBurnNotInitialized() public {
        super._burn(0);
    }
}
