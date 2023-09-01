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
        super._mint(address(this), 1, false, 10, 1000);     // Mint ID 0

        super._mint(address(user1), 100, true, 10, 100);
        super._mint(address(user1), 1, true, 10, 100);

        user1.__ERC721A__operatorApproval(address(user2));
    }

    function test__ERC721A_Mint_001() public {
        super._mint(msg.sender, 1, true, 10, 100);
    }

    function test__ERC721A_Mint_005() public {
        super._mint(msg.sender, 5, true, 10, 50);
    }

    function test__ERC721A_Mint_010() public {
        super._mint(msg.sender, 10, true, 10, 50);
    }

    function test__ERC721A_Mint_050() public {
        super._mint(msg.sender, 50, true, 10, 50);
    }

    function test__ERC721A_Mint_100() public {
        super._mint(msg.sender, 100, true, 10, 50);
    }

    function test__ERC721A_Transfer_ID_001() public {
        user1.__ERC721A__transferTo(address(user2), 1);
    }

    function test__ERC721A_Transfer_ID_005() public {
        user1.__ERC721A__transferTo(address(user2), 5);
    }

    function test__ERC721A_Transfer_ID_010() public {
        user1.__ERC721A__transferTo(address(user2), 10);
    }
    
    function test__ERC721A_Transfer_ID_050() public {
        user1.__ERC721A__transferTo(address(user2), 50);
    }

    function test__ERC721A_Transfer_ID_100() public {
        user1.__ERC721A__transferTo(address(user2), 100);
    }

    function test__ERC721A_Transfer_Initialized() public {
        user1.__ERC721A__transferTo(address(user2), 101);
    }

    function test__ERC721A_Burn_ID_001() public {
        super._burn(1);
    }

    function test__ERC721A_Burn_ID_005() public {
        super._burn(5);
    }

    function test__ERC721A_Burn_ID_010() public {
        super._burn(10);
    }

    function test__ERC721A_Burn_ID_050() public {
        super._burn(50);
    }

    function test__ERC721A_Burn_ID_100() public {
        super._burn(100);
    }
}
