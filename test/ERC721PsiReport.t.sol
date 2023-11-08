// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC721Psi } from 'src/ERC721Psi.sol';
import { User } from './User.sol';
import 'forge-std/Test.sol';

contract ERC721PsiTest is ERC721Psi, Test {

    User public user1;
    User public user2;
    uint256 oneDay = 86400;

    constructor() ERC721Psi('Test', 'Test', oneDay) {}

    function setUp() public {
        user1 = new User(address(this));
        user2 = new User(address(this));

        // Setup 
        super._mint(address(this), 1, block.timestamp, false, 10, 100);         // Initialize _currentIndex and _batchHead bitmap
        super._burn(0);                                                         // Initialize _burnedToken bitmap
        super._mint(address(user1), 10001, block.timestamp, true, 10, 100);

        user1.__ERC721Psi__operatorApproval(address(user2));
    }

    // _addressData is uninitialized, cost of a SSTORE(1) is accrued, instead of a SSTORE(2)
    function test__ERC721Psi_Mint_00001() public {
        super._mint(msg.sender, 1, block.timestamp, false, 10, 50);
    }

    function test__ERC721Psi_Mint_00002() public {
        super._mint(msg.sender, 2, block.timestamp, false, 10, 50);
    }

    function test__ERC721Psi_Mint_00003() public {
        super._mint(msg.sender, 3, block.timestamp, false, 10, 50);
    }

    function test__ERC721Psi_Mint_00005() public {
        super._mint(msg.sender, 5, block.timestamp, true, 10, 50);
    }

    function test__ERC721Psi_Mint_00010() public {
        super._mint(msg.sender, 10, block.timestamp, true, 10, 50);
    }

    function test__ERC721Psi_Mint_00020() public {
        super._mint(msg.sender, 20, block.timestamp, false, 10, 50);
    }

    function test__ERC721Psi_Mint_00100() public {
        super._mint(msg.sender, 100, block.timestamp, true, 10, 50);
    }

    function test__ERC721Psi_Mint_01000() public {
        super._mint(msg.sender, 1000, block.timestamp, true, 10, 50);
    }

    function test__ERC721Psi_Mint_10000() public {
        super._mint(msg.sender, 10000, block.timestamp, true, 10, 50);
    }

    function test__ERC721Psi_Transfer_Distance_00000() public {
        user1.__ERC721Psi__transferTo(address(user2), 1);
    }

    function test__ERC721Psi_Transfer_Distance_00001() public {
        user1.__ERC721Psi__transferTo(address(user2), 2);
    }

    function test__ERC721Psi_Transfer_Distance_00002() public {
        user1.__ERC721Psi__transferTo(address(user2), 3);
    }

    function test__ERC721Psi_Transfer_Distance_00003() public {
        user1.__ERC721Psi__transferTo(address(user2), 4);
    }

    function test__ERC721Psi_Transfer_Distance_00005() public {
        user1.__ERC721Psi__transferTo(address(user2), 6);
    }

    function test__ERC721Psi_Transfer_Distance_00010() public {
        user1.__ERC721Psi__transferTo(address(user2), 11);
    }
    
    function test__ERC721Psi_Transfer_Distance_00020() public {
        user1.__ERC721Psi__transferTo(address(user2), 21);
    }

    function test__ERC721Psi_Transfer_Distance_00100() public {
        user1.__ERC721Psi__transferTo(address(user2), 101);
    }

    function test__ERC721Psi_Transfer_Distance_01000() public {
        user1.__ERC721Psi__transferTo(address(user2), 1001);
    }

    function test__ERC721Psi_Transfer_Distance_10000() public {
        user1.__ERC721Psi__transferTo(address(user2), 10001);
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