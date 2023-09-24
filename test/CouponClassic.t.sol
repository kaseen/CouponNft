// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { CouponClassic } from 'src/CouponClassic.sol';
import { User } from './User.sol';
import 'forge-std/Test.sol';

contract CouponClassicTest is Test {

    uint256 public volume;
    mapping(uint256 => address) public coupons;
    User public user1;
    User public user2;

    function mintMultipleForUser(address user, uint256 amount) private {
        for(uint256 i; i < amount; ++i){
            coupons[volume] = address(new CouponClassic(volume, user, 2 * block.timestamp, false, 10, 100));
            volume++;
        }   
    }

    function setUp() public {
        user1 = new User(address(this));
        user2 = new User(address(this));

        mintMultipleForUser(address(user1), 1);     // Mint ID 0
        mintMultipleForUser(address(user1), 10000);
    }

    function test__Classic_Mint_00001() public {
        mintMultipleForUser(msg.sender, 1);
    }

    function test__Classic_Mint_00005() public {
        mintMultipleForUser(msg.sender, 5);
    }

    function test__Classic_Mint_00010() public {
        mintMultipleForUser(msg.sender, 10);
    }

    function test__Classic_Mint_00050() public {
        mintMultipleForUser(msg.sender, 50);
    }

    function test__Classic_Mint_00100() public {
        mintMultipleForUser(msg.sender, 100);
    }

    function test__Classic_Mint_00200() public {
        mintMultipleForUser(msg.sender, 200);
    }

    function test__Classic_Mint_00500() public {
        mintMultipleForUser(msg.sender, 500);
    }

    function test__Classic_Mint_01000() public {
        mintMultipleForUser(msg.sender, 1000);
    }

    function test__Classic_Mint_02000() public {
        mintMultipleForUser(msg.sender, 2000);
    }

    function test__Classic_Mint_05000() public {
        mintMultipleForUser(msg.sender, 5000);
    }

    function test__Classic_Mint_10000() public {
        mintMultipleForUser(msg.sender, 10000);
    }

    function test__Classic_Transfer_ID_00001() public {
        user1.__Classic__transferTo(address(user2), coupons[1]);
    }

    function test__Classic_Transfer_ID_00005() public {
        user1.__Classic__transferTo(address(user2), coupons[5]);
    }

    function test__Classic_Transfer_ID_00010() public {
        user1.__Classic__transferTo(address(user2), coupons[10]);
    }
    
    function test__Classic_Transfer_ID_00050() public {
        user1.__Classic__transferTo(address(user2), coupons[50]);
    }

    function test__Classic_Transfer_ID_00100() public {
        user1.__Classic__transferTo(address(user2), coupons[100]);
    }

    function test__Classic_Transfer_ID_00200() public {
        user1.__Classic__transferTo(address(user2), coupons[200]);
    }

    function test__Classic_Transfer_ID_00500() public {
        user1.__Classic__transferTo(address(user2), coupons[500]);
    }

    function test__Classic_Transfer_ID_01000() public {
        user1.__Classic__transferTo(address(user2), coupons[1000]);
    }

    function test__Classic_Transfer_ID_02000() public {
        user1.__Classic__transferTo(address(user2), coupons[2000]);
    }

    function test__Classic_Transfer_ID_05000() public {
        user1.__Classic__transferTo(address(user2), coupons[5000]);
    }

    function test__Classic_Transfer_ID_10000() public {
        user1.__Classic__transferTo(address(user2), coupons[10000]);
    }

    function test__Classic_Burn_ID_00001() public {
        user1.__Classic__burn(coupons[1]);
    }

    function test__Classic_Burn_ID_00005() public {
        user1.__Classic__burn(coupons[5]);
    }

    function test__Classic_Burn_ID_00010() public {
        user1.__Classic__burn(coupons[10]);
    }

    function test__Classic_Burn_ID_00050() public {
        user1.__Classic__burn(coupons[50]);
    }

    function test__Classic_Burn_ID_00100() public {
        user1.__Classic__burn(coupons[100]);
    }

    function test__Classic_Burn_ID_00200() public {
        user1.__Classic__burn(coupons[200]);
    }

    function test__Classic_Burn_ID_00500() public {
        user1.__Classic__burn(coupons[500]);
    }

    function test__Classic_Burn_ID_01000() public {
        user1.__Classic__burn(coupons[1000]);
    }

    function test__Classic_Burn_ID_02000() public {
        user1.__Classic__burn(coupons[2000]);
    }

    function test__Classic_Burn_ID_05000() public {
        user1.__Classic__burn(coupons[5000]);
    }

    function test__Classic_Burn_ID_10000() public {
        user1.__Classic__burn(coupons[10000]);
    }
}