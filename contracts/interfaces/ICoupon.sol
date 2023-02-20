// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ICoupon {

	/**
	 * Token ID does not exists.
	 */
	error QueryForNonexistentToken();

	/**
	 * Coupon is not approved by owner.
	 */
	error NotApproved();

	/**
	 * Coupon expired.
	 */
	error CouponExpired();

	/**
	 * Caller not authorized.
	 */
	error NotAuthorized();

	function mintSoulbound(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external returns(uint256);
	function mintNonSoulbound(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external returns(uint256);
	function safeMintSoulbound(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external returns(uint256);
	function safeMintNonSoulbound(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external returns(uint256);
	function useCoupon(uint256 tokenId) external;
	function getCouponDiscount(uint256 tokenId) external view returns(uint256);
	function exists(uint256 tokenId) external view returns(bool);
	
}