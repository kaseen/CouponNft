// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import '@openzeppelin/contracts/access/Ownable.sol';
import './interfaces/ICoupon.sol';
import './ERC721A.sol';

contract Coupon is Ownable, ERC721A, ICoupon {
	
	uint256 private constant _SECONDS_IN_ONE_DAY = 24 * 60 * 60;

	constructor(string memory _name, string memory _symbol) ERC721A(_name, _symbol){}

	function mintSoulbind(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external onlyOwner {
		_mint(to, quantity, true, percentage, daysValid);
	}

	function mintNonSoulbind(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external onlyOwner {
		_mint(to, quantity, false, percentage, daysValid);
	}

	function safeMintSoulbind(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external onlyOwner {
		_safeMint(to, quantity, true, percentage, daysValid);
	}

	function safeMintNonSoulbind(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external onlyOwner {
		_safeMint(to, quantity, false, percentage, daysValid);
	}

	function useCoupon(uint256 tokenId) external onlyOwner {
		TokenOwnership memory unpackedOwnership = _ownershipOf(tokenId);

		// Check if tokenId is valid or coupon is already burned.
		if(!_exists(tokenId)) revert QueryForNonexistentToken();		

		// Check if coupon expired.
		if(unpackedOwnership.startTimestamp + unpackedOwnership.daysValid * _SECONDS_IN_ONE_DAY < block.timestamp)
			revert CouponExpired();

		// Check if coupon is approved by its owner.
		if(msg.sender != getApproved(tokenId)) revert NotApproved();

		_burn(tokenId);
	}

	function getCouponDiscount(uint256 tokenId) external view returns(uint256) {
		if(tokenId == 0)
			return 0;
		return _ownershipOf(tokenId).percentage;
	}

	function exists(uint256 tokenId) external view returns(bool){
		// '0th' token is used for buying without discount
		if(tokenId == 0)
			return true;
		return _exists(tokenId);
	}

	// TODO: Helper function, remove
	function ownershipOf(uint256 tokenId) external view returns(TokenOwnership memory){
		return _ownershipOf(tokenId);
	}
	
}