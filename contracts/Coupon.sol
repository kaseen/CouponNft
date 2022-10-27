// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import './ERC721A.sol';

contract Coupon is ERC721A {

	uint256 private constant _SECONDS_IN_ONE_DAY = 24 * 60 * 60;

	constructor(string memory _name, string memory _symbol) ERC721A(_name, _symbol){
		// TODO
	}

	error QueryForNonexistentToken();
	error NotOwner();
	error CouponExpired();

	function mintSoulbind(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external {
		_mint(to, quantity, true, percentage, daysValid);
	}

	function mintNonSoulbind(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external {
		_mint(to, quantity, false, percentage, daysValid);
	}

	function safeMintSoulbind(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external {
		_safeMint(to, quantity, true, percentage, daysValid);
	}

	function safeMintNonSoulbind(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external {
		_safeMint(to, quantity, false, percentage, daysValid);
	}

	function useCoupon(uint256 tokenId) external {
		TokenOwnership memory unpackedOwnership = _ownershipOf(tokenId);

		// Check if tokenId is valid or coupon is already burned.
		if(!_exists(tokenId)) revert QueryForNonexistentToken();

		// Check if msg.sender is owner of coupon
		if(unpackedOwnership.addr != msg.sender) revert NotOwner();

		// Check if coupon expired.
		if(unpackedOwnership.startTimestamp + unpackedOwnership.daysValid * _SECONDS_IN_ONE_DAY < block.timestamp)
			revert CouponExpired();

		_burn(tokenId);
	}

	// TODO: Helper function, remove
	function ownershipOf(uint256 tokenId) external view returns(TokenOwnership memory){
		return _ownershipOf(tokenId);
	}
	
}