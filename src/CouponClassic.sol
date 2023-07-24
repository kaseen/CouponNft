// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract CouponClassic {
    
    // Coupon info
    uint256 ID;
    address owner;
    uint256 startTime;
    bool soulbound;
    uint256 percentage;
    uint256 daysValid;

    event ChangeOwnerTo(address new_owner);

    modifier onlyOwner(){
        assert(owner == msg.sender);
        _;
    }

    modifier isValidRedeemTime(){
        require(startTime + daysValid * 86400 >= block.timestamp);
        _;
    }

    // Mint coupon
    constructor(
        uint256 _id,
        address _owner,
        uint256 _startTime,
        bool _soulbound,
        uint256 _percentage,
        uint256 _daysValid
    ) {
        require(_percentage <= 100 && _percentage > 0);
        require(_daysValid <= 65535 && _daysValid > 0);

        ID = _id;
        owner = _owner;
        startTime = _startTime;
        soulbound = _soulbound;
        percentage = _percentage;
        daysValid = _daysValid;
    }

    // Transfer coupon
    function changeOwnerTo(address receiver) public onlyOwner {
        require(!soulbound);

        owner = receiver;
        emit ChangeOwnerTo(receiver);
    }

    // Burn coupon
    function redeem() public onlyOwner isValidRedeemTime {
        changeOwnerTo(address(0));
    }
}