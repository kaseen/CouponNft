// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import '@openzeppelin/contracts/access/Ownable.sol';
import './interfaces/IShop.sol';
import './Coupon.sol';

import 'hardhat/console.sol';

contract Shop is Ownable, IShop {

	ICoupon couponContract;

	Product[] products;
	mapping(address => uint256) spentBalances;

	// Mapping user to projectId to balance
	mapping(address => mapping(uint256 => uint256)) productBalances;

	uint256 private _COUPON_DISCOUNT = 10;
	uint256 private _DAYS_VALID = 100;
	uint256 private _QUANTITY_MINTED = 1;
	uint256 private _MINT_THRESHOLD = 0.1 ether;

	constructor(){
		couponContract = new Coupon('NAME_TEST', 'SYMBOL_TEST');
		products.push(Product({ name: 'test', value: 0.1 ether, couponUsable: false }));
		products.push(Product({ name: 'test1', value: 0.25 ether, couponUsable: true }));
		products.push(Product({ name: 'test2', value: 0.4 ether, couponUsable: false }));
	}

	function buyProduct(uint256 productId, uint256 couponId) public payable{
		if(products.length < productId) revert OutOfRange();
		if(msg.value < products[productId].value) revert NotEnoughFunds();

		uint256 couponPercentage = couponContract.getCouponDiscount(couponId);
		
		// Return change (if exists)
		uint256 productValue = products[productId].value;
		uint256 change = msg.value - productValue;

		if(change > 0){
			payable(msg.sender).transfer(change);
		}

		// Reduce product value based on coupon percentage.
		if(couponPercentage != 0){
			// Revert if product price is not reducible
			if(!products[productId].couponUsable) revert ProductPriceNotReducible();

			// Burn coupon (also checks if couponId is valid) 
			couponContract.useCoupon(couponId);

			productValue = (productValue / 100) * couponPercentage;
			emit CouponUsed(msg.sender, couponId);
		}
		spentBalances[msg.sender] += productValue;

		// Mint new coupon if user exceeds threshold
		if(spentBalances[msg.sender] >= _MINT_THRESHOLD){
			couponContract.mintSoulbind(msg.sender, _QUANTITY_MINTED, _COUPON_DISCOUNT, _DAYS_VALID);
			spentBalances[msg.sender] = 0;
			emit CouponMinted(msg.sender);
		}

		productBalances[msg.sender][productId]++;
	}

	function getCouponContractAddress() public view returns(address){
		return address(couponContract);
	}

	function getSpentBalances(address user) public view returns(uint256){
		return spentBalances[user];
	}

	function getProductBalances(address user, uint256 productId) public view returns(uint256){
		return productBalances[user][productId];
	}

	function getProducts() public view returns(Product[] memory){
		return products;
	}

	// =============================================================
	//                  METHODS WITH AUTHORIZATION
	// =============================================================

	function setCouponDiscount(uint256 value) public onlyOwner{
		if(value == 0 || value > 100) revert InvalidParameter();
		_COUPON_DISCOUNT = value;
	}

	function setDaysValid(uint256 value) public onlyOwner{
		if(value == 0 || value > 65535) revert InvalidParameter();
		_DAYS_VALID = value;
	}

	function quantityMinted(uint256 value) public onlyOwner{
		if(value > 5) revert InvalidParameter();
		_QUANTITY_MINTED = value;
	}

	function mintThreshold(uint256 value) public onlyOwner{
		_MINT_THRESHOLD = value;
	}
}
