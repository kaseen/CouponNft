// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC721 } from 'src/ERC721.sol';
import { User } from './User.sol';
import 'forge-std/Test.sol';

contract ERC721Test is ERC721, Test {

    constructor() ERC721('Test', 'Test'){}

    User public user1;
    User public user2;

    function setUp() public {
        user1 = new User(address(this));
        user2 = new User(address(this));

        // Setup
        super._mint(address(this), true, 10, 100);      // Mint ID 0
        mintMultipleForUser(address(user1), 100);

        user1.__ERC721__operatorApproval(address(user2));
    }

    function mintMultipleForUser(address user, uint256 amount) private {
        for(uint256 i; i < amount; ++i)
            super._mint(user, true, 10, 50);
    }

    function test__ERC721_Mint_001() public {
        mintMultipleForUser(msg.sender, 1);
    }

    function test__ERC721_Mint_005() public {
        mintMultipleForUser(msg.sender, 5);
    }

    function test__ERC721_Mint_010() public {
        mintMultipleForUser(msg.sender, 10);
    }

    function test__ERC721_Mint_050() public {
        mintMultipleForUser(msg.sender, 50);
    }

    function test__ERC721_Mint_100() public {
        mintMultipleForUser(msg.sender, 100);
    }

    function test__ERC721_Transfer_ID_001() public {
        user1.__ERC721__transferTo(address(user2), 1);
    }

    function test__ERC721_Transfer_ID_005() public {
        user1.__ERC721__transferTo(address(user2), 5);
    }

    function test__ERC721_Transfer_ID_010() public {
        user1.__ERC721__transferTo(address(user2), 10);
    }
    
    function test__ERC721_Transfer_ID_050() public {
        user1.__ERC721__transferTo(address(user2), 50);
    }

    function test__ERC721_Transfer_ID_100() public {
        user1.__ERC721__transferTo(address(user2), 100);
    }

    function test__ERC721_Burn_ID_001() public {
        super._burn(1);
    }

    function test__ERC721_Burn_ID_005() public {
        super._burn(5);
    }

    function test__ERC721_Burn_ID_010() public {
        super._burn(10);
    }

    function test__ERC721_Burn_ID_050() public {
        super._burn(50);
    }

    function test__ERC721_Burn_ID_100() public {
        super._burn(100);
    }
}
