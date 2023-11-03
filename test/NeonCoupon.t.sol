// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//import { NeonCoupon } from 'src/NeonCoupon.sol';
import { NeonMarket } from './NeonMarket.sol';
import { User } from './User.sol';
import 'forge-std/Test.sol';

import 'forge-std/console.sol';

contract NeonCouponTest is NeonMarket, Test {

    User public user1;
    User public user2;

    // For calculation of deployment cost
    function /*test__*/getCreationCode() public view {
        bytes memory result = vm.getCode('out/NeonCoupon.sol/NeonCoupon.json');
        console.logBytes(result);
    }

    function /*test__*/getRuntimeCode() public view {
        bytes memory result = vm.getDeployedCode('out/NeonCoupon.sol/NeonCoupon.json');
        console.logBytes(result);
    }

    function mintMultipleForUser(address user, uint256 amount) private {
        for(uint256 i; i < amount; ++i){
            super.createCoupon(user, block.timestamp, block.timestamp + 100000, 10);
            volume++;
        }
    }

    function setUp() public {
        user1 = new User(address(this));
        user2 = new User(address(this));

        mintMultipleForUser(address(user1), 1);              // Bypass cold SSTORE(1) for ID 0
    }

    function test__Neon_Mint_00001() public {
        mintMultipleForUser(msg.sender, 1);
    }

    function test__Neon_Mint_00005() public {
        mintMultipleForUser(msg.sender, 5);
    }

    function test__Neon_Mint_00010() public {
        mintMultipleForUser(msg.sender, 10);
    }

    function test__Neon_Mint_00050() public {
        mintMultipleForUser(msg.sender, 50);
    }

    function test__Neon_Mint_00100() public {
        mintMultipleForUser(msg.sender, 100);
    }

    function test__Neon_Mint_00200() public {
        mintMultipleForUser(msg.sender, 200);
    }

    function test__Neon_Mint_00500() public {
        mintMultipleForUser(msg.sender, 500);
    }

    function test__Neon_Mint_01000() public {
        mintMultipleForUser(msg.sender, 1000);
    }

    function test__Neon_Mint_02000() public {
        mintMultipleForUser(msg.sender, 2000);
    }

    function test__Neon_Mint_05000() public {
        mintMultipleForUser(msg.sender, 5000);
    }

    function test__Neon_Mint_10000() public {
        mintMultipleForUser(msg.sender, 10000);
    }

    function test__Neon_Transfer() public {
        address couponAddress = super.getCouponAddrByID(1);
        user1.__NeonCoupon__transferTo(address(user2), couponAddress);
    }

    function test__Neon_Burn() public {
        address couponAddress = getCouponAddrByID(1);
        user1.__NeonCoupon__burn(couponAddress);
    }
}