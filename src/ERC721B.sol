// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.4;

import './IERC721B.sol';

/**
 * @dev Interface of ERC721 token receiver.
 */
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

/**
 * @notice Updated, minimalist and gas efficient version of OpenZeppelins ERC721 contract.
 *         Includes the Metadata and Enumerable extension.
 *
 * @dev Token IDs are minted  in sequential order starting at 0 (e.g. 0, 1, 2, ...).
 *      Does not support burning tokens.
 *
 * @author beskay0x
 * Credits: chiru-labs, solmate, transmissions11, nftchance, squeebo_nft and others
 */

contract ERC721B is IERC721B {

    /*///////////////////////////////////////////////////////////////
                             MASKS FOR PACKING
    //////////////////////////////////////////////////////////////*/

    // The mask of the lower 160 bits for addresses.
    uint256 private constant _BITMASK_ADDRESS = (1 << 160) - 1;

    // The bit mask of the `burned` bit in packed ownership.
    uint256 private constant _BITMASK_BURNED = 1 << 224;

    // The bit mask of the `giftable` bit in packed ownership.
    uint256 private constant _BITMASK_GIFTABLE = 1 << 226;

    // The bit position of `startTimestamp` in packed ownership.
    uint256 private constant _BITPOS_START_TIMESTAMP = 160;

    // The bit position of the `giftable` bit in packed ownership.
    uint256 private constant _BITPOS_GIFTABLE = 226;

    // The bit position of `percentage` in packed ownership.
    uint256 private constant _BITPOS_PERCENTAGE = 232;

    // The bit position of `daysValid` in packed ownership.
    uint256 private constant _BITPOS_DAYS_VALID = 240;

    /*///////////////////////////////////////////////////////////////
                          METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    // function tokenURI(uint256 tokenId) public view virtual returns (string memory);

    /*///////////////////////////////////////////////////////////////
                          ERC721 STORAGE
    //////////////////////////////////////////////////////////////*/

    // Array which maps token ID to address (index is tokenID)
    uint256[] internal _owners;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /*///////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /*///////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x780e9d63 || // ERC165 Interface ID for ERC721Enumerable
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*///////////////////////////////////////////////////////////////
                       ERC721ENUMERABLE LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _owners.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     * It is not recommended to call this function on chain from another smart contract,
     * as it can become quite expensive for larger collections.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256 tokenId) {
        if (index >= balanceOf(owner)) revert OwnerIndexOutOfBounds();

        uint256 count;
        uint256 qty = _owners.length;
        // Cannot realistically overflow, since we are using uint256
        unchecked {
            for (tokenId; tokenId < qty; tokenId++) {
                if (owner == ownerOf(tokenId)) {
                    if (count == index) return tokenId;
                    else count++;
                }
            }
        }

        revert UnableGetTokenOwnerByIndex();
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual returns (uint256) {
        if (index >= totalSupply()) revert TokenIndexOutOfBounds();
        return index;
    }

    /*///////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Returns the number of tokens in `owner`'s account.
     *      Iterates through _owners array -- it is not recommended to call this function
     *      from another contract, as it can become quite expensive for larger collections.
     */
    function balanceOf(address owner) public view virtual returns (uint256) {
        if (owner == address(0)) revert BalanceQueryForZeroAddress();

        uint256 count;
        uint256 qty = _owners.length;
        // Cannot realistically overflow, since we are using uint256
        unchecked {
            for (uint256 i; i < qty; i++) {
                if (owner == ownerOf(i)) {
                    count++;
                }
            }
        }
        return count;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual {
        address owner = ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (msg.sender != owner && !isApprovedForAll(owner, msg.sender)) revert ApprovalCallerNotOwnerNorApproved();

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual returns (address) {
        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual {
        if (operator == msg.sender) revert ApproveToCaller();

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual {
        if (!_exists(tokenId)) revert OwnerQueryForNonexistentToken();
        if (ownerOf(tokenId) != from) revert TransferFromIncorrectOwner();
        if (to == address(0)) revert TransferToZeroAddress();

        uint256 previousOwnerInfo = _packedOwnershipOf(tokenId);
        if (previousOwnerInfo & _BITMASK_GIFTABLE == 0) revert TransferNonGiftableToken();

        bool isApprovedOrOwner = (msg.sender == from ||
            msg.sender == getApproved(tokenId) ||
            isApprovedForAll(from, msg.sender));
        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();

        _beforeTokenTransfers(from, to, tokenId, 1);

        // delete token approvals from previous owner
        delete _tokenApprovals[tokenId];

        uint256 result;
        assembly {
            result := and(to, _BITMASK_ADDRESS)
            result := or(result, shl(_BITPOS_START_TIMESTAMP, shr(_BITPOS_START_TIMESTAMP, previousOwnerInfo)))
        }

        _owners[tokenId] = result;

        // if token ID below transferred one isnt set, set it to previous owner
        // if tokenid is zero, skip this to prevent underflow
        if (tokenId > 0 && _owners[tokenId - 1] == 0) {
            _owners[tokenId - 1] = previousOwnerInfo;
        }

        _afterTokenTransfers(from, to, tokenId, 1);

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        safeTransferFrom(from, to, id, '');
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) public virtual {
        transferFrom(from, to, id);

        if (!_checkOnERC721Received(from, to, id, data)) revert TransferToNonERC721ReceiverImplementer();
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    /**
     * @dev Returns whether `tokenId` exists.
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return tokenId < _owners.length;
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     *      The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.code.length == 0) return true;

        try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) revert TransferToNonERC721ReceiverImplementer();

            assembly {
                revert(add(32, reason), mload(reason))
            }
        }
    }

    /*///////////////////////////////////////////////////////////////
                       INTERNAL MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Safely mints `qty` tokens and transfers them to `to`.
     *
     *      If `to` refers to a smart contract, it must implement
     *      {IERC721Receiver-onERC721Received}
     *
     *      Unlike in the standard ERC721 implementation {IERC721Receiver-onERC721Received}
     *      is only called once. If the receiving contract confirms the transfer of one token,
     *      all additional tokens are automatically confirmed too.
     */
    function _safeMint(
        address to,
        uint256 qty,
        bool giftable,
        uint256 percentage,
        uint256 daysValid
    ) internal virtual {
        _safeMint(to, qty, giftable, percentage, daysValid, '');
    }

    /**
     * @dev Equivalent to {safeMint(to, qty)}, but accepts an additional data argument.
     */
    function _safeMint(
        address to,
        uint256 qty,
        bool giftable,
        uint256 percentage,
        uint256 daysValid,
        bytes memory data
    ) internal virtual {
        _mint(to, qty, giftable, percentage, daysValid);

        if (!_checkOnERC721Received(address(0), to, _owners.length - 1, data))
            revert TransferToNonERC721ReceiverImplementer();
    }

    /**
     * @dev Mints `qty` tokens and transfers them to `to`.
     *      Emits a {Transfer} event for each mint.
     */
    function _mint(address to, uint256 qty, bool giftable, uint256 percentage, uint256 daysValid) internal virtual {
        if (to == address(0)) revert MintToZeroAddress();
        if (qty == 0) revert MintZeroQuantity();
        if (percentage > 100 || percentage == 0) revert MintInvalidPercentage();
        if (daysValid > 65535 || daysValid == 0) revert MintInvalidDays();

        uint256 _currentIndex = _owners.length;

        _beforeTokenTransfers(address(0), to, _currentIndex, qty);

        // Cannot realistically overflow, since we are using uint256
        unchecked {
            for (uint256 i; i < qty - 1; i++) {
                _owners.push();
                emit Transfer(address(0), to, _currentIndex + i);
            }
        }

        uint256 result;
        assembly {
            result := and(to, _BITMASK_ADDRESS)
            result := or(result, shl(_BITPOS_START_TIMESTAMP, timestamp()))
            result := or(result, shl(_BITPOS_GIFTABLE, giftable))
            result := or(result, shl(_BITPOS_PERCENTAGE, percentage))
            result := or(result, shl(_BITPOS_DAYS_VALID, daysValid))
        }

        // set last index to receiver
        _owners.push(result);
        emit Transfer(address(0), to, _currentIndex + (qty - 1));

        _afterTokenTransfers(address(0), to, _currentIndex, qty);
    }

    /*///////////////////////////////////////////////////////////////
                            OWNERSHIP OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return address(uint160(_packedOwnershipOf(tokenId)));
    }

    function _ownershipOf(uint256 tokenId) internal view virtual returns (TokenOwnership memory) {
        return _unpackedOwnership(_packedOwnershipOf(tokenId));
    }

    function _initializeOwnershipAt(uint256 index) internal virtual {
        if (_owners[index] == 0) {
            _owners[index] = _packedOwnershipOf(index);
        }
    }

    function _packedOwnershipOf(uint256 tokenId) private view returns (uint256) {
        if (!_exists(tokenId)) revert OwnerQueryForNonexistentToken();

        // Cannot realistically overflow, since we are using uint256
        unchecked {
            for (tokenId; ; tokenId++) {
                if (_owners[tokenId] != 0) {
                    return _owners[tokenId];
                }
            }
        }

        revert UnableDetermineTokenOwner();
    }

    function _unpackedOwnership(uint256 packed) private pure returns (TokenOwnership memory ownership) {
        ownership.addr = address(uint160(packed));
        ownership.startTimestamp = uint64(packed >> _BITPOS_START_TIMESTAMP);
        ownership.burned = packed & _BITMASK_BURNED != 0;
        ownership.giftable = packed & _BITMASK_GIFTABLE != 0;
        ownership.percentage = uint8(packed >> _BITPOS_PERCENTAGE);
        ownership.daysValid = uint16(packed >> _BITPOS_DAYS_VALID);
    }
}