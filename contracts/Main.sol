// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// TODO: interface
import './Coupon.sol';

import 'hardhat/console.sol';

contract Main {

	error OutOf();
	error NotEnoughFunds();
	error QueryForNonexistentToken();

	event CouponUsed(address user, uint256 couponId);
	event CouponMinted(address user);

	ICoupon couponContract;

	struct Product {
		string name;
		uint256 value;
		bool couponUsable;
	}

	Product[] products;
	mapping(address => uint256) spentBalances;

	// Mapping user to projectId to balance
	mapping(address => mapping(uint256 => uint256)) productBalances;

	constructor(){
		couponContract = new Coupon('NAME_TEST', 'SYMBOL_TEST');
		products.push(Product({ name: 'test', value: 100000000000000000, couponUsable: false }));
		products.push(Product({ name: 'test1', value: 2500000000000000, couponUsable: true }));
		products.push(Product({ name: 'test2', value: 4000000000000000, couponUsable: false }));
	}

	function buyProduct(uint256 productId, uint256 couponId) public payable{
		if(products.length < productId) revert OutOf();
		if(msg.value < products[productId].value) revert NotEnoughFunds();

		uint256 couponDiscount = couponContract.getCouponDiscount(couponId);
		uint256 productValue = msg.value;

		if(couponDiscount != 0){
			// Also checks if couponId is valid 
			couponContract.useCoupon(couponId);
			productValue = (productValue *  couponDiscount) / 100;
			emit CouponUsed(msg.sender, couponId);
		}
		spentBalances[msg.sender] += productValue;

		if(spentBalances[msg.sender] > 1 ether){
			couponContract.mintSoulbind(msg.sender, 1, 10, 100);
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
}
