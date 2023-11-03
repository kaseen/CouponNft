// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract NeonCoupon {
    
    // Coupon info
    uint256 public ID;
    address public owner;
    address public issuer;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public percentage;

    event ChangeOwnerTo(address new_owner);

    // Functions with this modifier can only be executed by the owner
    modifier onlyOwner(){
        assert(owner == msg.sender);
        _;
    }

    // Check whether the redeem time is between the span of startTime and endTime.
    modifier isValidRedeemTime(){
        require(startTime <= block.timestamp);
        require(endTime >= block.timestamp);
        _;
    }

    // Mint coupon
    constructor(
        uint256 _id,
        address _owner,
        address _issuer,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _percentage
    ) {
        require(_percentage <= 100 && _percentage > 0);
        require(_endTime >= _startTime);

        ID = _id;                           // cold SSTORE(1)
        owner = _owner;                     // cold SSTORE(1)
        issuer = _issuer;                   // cold SSTORE(1)
        startTime = _startTime;             // cold SSTORE(1)
        endTime = _endTime;                 // cold SSTORE(1)
        percentage = _percentage;           // cold SSTORE(1)
    }

    // Transfer coupon
    function changeOwnerTo(address receiver) public onlyOwner {
        owner = receiver;
        emit ChangeOwnerTo(receiver);
    }

    // Burn coupon
    function redeem() public onlyOwner isValidRedeemTime {
        changeOwnerTo(issuer);
    }
}
