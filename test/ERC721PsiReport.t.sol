// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC721Psi } from 'src/ERC721Psi.sol';
import { User } from './User.sol';
import 'forge-std/Test.sol';

contract ERC721PsiTest is ERC721Psi, Test {

    User immutable user1;
    User immutable user2;
    User immutable user3;
    uint256 oneDay = 86400;

    constructor() ERC721Psi('Test', 'Test', oneDay) {
        user1 = new User(address(this));    // User with 10001 tokens
        user2 = new User(address(this));    // User with 1 token
        user3 = new User(address(this));    // User with 0 tokens
    }

    function setUp() public {
        super._mint(address(this), 1, block.timestamp, false, 10, 100);         // Initialize _currentIndex and _batchHead bitmap
        super._burn(0);                                                         // Initialize _burnedToken bitmap
        super._mint(address(user1), 10001, block.timestamp, true, 10, 100);     // Initialize user1 balance
        super._mint(address(user2), 1, block.timestamp, true, 10, 1000);        // Initialize user2 balance
    }

    // _addressData of user3 is uninitialized, cost of a SSTORE(1) is accrued, instead of a SSTORE(2)
    function test__ERC721Psi_Mint_00001() public {
        super._mint(address(user3), 1, block.timestamp, false, 10, 50);
    }

    function test__ERC721Psi_Mint_00002() public {
        super._mint(address(user3), 2, block.timestamp, false, 10, 50);
    }

    function test__ERC721Psi_Mint_00003() public {
        super._mint(address(user3), 3, block.timestamp, false, 10, 50);
    }

    function test__ERC721Psi_Mint_00005() public {
        super._mint(address(user3), 5, block.timestamp, true, 10, 50);
    }

    function test__ERC721Psi_Mint_00010() public {
        super._mint(address(user3), 10, block.timestamp, true, 10, 50);
    }

    function test__ERC721Psi_Mint_00020() public {
        super._mint(address(user3), 20, block.timestamp, false, 10, 50);
    }

    function test__ERC721Psi_Mint_00100() public {
        super._mint(address(user3), 100, block.timestamp, true, 10, 50);
    }

    function test__ERC721Psi_Mint_01000() public {
        super._mint(address(user3), 1000, block.timestamp, true, 10, 50);
    }

    function test__ERC721Psi_Mint_10000() public {
        super._mint(address(user3), 10000, block.timestamp, true, 10, 50);
    }

    // Specific mint scenario
    function test__ERC721Psi_Mint_NonZero_1() public {
        super._mint(address(user1), 1, block.timestamp, true, 10, 50);
    }

    function test__ERC721Psi_Transfer_Distance_00000() public {
        user1.__ERC721Psi__transferTo(address(user3), 1);
    }

    function test__ERC721Psi_Transfer_Distance_00001() public {
        user1.__ERC721Psi__transferTo(address(user3), 2);
    }

    function test__ERC721Psi_Transfer_Distance_00002() public {
        user1.__ERC721Psi__transferTo(address(user3), 3);
    }

    function test__ERC721Psi_Transfer_Distance_00003() public {
        user1.__ERC721Psi__transferTo(address(user3), 4);
    }

    function test__ERC721Psi_Transfer_Distance_00005() public {
        user1.__ERC721Psi__transferTo(address(user3), 6);
    }

    function test__ERC721Psi_Transfer_Distance_00010() public {
        user1.__ERC721Psi__transferTo(address(user3), 11);
    }
    
    function test__ERC721Psi_Transfer_Distance_00020() public {
        user1.__ERC721Psi__transferTo(address(user3), 21);
    }

    function test__ERC721Psi_Transfer_Distance_00100() public {
        user1.__ERC721Psi__transferTo(address(user3), 101);
    }

    function test__ERC721Psi_Transfer_Distance_01000() public {
        user1.__ERC721Psi__transferTo(address(user3), 1001);
    }

    function test__ERC721Psi_Transfer_Distance_10000() public {
        user1.__ERC721Psi__transferTo(address(user3), 10001);
    }

    // Specific transfer scenarios
    function test__ERC721Psi_Transfer_ToNonZeroBalance_Distance0() public {
        user1.__ERC721Psi__transferTo(address(user2), 1);
    }

    function test__ERC721Psi_Burn_Distance_00000() public {
        super._burn(1);
    }

    function test__ERC721Psi_Burn_Distance_00001() public {
        super._burn(2);
    }

    function test__ERC721Psi_Burn_Distance_00002() public {
        super._burn(3);
    }

    function test__ERC721Psi_Burn_Distance_00003() public {
        super._burn(4);
    }

    function test__ERC721Psi_Burn_Distance_00005() public {
        super._burn(6);
    }

    function test__ERC721Psi_Burn_Distance_00010() public {
        super._burn(11);
    }

    function test__ERC721Psi_Burn_Distance_00020() public {
        super._burn(21);
    }

    function test__ERC721Psi_Burn_Distance_00100() public {
        super._burn(101);
    }

    function test__ERC721Psi_Burn_Distance_01000() public {
        super._burn(1001);
    }

    function test__ERC721Psi_Burn_Distance_10000() public {
        super._burn(10001);
    }
}