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
        mintMultipleForUser(address(user1), 10000);

        user1.__ERC721__operatorApproval(address(user2));
    }

    function mintMultipleForUser(address user, uint256 amount) private {
        for(uint256 i; i < amount; ++i)
            super._mint(user, true, 10, 50);
    }

    function test__ERC721_Mint_00001() public {
        mintMultipleForUser(msg.sender, 1);
    }

    function test__ERC721_Mint_00005() public {
        mintMultipleForUser(msg.sender, 5);
    }

    function test__ERC721_Mint_00010() public {
        mintMultipleForUser(msg.sender, 10);
    }

    function test__ERC721_Mint_00050() public {
        mintMultipleForUser(msg.sender, 50);
    }

    function test__ERC721_Mint_00100() public {
        mintMultipleForUser(msg.sender, 100);
    }

    function test__ERC721_Mint_00200() public {
        mintMultipleForUser(msg.sender, 200);
    }

    function test__ERC721_Mint_00500() public {
        mintMultipleForUser(msg.sender, 500);
    }

    function test__ERC721_Mint_01000() public {
        mintMultipleForUser(msg.sender, 1000);
    }

    function test__ERC721_Mint_02000() public {
        mintMultipleForUser(msg.sender, 2000);
    }

    function test__ERC721_Mint_05000() public {
        mintMultipleForUser(msg.sender, 5000);
    }

    function test__ERC721_Mint_10000() public {
        mintMultipleForUser(msg.sender, 10000);
    }

    function test__ERC721_Transfer_ID_00001() public {
        user1.__ERC721__transferTo(address(user2), 1);
    }

    function test__ERC721_Transfer_ID_00005() public {
        user1.__ERC721__transferTo(address(user2), 5);
    }

    function test__ERC721_Transfer_ID_00010() public {
        user1.__ERC721__transferTo(address(user2), 10);
    }
    
    function test__ERC721_Transfer_ID_00050() public {
        user1.__ERC721__transferTo(address(user2), 50);
    }

    function test__ERC721_Transfer_ID_00100() public {
        user1.__ERC721__transferTo(address(user2), 100);
    }

    function test__ERC721_Transfer_ID_00200() public {
        user1.__ERC721__transferTo(address(user2), 200);
    }

    function test__ERC721_Transfer_ID_00500() public {
        user1.__ERC721__transferTo(address(user2), 500);
    }

    function test__ERC721_Transfer_ID_01000() public {
        user1.__ERC721__transferTo(address(user2), 1000);
    }

    function test__ERC721_Transfer_ID_02000() public {
        user1.__ERC721__transferTo(address(user2), 2000);
    }

    function test__ERC721_Transfer_ID_05000() public {
        user1.__ERC721__transferTo(address(user2), 5000);
    }

    function test__ERC721_Transfer_ID_10000() public {
        user1.__ERC721__transferTo(address(user2), 10000);
    }

    function test__ERC721_Burn_ID_00001() public {
        super._burn(1);
    }

    function test__ERC721_Burn_ID_00005() public {
        super._burn(5);
    }

    function test__ERC721_Burn_ID_00010() public {
        super._burn(10);
    }

    function test__ERC721_Burn_ID_00050() public {
        super._burn(50);
    }

    function test__ERC721_Burn_ID_00100() public {
        super._burn(100);
    }

    function test__ERC721_Burn_ID_00200() public {
        super._burn(200);
    }

    function test__ERC721_Burn_ID_00500() public {
        super._burn(500);
    }

    function test__ERC721_Burn_ID_01000() public {
        super._burn(1000);
    }

    function test__ERC721_Burn_ID_02000() public {
        super._burn(2000);
    }

    function test__ERC721_Burn_ID_05000() public {
        super._burn(5000);
    }

    function test__ERC721_Burn_ID_10000() public {
        super._burn(10000);
    }
}
