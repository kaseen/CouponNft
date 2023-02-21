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
		products.push(Product({ name: 'PRODUCT_1', value: 0.1 ether, couponUsable: false }));
		products.push(Product({ name: 'PRODUCT_2', value: 1 ether, couponUsable: true }));
		products.push(Product({ name: 'PRODUCT_3', value: 0.4 ether, couponUsable: false }));
	}

	function buyProduct(uint256 productId) public payable{
		buyProduct(productId, 0);
	}

	function buyProduct(uint256 productId, uint256 couponId) public payable{
		if(products.length < productId) revert OutOfRange();

		// If coupon is burned reverts with _packedOwnershipOf -> OwnerQueryForNonexistentToken
		uint256 couponPercentage = couponContract.getCouponDiscount(couponId);
		uint256 productValue = products[productId].value;

		// Use coupon and calculate productValue 
		if(couponPercentage != 0){
			// Revert if product price is not reducible
			if(!products[productId].couponUsable) revert ProductPriceNotReducible();

			// Burn coupon (also checks if couponId is valid) 
			couponContract.useCoupon(couponId);

			productValue = (productValue * (100 - couponPercentage)) / 100;
			emit CouponUsed(msg.sender, couponId);
		}

		// Check if user have enough funds
		if(msg.value < productValue) revert NotEnoughFunds();
		
		// Return change (if exists)
		uint256 change = msg.value - productValue;
		if(change > 0){
			payable(msg.sender).transfer(change);
		}

		// Increment msg.sender loyalty 
		loyaltyProgram[msg.sender]++;
	}

	function mintCoupon() public{
		uint256 numOfPurchasedProducts = getNumOfPurchasedProducts();

		if(numOfPurchasedProducts == 10)
			couponContract.mintSoulbound(msg.sender, 1, 10, 30);
		else if(numOfPurchasedProducts == 50)
			couponContract.mintSoulbound(msg.sender, 2, 15, 30);
		else{
			bool canMint = (numOfPurchasedProducts % 100) == 0;
			if(canMint)
				couponContract.mintSoulbound(msg.sender, 5, 20, 30);
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
