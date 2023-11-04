// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC721 } from 'src/ERC721.sol';
import { User } from './User.sol';
import 'forge-std/Test.sol';

contract ERC721Test is ERC721, Test {

    User public user1;
    User public user2;
    User public user3;
    uint256 oneDay = 86400;

    constructor() ERC721('Test', 'Test', oneDay) {}

    function mintMultipleForUser(address user, uint256 amount) private {
        for(uint256 i; i < amount; ++i)
            super._mint(user, block.timestamp, true, 10, 50);
    }

    function setUp() public {
        user1 = new User(address(this));
        user2 = new User(address(this));
        user3 = new User(address(this));

        // Setup
        super._mint(address(user1), block.timestamp, true, 10, 100);
        super._mint(address(user1), block.timestamp, true, 10, 100);
        super._mint(address(user2), block.timestamp, true, 10, 100);
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

    function test__ERC721_Transfer_Scenario1_SSTORE3_SSTORE2() public {
        user2.__ERC721__transferTo(address(user1), 2);
    }

    function test__ERC721_Transfer_Scenario2_SSTORE2_SSTORE2() public {
        user1.__ERC721__transferTo(address(user2), 0);
    }

    function test__ERC721_Transfer_Scenario3_SSTORE3_SSTORE1() public {
        user2.__ERC721__transferTo(address(user3), 2);
    }

    function test__ERC721_Transfer_Scenario4_SSTORE2_SSTORE1() public {
        user1.__ERC721__transferTo(address(user3), 0);
    }

    function test__ERC721_Burn_Scenario1() public {
        super._burn(2);
    }

    function test__ERC721_Burn_Scenario2() public {
        super._burn(1);
    }
}