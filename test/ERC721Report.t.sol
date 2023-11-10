// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC721 } from 'src/ERC721.sol';
import { User } from './User.sol';
import 'forge-std/Test.sol';

contract ERC721Test is ERC721, Test {

    User immutable user1;
    User immutable user2;
    User immutable user3;
    uint256 oneDay = 86400;

    constructor() ERC721('Test', 'Test', oneDay) {
        user1 = new User(address(this));    // User with 5 tokens
        user2 = new User(address(this));    // User with 1 token
        user3 = new User(address(this));    // User with 0 tokens
    }

    function mintMultipleForUser(address user, uint256 amount) private {
        for(uint256 i; i < amount; ++i)
            super._mint(user, block.timestamp, true, 10, 50);
    }

    function setUp() public {
        super._mint(address(this), block.timestamp, true, 10, 100);     // Initialize _currentIndex
        mintMultipleForUser(address(user1), 5);                         // Initialize user1 balance
        super._mint(address(user2), block.timestamp, true, 10, 100);    // Initialize user2 balance
    }

    // _balances are uninitialized, cost of a SSTORE(1) is accrued, instead of a SSTORE(2)
    function test__ERC721_Mint_00001() public {
        mintMultipleForUser(address(user3), 1);
    }

    function test__ERC721_Mint_00002() public {
        mintMultipleForUser(address(user3), 2);
    }

    function test__ERC721_Mint_00003() public {
        mintMultipleForUser(address(user3), 3);
    }

    function test__ERC721_Mint_00005() public {
        mintMultipleForUser(address(user3), 5);
    }

    function test__ERC721_Mint_00010() public {
        mintMultipleForUser(address(user3), 10);
    }

    function test__ERC721_Mint_00020() public {
        mintMultipleForUser(address(user3), 20);
    }

    function test__ERC721_Mint_00100() public {
        mintMultipleForUser(address(user3), 100);
    }

    function test__ERC721_Mint_01000() public {
        mintMultipleForUser(address(user3), 1000);
    }

    function test__ERC721_Mint_10000() public {
        mintMultipleForUser(address(user3), 10000);
    }

    // Specific mint scenario
    function test__ERC721_Mint_NonZero_1() public {
        mintMultipleForUser(address(user1), 1);
    }

    function test__ERC721_Transfer_Scenario1_SSTORE3_SSTORE2() public {
        user2.__ERC721__transferTo(address(user1), 6);
    }

    function test__ERC721_Transfer_Scenario2_SSTORE2_SSTORE2() public {
        user1.__ERC721__transferTo(address(user2), 1);
    }

    function test__ERC721_Transfer_Scenario3_SSTORE3_SSTORE1() public {
        user2.__ERC721__transferTo(address(user3), 6);
    }

    function test__ERC721_Transfer_Scenario4_SSTORE2_SSTORE1() public {
        user1.__ERC721__transferTo(address(user3), 1);
    }

    function test__ERC721_Burn_Scenario1() public {
        super._burn(6);
    }

    function test__ERC721_Burn_Scenario2() public {
        super._burn(2);
    }

    // Burning multiple tokens
    function test__ERC721_BurnMultiple_1() public {
        super._burn(1);
    }

    function test__ERC721_BurnMultiple_2() public {
        super._burn(1);
        super._burn(2);
    }

    function test__ERC721_BurnMultiple_3() public {
        super._burn(1);
        super._burn(2);
        super._burn(3);
    }

    function test__ERC721_BurnMultiple_4() public {
        super._burn(1);
        super._burn(2);
        super._burn(3);
        super._burn(4);
    }

    function test__ERC721_BurnMultiple_5() public {
        super._burn(1);
        super._burn(2);
        super._burn(3);
        super._burn(4);
        super._burn(5);
    }
}