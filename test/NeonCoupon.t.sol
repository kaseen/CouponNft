// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { NeonMarket } from './NeonMarket.sol';
import { User } from './User.sol';
import { Test, console } from 'forge-std/Test.sol';

contract NeonCouponTest is NeonMarket, Test {

    User immutable user1;
    User immutable user2;

    address immutable coupon1;
    address immutable coupon2;
    address immutable coupon3;
    address immutable coupon4;
    address immutable coupon5;

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

        mintMultipleForUser(address(user1), 5);              // Initialize volume and user1 balance

        coupon1 = super.getCouponAddrByID(1);
        coupon2 = super.getCouponAddrByID(2);
        coupon3 = super.getCouponAddrByID(3);
        coupon4 = super.getCouponAddrByID(4);
        coupon5 = super.getCouponAddrByID(5);
    }

    function mintMultipleForUser(address user, uint256 amount) private {
        for(uint256 i; i < amount; ++i){
            super.createCoupon(user, block.timestamp, block.timestamp + 100000, 10);
        }
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
        user1.__NeonCoupon__transferTo(address(user2), coupon1);
    }

    function test__Neon_Burn() public {
        user1.__NeonCoupon__burn(coupon1);
    }

    // Burning multiple tokens
    function test__Neon_BurnMultiple_1() public {
        user1.__NeonCoupon__burn(coupon1);
    }

    function test__Neon_BurnMultiple_2() public {
        user1.__NeonCoupon__burn(coupon1);
        user1.__NeonCoupon__burn(coupon2);
    }

    function test__Neon_BurnMultiple_3() public {
        user1.__NeonCoupon__burn(coupon1);
        user1.__NeonCoupon__burn(coupon2);
        user1.__NeonCoupon__burn(coupon3);
    }

    function test__Neon_BurnMultiple_4() public {
        user1.__NeonCoupon__burn(coupon1);
        user1.__NeonCoupon__burn(coupon2);
        user1.__NeonCoupon__burn(coupon3);
        user1.__NeonCoupon__burn(coupon4);
    }

    function test__Neon_BurnMultiple_5() public {
        user1.__NeonCoupon__burn(coupon1);
        user1.__NeonCoupon__burn(coupon2);
        user1.__NeonCoupon__burn(coupon3);
        user1.__NeonCoupon__burn(coupon4);
        user1.__NeonCoupon__burn(coupon5);
    }
}