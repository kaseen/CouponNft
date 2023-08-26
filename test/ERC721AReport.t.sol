// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC721A } from 'src/ERC721A.sol';
import { User } from './User.sol';
import 'forge-std/Test.sol';

contract ERC721ATest is ERC721A, Test {

    constructor() ERC721A('Test', 'Test'){}

    User public user1;
    User public user2;

    function setUp() public {
        user1 = new User(address(this));
        user2 = new User(address(this));

        // Setup
        super._mint(address(user1), 5, false, 10, 100);
        super._mint(address(user2), 1, false, 10, 100);

        user1.__ERC721A__operatorApproval(address(user2));
        user2.__ERC721A__operatorApproval(address(user1));
    }

    function test__ERC721A_Mint_1() public {
        super._mint(msg.sender, 1, false, 10, 100);
    }

    function test__ERC721A_Mint_5() public {
        super._mint(msg.sender, 5, true, 10, 50);
    }

    function test__ERC721A_Mint_10() public {
        super._mint(msg.sender, 10, true, 10, 50);
    }

    function test__ERC721A_Mint_50() public {
        super._mint(msg.sender, 50, true, 10, 50);
    }

    function test__ERC721A_Mint_100() public {
        super._mint(msg.sender, 100, true, 10, 50);
    }

    function testTransferInitialized() public {
        user2.__ERC721A__transferTo(address(user1), 5);
    }

    function testTransferNotInitialized() public {
        user1.__ERC721A__transferTo(address(user2), 1);
    }

    function testBurnInitialized() public {
        super._burn(2);
    }

    function testBurnNotInitialized() public {
        super._burn(0);
    }
}
