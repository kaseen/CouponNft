// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

interface IERC721B {

    struct CouponInfo {
        // The address of the owner.
        address addr;
        // Stores the start time of ownership with minimal overhead for tokenomics.
        uint64 startTimestamp;
        // Whether the token has been burned.
        bool burned;
        // Whather the token is soulbound.
        bool giftable;
        // Number representing the discount of token.
        uint8 percentage;
        // Number of days until token expire.
        uint16 daysValid;
    }

    /*///////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    error ApprovalCallerNotOwnerNorApproved();
    error ApprovalQueryForNonexistentToken();
    error ApproveToCaller();
    error ApprovalToCurrentOwner();
    error BalanceQueryForZeroAddress();
    error MintedQueryForZeroAddress();
    error MintToZeroAddress();
    error MintZeroQuantity();
    error OwnerIndexOutOfBounds();
    error OwnerQueryForNonexistentToken();
    error TokenIndexOutOfBounds();
    error TransferCallerNotOwnerNorApproved();
    error TransferFromIncorrectOwner();
    error TransferToNonERC721ReceiverImplementer();
    error TransferToZeroAddress();
    error UnableDetermineTokenOwner();
    error UnableGetTokenOwnerByIndex();
    error URIQueryForNonexistentToken();
    error MintInvalidPercentage();
    error MintInvalidDays();
    error TransferNonGiftableToken();

    function ownerOf(uint256 tokenId) external view returns (address owner);
}