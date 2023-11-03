// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { NeonCoupon } from 'src/NeonCoupon.sol';

contract NeonMarket {

    uint256 public volume;
    mapping(uint256 => address) public coupons;

    event CreateCoupon(uint256 id, address new_address);

    constructor() {
        volume = 0;
    }

    // Get Available ID
    function getNextID() public returns (uint256) {
        volume = volume + 1;
        return volume;
    }

    // Coupon creater
    function createCoupon(
        address user,
        uint256 startTimestamp,
        uint256 endTimestamp,
        uint256 value
    ) public returns (uint256) {

        uint256 couponID = getNextID();                             // cold SSTORE(2), if volume is 0 then cold SSTORE(1)
        /*
         *  Creating new NeonCoupon contract costs around ~400k gas
         * 
         *  Num of zero bytes in tx.data = 108
         *  Num of non-zero bytes in tx.data = 1643
         *  Runtime length = 1184
         * 
         *  CREATE: 32,000
         *  SSTORE(1): 22100
         * 
         *  Total cost: 32,000 + 6 * 22100 + 108 * 4 + 1643 * 16 + 1184 * 200 + constructor code
         */ 

        address couponAddress = address(new NeonCoupon(
            couponID,
            user,
            address(this),
            startTimestamp,
            endTimestamp,
            value
        ));

        coupons[couponID] = couponAddress;                          // cold SSTORE(1)
        emit CreateCoupon(couponID, couponAddress);
        return couponID;
    }

    // Return coupon address
    function getCouponAddrByID(uint256 couponID) public view returns (address) {
        return coupons[couponID];
    }
}