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
        super._mint(address(this), 1, false, 10, 1000);         // Bypass warm SSTORE(1) for currentIndex
        super._mint(address(user1), 10000, true, 10, 100);
        super._mint(address(user1), 1, true, 10, 100);

        user1.__ERC721A__operatorApproval(address(user2));
    }

    function test__ERC721A_Mint_00001() public {
        super._mint(msg.sender, 1, true, 10, 100);
    }

    function test__ERC721A_Mint_00005() public {
        super._mint(msg.sender, 5, true, 10, 50);
    }

    function test__ERC721A_Mint_00010() public {
        super._mint(msg.sender, 10, true, 10, 50);
    }

    function test__ERC721A_Mint_00050() public {
        super._mint(msg.sender, 50, true, 10, 50);
    }

    function test__ERC721A_Mint_00100() public {
        super._mint(msg.sender, 100, true, 10, 50);
    }

    function test__ERC721A_Mint_00200() public {
        super._mint(msg.sender, 200, true, 10, 50);
    }

    function test__ERC721A_Mint_00500() public {
        super._mint(msg.sender, 500, true, 10, 50);
    }

    function test__ERC721A_Mint_01000() public {
        super._mint(msg.sender, 1000, true, 10, 50);
    }

    function test__ERC721A_Mint_02000() public {
        super._mint(msg.sender, 2000, true, 10, 50);
    }

    function test__ERC721A_Mint_05000() public {
        super._mint(msg.sender, 5000, true, 10, 50);
    }

    function test__ERC721A_Mint_10000() public {
        super._mint(msg.sender, 10000, true, 10, 50);
    }

    function test__ERC721A_Transfer_ID_00001() public {
        user1.__ERC721A__transferTo(address(user2), 1);
    }

    function test__ERC721A_Transfer_ID_00005() public {
        user1.__ERC721A__transferTo(address(user2), 5);
    }

    function test__ERC721A_Transfer_ID_00010() public {
        user1.__ERC721A__transferTo(address(user2), 10);
    }
    
    function test__ERC721A_Transfer_ID_00050() public {
        user1.__ERC721A__transferTo(address(user2), 50);
    }

    function test__ERC721A_Transfer_ID_00100() public {
        user1.__ERC721A__transferTo(address(user2), 100);
    }

    function test__ERC721A_Transfer_ID_00200() public {
        user1.__ERC721A__transferTo(address(user2), 200);
    }

    function test__ERC721A_Transfer_ID_00500() public {
        user1.__ERC721A__transferTo(address(user2), 500);
    }

    function test__ERC721A_Transfer_ID_01000() public {
        user1.__ERC721A__transferTo(address(user2), 1000);
    }

    function test__ERC721A_Transfer_ID_02000() public {
        user1.__ERC721A__transferTo(address(user2), 2000);
    }

    function test__ERC721A_Transfer_ID_05000() public {
        user1.__ERC721A__transferTo(address(user2), 5000);
    }

    function test__ERC721A_Transfer_ID_10000() public {
        user1.__ERC721A__transferTo(address(user2), 10000);
    }

    function test__ERC721A_Transfer_Initialized() public {
        user1.__ERC721A__transferTo(address(user2), 10001);
    }

    function test__ERC721A_Burn_ID_00001() public {
        super._burn(1);
    }

    function test__ERC721A_Burn_ID_00005() public {
        super._burn(5);
    }

    function test__ERC721A_Burn_ID_00010() public {
        super._burn(10);
    }

    function test__ERC721A_Burn_ID_00050() public {
        super._burn(50);
    }

    function test__ERC721A_Burn_ID_00100() public {
        super._burn(100);
    }

    function test__ERC721A_Burn_ID_00200() public {
        super._burn(200);
    }

    function test__ERC721A_Burn_ID_00500() public {
        super._burn(500);
    }

    function test__ERC721A_Burn_ID_01000() public {
        super._burn(1000);
    }

    function test__ERC721A_Burn_ID_02000() public {
        super._burn(2000);
    }

    function test__ERC721A_Burn_ID_05000() public {
        super._burn(5000);
    }

    function test__ERC721A_Burn_ID_10000() public {
        super._burn(10000);
    }
}
