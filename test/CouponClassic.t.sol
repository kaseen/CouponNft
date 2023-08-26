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

    function mintCoupon(address user) private {
        coupons[volume] = address(new CouponClassic(volume, user, 2 * block.timestamp, false, 10, 100));
        volume++;
    }

    function setUp() public {
        user1 = new User(address(this));
        user2 = new User(address(this));

        mintCoupon(address(user1));
    }

    function testMintSingle() public {
        mintCoupon(address(user1));
    }

    function testMintMultiple() public {
        uint256 n = 6;
        for(uint256 i; i < n; ++i)
            mintCoupon(address(user1));
    }

    function testTransfer() public {
        user1.__Classic__transferTo(address(user2), coupons[0]);
    }

    function testBurn() public {
        user1.__Classic__burn(coupons[0]);
    }

}