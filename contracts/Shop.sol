// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import '@openzeppelin/contracts/access/Ownable.sol';
import './interfaces/IShop.sol';
import './Coupon.sol';

contract Shop is Ownable, IShop {

	ICoupon couponContract;
	Product[] products;

	// Mapping how many products address purchased 
	mapping(address => uint256) loyaltyProgram;

	constructor(string memory name, string memory symbol, string memory uri){
		couponContract = new Coupon(name, symbol, uri);
		products.push(Product({ name: 'test', value: 0.1 ether, couponUsable: false }));
		products.push(Product({ name: 'test1', value: 0.25 ether, couponUsable: true }));
		products.push(Product({ name: 'test2', value: 0.4 ether, couponUsable: false }));
	}

	function buyProduct(uint256 productId) public payable{
		buyProduct(productId, 0);
	}

	function buyProduct(uint256 productId, uint256 couponId) public payable{
		if(products.length < productId) revert OutOfRange();
		// TODO: Missing msg.value with discount
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
		// Increment msg.sender loyalty 
		loyaltyProgram[msg.sender]++;
	}

	function mintCoupon() public{
		uint256 numOfPurchasedProducts = getNumOfPurchasedProducts();
		if(numOfPurchasedProducts == 5){
			couponContract.mintSoulbound(msg.sender, 1, 10, 30);
		}else if(numOfPurchasedProducts == 10){
			couponContract.mintSoulbound(msg.sender, 2, 10, 30);
		}else{
			return;
		}
	}

	function getCouponContractAddress() public view returns(address){
		return address(couponContract);
	}

	function getNumOfPurchasedProducts() public view returns(uint256){
		return loyaltyProgram[msg.sender];
	}

	function addProduct(Product memory _product) public onlyOwner{
		products.push(Product({ name: _product.name, value: _product.value, couponUsable: _product.couponUsable }));
	}

	function getProducts() public view returns(Product[] memory){
		return products;
	}

}
