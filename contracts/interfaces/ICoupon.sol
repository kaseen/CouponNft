// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ICoupon {

	/**
	 * Emitted when coupon is not approved by owner.
	 */
	error NotApproved();

	/**
	 * Emitted when coupon is expired.
	 */
	error CouponExpired();

	/**
	 * Emitted when caller not authorized.
	 */
	error NotAuthorized();

	function mintSoulbound(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external;
	function mintNonSoulbound(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external;
	function safeMintSoulbound(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external;
	function safeMintNonSoulbound(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external;
	function useCoupon(uint256 tokenId) external;
	function getCouponDiscount(uint256 tokenId) external view returns(uint256);
	function exists(uint256 tokenId) external view returns(bool);
}