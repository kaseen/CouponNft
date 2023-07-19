// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract ERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4){
        // Silence compiler warnings 
        operator; from; tokenId; data;

        return this.onERC721Received.selector;
    }
}