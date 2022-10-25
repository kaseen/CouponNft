// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import './ERC721A.sol';

contract Coupon is ERC721A{

	constructor(string memory _name, string memory _symbol) ERC721A(_name, _symbol){
		// TODO
	}

	function mintSoulbind(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external {
		_mint(to, quantity, true, percentage, daysValid);
	}

	function mintNonSoulbind(address to, uint256 quantity, uint256 percentage, uint256 daysValid) external {
		_mint(to, quantity, false, percentage, daysValid);
	}

	function useCoupon(uint256 tokenId) external {
		// TODO: require daysValid + timestamp < block.timestamp
		_burn(tokenId);
	}

	function ownershipOf(uint256 tokenId) external view returns(TokenOwnership memory){
		return _ownershipOf(tokenId);
	}

	function getPercentage(uint256 tokenId) external view returns(uint256){
		return _getPercentage(tokenId);
	}

	function getDaysValid(uint256 tokenId) external view returns(uint256){
		return _getDaysValid(tokenId);
	}

	function exists(uint256 tokenId) external view returns(bool){
		return _exists(tokenId);
	}
	
}