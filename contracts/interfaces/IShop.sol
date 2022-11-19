// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IShop {

	struct Product {
		string name;
		uint256 value;
		bool couponUsable;
	}

	/**
	 * Emitted when coupon is used.
	 */
	event CouponUsed(address user, uint256 couponId);

	/**
	 * Emitted when new coupon is minted.
	 */
	event CouponMinted(address user, uint256 couponId);

	/**
	 * Token ID is invalid.
	 */
	error QueryForNonexistentToken();

	/**
	 * Product ID is invalid.
	 */
	error OutOfRange();

	/**
	 * Not enough funds in msg.value.
	 */
	error NotEnoughFunds();

	/**
	 * Product price is not reducible.
	 */
	error ProductPriceNotReducible();

	/**
	 * Function parameter is invalid.
	 */
	error InvalidParameter();
}