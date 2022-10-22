// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import './ERC721A.sol';

contract Coupon is ERC721A{

	constructor(string memory _name, string memory _symbol) ERC721A(_name, _symbol){
		// TODO
	}

	function mintSoulbind(address to, uint256 quantity, uint256 percentage, uint256 daysValid) public{
		_mint(to, quantity, true, percentage, daysValid);
	}

	function mintNonSoulbind(address to, uint256 quantity, uint256 percentage, uint256 daysValid) public{
		_mint(to, quantity, false, percentage, daysValid);
	}

	function ownershipOf(uint256 tokenId) public view returns(TokenOwnership memory){
		return _ownershipOf(tokenId);
	}
	
}