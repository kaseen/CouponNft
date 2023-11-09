// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//import { NeonCoupon } from 'src/NeonCoupon.sol';
import { NeonMarket } from './NeonMarket.sol';
import { User } from './User.sol';
import 'forge-std/Test.sol';

import 'forge-std/console.sol';

contract NeonCouponTest is NeonMarket, Test {

    User immutable user1;
    User immutable user2;

    // For calculation of deployment cost
    function /*test__*/getCreationCode() public view {
        bytes memory result = vm.getCode('out/NeonCoupon.sol/NeonCoupon.json');
        console.logBytes(result);
    }

    function /*test__*/getRuntimeCode() public view {
        bytes memory result = vm.getDeployedCode('out/NeonCoupon.sol/NeonCoupon.json');
        console.logBytes(result);
    }

    constructor() {
        user1 = new User(address(this));
        user2 = new User(address(this));
    }

    function mintMultipleForUser(address user, uint256 amount) private {
        for(uint256 i; i < amount; ++i){
            super.createCoupon(user, block.timestamp, block.timestamp + 100000, 10);
            volume++;
        }
    }

    function setUp() public {
        mintMultipleForUser(address(user1), 1);              // Initialize volume and user1 balance
    }

    function test__Neon_Mint_00001() public {
        mintMultipleForUser(address(user2), 1);
    }

    function test__Neon_Mint_00002() public {
        mintMultipleForUser(address(user2), 2);
    }

    function test__Neon_Mint_00003() public {
        mintMultipleForUser(address(user2), 3);
    }

    function test__Neon_Mint_00005() public {
        mintMultipleForUser(address(user2), 5);
    }

    function test__Neon_Mint_00010() public {
        mintMultipleForUser(address(user2), 10);
    }

    function test__Neon_Mint_00020() public {
        mintMultipleForUser(address(user2), 20);
    }

    function test__Neon_Mint_00100() public {
        mintMultipleForUser(address(user2), 100);
    }

    function test__Neon_Mint_01000() public {
        mintMultipleForUser(address(user2), 1000);
    }

    function test__Neon_Mint_10000() public {
        mintMultipleForUser(address(user2), 10000);
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