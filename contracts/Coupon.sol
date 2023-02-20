// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import '@openzeppelin/contracts/access/Ownable.sol';
import './interfaces/ICoupon.sol';
import './ERC721A.sol';

contract Coupon is Ownable, ERC721A, ICoupon {
	
	uint256 private constant _SECONDS_IN_ONE_DAY = 24 * 60 * 60;
	string private _baseTokenURI;

	constructor(string memory _name, string memory _symbol, string memory baseTokenURI) ERC721A(_name, _symbol){
		_baseTokenURI = baseTokenURI;
	}

	function mintSoulbound(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external onlyOwner returns(uint256){
		_mint(to, quantity, true, percentage, daysValid);
		return _nextTokenId() - 1;
	}

	function mintNonSoulbound(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external onlyOwner returns(uint256){
		_mint(to, quantity, false, percentage, daysValid);
		return _nextTokenId() - 1;
	}

	function safeMintSoulbound(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external onlyOwner returns(uint256){
		_safeMint(to, quantity, true, percentage, daysValid);
		return _nextTokenId() - 1;
	}

	function safeMintNonSoulbound(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external onlyOwner returns(uint256){
		_safeMint(to, quantity, false, percentage, daysValid);
		return _nextTokenId() - 1;
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
		return tokenId == 0 ? 0 : _ownershipOf(tokenId).percentage;
	}

	function exists(uint256 tokenId) external view returns(bool){
		return tokenId == 0 ? true : _exists(tokenId);
	}
	
}