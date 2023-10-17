// SPDX-License-Identifier: MIT
/**
  ______ _____   _____ ______ ___  __ _  _  _ 
 |  ____|  __ \ / ____|____  |__ \/_ | || || |
 | |__  | |__) | |        / /   ) || | \| |/ |
 |  __| |  _  /| |       / /   / / | |\_   _/ 
 | |____| | \ \| |____  / /   / /_ | |  | |   
 |______|_|  \_\\_____|/_/   |____||_|  |_|   

 - github: https://github.com/estarriolvetch/ERC721Psi
 - npm: https://www.npmjs.com/package/erc721psi

 */

pragma solidity ^0.8.0;

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

import { IERC721Psi } from './interfaces/IERC721Psi.sol';
import { BitMaps } from './libs/BitMaps.sol';

contract ERC721Psi is IERC721Psi {

    // The mask of the lower 160 bits for addresses.
    uint256 private constant _BITMASK_ADDRESS = (1 << 160) - 1;

    // The bit mask of the `giftable` bit in packed ownership.
    uint256 private constant _BITMASK_GIFTABLE = 1 << 224;

    // The bit position of `startTimestamp` in packed ownership.
    uint256 private constant _BITPOS_START_TIMESTAMP = 160;

    // The bit position of the `giftable` bit in packed ownership.
    uint256 private constant _BITPOS_GIFTABLE = 224;

    // The bit position of `percentage` in packed ownership.
    uint256 private constant _BITPOS_PERCENTAGE = 232;

    // The bit position of `daysValid` in packed ownership.
    uint256 private constant _BITPOS_DAYS_VALID = 240;

    using BitMaps for BitMaps.BitMap;

    BitMaps.BitMap private _batchHead;

    string private _name;
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => uint256) internal _owners;
    uint256 private _currentIndex;

    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // The `Transfer` event signature is given by:
    // `keccak256(bytes("Transfer(address,address,uint256)"))`.
    bytes32 private constant _TRANSFER_EVENT_SIGNATURE =
        0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    /**
     * @dev Returns the starting token ID.
     * To change the starting token ID, please override this function.
     */
    function _startTokenId() internal pure returns (uint256) {
        // It will become modifiable in the future versions
        return 0;
    }

    /**
     * @dev Returns the next token ID to be minted.
     */
    function _nextTokenId() internal view virtual returns (uint256) {
        return _currentIndex;
    }

    /**
     * @dev Returns the total amount of tokens minted in the contract.
     */
    function _totalMinted() internal view virtual returns (uint256) {
        return _currentIndex - _startTokenId();
    }


    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == 0x01ffc9a7 ||    // ERC165 interface ID for ERC165.
            interfaceId == 0x80ac58cd ||    // ERC165 interface ID for ERC721
            interfaceId == 0x5b5e139f;      // ERC165 interface ID for ERC721Metadata
    }


    // =============================================================
    //                     OWNERSHIPS OPERATIONS
    // =============================================================

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        (uint256 packedOwnership, ) = _packedOwnershipAndBatchHeadOf(tokenId);
        return address(uint160(packedOwnership));
    }

    function _packedOwnershipAndBatchHeadOf(uint256 tokenId)
        internal
        view
        returns (uint256 packedOwnership, uint256 tokenIdBatchHead) {
        require(_exists(tokenId), "ERC721Psi: owner query for nonexistent token");  // 2 * cold SLOAD, with burnable extension
        tokenIdBatchHead = _getBatchHead(tokenId);
        packedOwnership = _owners[tokenIdBatchHead];                                // cold SLOAD
    }

    function _ownershipOf(uint256 tokenId) internal view returns (CouponInfo memory ownership) {
        uint256 tokenIdBatchHead = _getBatchHead(tokenId);
        uint256 packedOwnership = _owners[tokenIdBatchHead];

        ownership.owner = address(uint160(packedOwnership));
        ownership.startTimestamp = uint64(packedOwnership >> _BITPOS_START_TIMESTAMP);
        ownership.giftable = packedOwnership & _BITMASK_GIFTABLE != 0;
        ownership.percentage = uint8(packedOwnership >> _BITPOS_PERCENTAGE);
        ownership.daysValid = uint16(packedOwnership >> _BITPOS_DAYS_VALID);
    }


    // =============================================================
    //                        IERC721Metadata
    // =============================================================

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        require(_exists(tokenId), "ERC721Psi: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _toString(tokenId))) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }


    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721Psi: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721Psi: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721Psi: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        require(operator != _msgSender(), "ERC721Psi: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721Psi: transfer caller is not owner nor approved"
        );

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721Psi: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, 1, _data),
            "ERC721Psi: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        require(
            _exists(tokenId),
            "ERC721Psi: operator query for nonexistent token"
        );
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called for each safe transfer.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(
        address to,
        uint256 quantity,
        bool giftable,
        uint256 percentage,
        uint256 daysValid
    ) internal virtual {
        _safeMint(to, quantity, giftable, percentage, daysValid, "");
    }

    function _safeMint(
        address to,
        uint256 quantity,
        bool giftable,
        uint256 percentage,
        uint256 daysValid,
        bytes memory _data
    ) internal virtual {
        uint256 nextTokenId = _nextTokenId();
        _mint(to, quantity, giftable, percentage, daysValid);
        require(
            _checkOnERC721Received(address(0), to, nextTokenId, quantity, _data),
            "ERC721Psi: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(
        address to,
        uint256 quantity,
        bool giftable,
        uint256 percentage,
        uint256 daysValid
    ) internal virtual {
        uint256 nextTokenId = _nextTokenId();                                       // cold SLOAD

        require(quantity > 0, "ERC721Psi: quantity must be greater 0");
        require(to != address(0), "ERC721Psi: mint to the zero address");
        require(percentage > 0 && percentage < 101, "ERC721Psi: invalid percentage");
        require(daysValid > 0 && daysValid < 65536, "ERC721Psi: invalid days");

        _beforeTokenTransfers(address(0), to, nextTokenId, quantity);
        _currentIndex += quantity;                                                  // warm SSTORE(2), if index is 0 warm SSTORE(1)

        uint256 result;
        assembly {
            result := and(to, _BITMASK_ADDRESS)
            result := or(result, shl(_BITPOS_START_TIMESTAMP, timestamp()))
            result := or(result, shl(_BITPOS_GIFTABLE, giftable))
            result := or(result, shl(_BITPOS_PERCENTAGE, percentage))
            result := or(result, shl(_BITPOS_DAYS_VALID, daysValid))
        }
        _owners[nextTokenId] = result;                                              // cold SSTORE(1)

        _batchHead.set(nextTokenId);                                                // cold SSTORE(2), if bucket is empty cold SSTORE(1) 

        uint256 toMasked;
        uint256 end = nextTokenId + quantity;

        // Use assembly to loop and emit the `Transfer` event for gas savings.
        // The duplicated `log4` removes an extra check and reduces stack juggling.
        // The assembly, together with the surrounding Solidity code, have been
        // delicately arranged to nudge the compiler into producing optimized opcodes.
        assembly {
            // Mask `to` to the lower 160 bits, in case the upper bits somehow aren't clean.
            toMasked := and(to, _BITMASK_ADDRESS)
            // Emit the `Transfer` event.
            log4(
                0, // Start of data (0, since no data).
                0, // End of data (0, since no data).
                _TRANSFER_EVENT_SIGNATURE, // Signature.
                0, // `address(0)`.
                toMasked, // `to`.
                nextTokenId // `tokenId`.
            )

            // The `iszero(eq(,))` check ensures that large values of `quantity`
            // that overflows uint256 will make the loop run out of gas.
            // The compiler will optimize the `iszero` away for performance.
            for {
                let tokenId := add(nextTokenId, 1)
            } iszero(eq(tokenId, end)) {
                tokenId := add(tokenId, 1)
            } {
                // Emit the `Transfer` event. Similar to above.
                log4(0, 0, _TRANSFER_EVENT_SIGNATURE, 0, toMasked, tokenId)
            }
        }

        _afterTokenTransfers(address(0), to, nextTokenId, quantity);
    }


    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        (uint256 previousOwnershipInfo, uint256 tokenIdBatchHead) = _packedOwnershipAndBatchHeadOf(tokenId);

        require(
            address(uint160(previousOwnershipInfo)) == from,
            "ERC721Psi: transfer of token that is not own"
        );
        require(to != address(0), "ERC721Psi: transfer to the zero address");

        _beforeTokenTransfers(from, to, tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);   

        uint256 subsequentTokenId = tokenId + 1;

        // If subsequent token id is 0 and within limit, save information about original owner
        if(!_batchHead.get(subsequentTokenId) &&  
            subsequentTokenId < _nextTokenId()                                      // warm SLOAD
        ) {
            _owners[subsequentTokenId] = previousOwnershipInfo;                     // cold SSTORE(1)
            _batchHead.set(subsequentTokenId);                                      // warm SSTORE(2), if bucket is empty warm SSTORE(1)
        }

        // Change address to from in packedOwnershipInfo and save in _owners mapping new owner
        uint256 result;
        assembly {
            result := and(to, _BITMASK_ADDRESS)
            result := or(result, shl(_BITPOS_START_TIMESTAMP, shr(_BITPOS_START_TIMESTAMP, previousOwnershipInfo)))
        }
        _owners[tokenId] = result;                                                  // cold SSTORE(1), if id is batch head warm SSTORE(2)

        // If id being transferred have 0 in BitMap i.e. is not head of the batch
        if(tokenId != tokenIdBatchHead) {
            _batchHead.set(tokenId);                                                // warm SSTORE(3), if id is in end of bucket warm SSTORE(2)
        }

        emit Transfer(from, to, tokenId);

        _afterTokenTransfers(from, to, tokenId, 1);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param startTokenId uint256 the first ID of the tokens to be transferred
     * @param quantity uint256 amount of the tokens to be transfered.
     * @param _data bytes optional data to send along with the call
     * @return r bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity,
        bytes memory _data
    ) private returns (bool r) {
        if (isContract(to)) {
            r = true;
            for(uint256 tokenId = startTokenId; tokenId < startTokenId + quantity; tokenId++){
                try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                    r = r && retval == IERC721Receiver.onERC721Received.selector;
                } catch (bytes memory reason) {
                    if (reason.length == 0) {
                        revert("ERC721Psi: transfer to non ERC721Receiver implementer");
                    } else {
                        assembly {
                            revert(add(32, reason), mload(reason))
                        }
                    }
                }
            }
            return r;
        } else {
            return true;
        }
    }

    /**
     * If n is a label for the distance between current token id and the head of a batch,
     * price of this function can be calculated as:
     * 
     * (n/256+1)*2100+(n/256*2.5)*194
     * 
     * where the first addend in the sum is number of SLOAD insructions, second and third
     * addends are approximated gas cost of all instructions inside function body
     */
    function _getBatchHead(uint256 tokenId) internal view returns (uint256 tokenIdBatchHead) {
        tokenIdBatchHead = _batchHead.scanForward(tokenId); 
    }

    /**
     * @dev Returns an array of token IDs owned by `owner`.
     *
     * This function scans the ownership mapping and is O(`totalSupply`) in complexity.
     * It is meant to be called off-chain.
     *
     * This function is compatiable with ERC721AQueryable.
     */
    function tokensOfOwner(address owner) external view virtual returns (uint256[] memory) {
        unchecked {
            uint256 tokenIdsIdx;
            uint256 tokenIdsLength = balanceOf(owner);
            uint256[] memory tokenIds = new uint256[](tokenIdsLength);
            for (uint256 i = _startTokenId(); tokenIdsIdx != tokenIdsLength; ++i) {
                if (_exists(i)) {
                    if (ownerOf(i) == owner) {
                        tokenIds[tokenIdsIdx++] = i;
                    }
                }
            }
            return tokenIds;   
        }
    }

    /**
     * @dev Hook that is called before a set of serially-ordered token ids are about to be transferred. This includes minting.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     */
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    function _toString(uint256 value) internal pure virtual returns (string memory str) {
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but
            // we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.
            // We will need 1 word for the trailing zeros padding, 1 word for the length,
            // and 3 words for a maximum of 78 digits. Total: 5 * 0x20 = 0xa0.
            let m := add(mload(0x40), 0xa0)
            // Update the free memory pointer to allocate.
            mstore(0x40, m)
            // Assign the `str` to the end.
            str := sub(m, 0x20)
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end of the memory to calculate the length later.
            let end := str

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 {} {
                str := sub(str, 1)
                // Write the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))
                // Keep dividing `temp` until zero.
                temp := div(temp, 10)
                // prettier-ignore
                if iszero(temp) { break }
            }

            let length := sub(end, str)
            // Move the pointer 32 bytes leftwards to make room for the length.
            str := sub(str, 0x20)
            // Store the length.
            mstore(str, length)
        }
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    // =============================================================
    //                    ADDRESS DATA EXTENSION
    // =============================================================

    // Mapping owner address to address data
    mapping(address => AddressData) _addressData;

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) 
        public 
        view 
        virtual 
        override 
        returns (uint) 
    {
        require(owner != address(0), "ERC721Psi: balance query for the zero address");
        return uint256(_addressData[owner].balance);   
    }

    /**
     * @dev Hook that is called after a set of serially-ordered token ids have been transferred. This includes
     * minting.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     */
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 /* startTokenId */,
        uint256 quantity
    ) internal virtual {
        require(quantity < 2 ** 64);
        uint64 _quantity = uint64(quantity);

        // On transfer and burn
        if(from != address(0)){
            _addressData[from].balance -= _quantity;                                // cold SSTORE(2)
        } else {
            // On mint
            _addressData[to].numberMinted += _quantity;                             // cold SSTORE(2), if balance is 0 SSTORE(1)
        }

        // On transfer and mint
        if(to != address(0)){
            _addressData[to].balance += _quantity;                                  // cold SSTORE(2), if balance is 0 SSTORE(1)
        } else {
            // On burn
            _addressData[from].numberBurned += _quantity;                           // cold SSTORE(2), if balance is 0 SSTORE(1)
        }
    }

    // =============================================================
    //                      BURNABLE EXTENSION
    // =============================================================

    BitMaps.BitMap private _burnedToken;

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address from = ownerOf(tokenId);
        _beforeTokenTransfers(from, address(0), tokenId, 1);
        _burnedToken.set(tokenId);
        
        emit Transfer(from, address(0), tokenId);

        _afterTokenTransfers(from, address(0), tokenId, 1);
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool){
        if(_burnedToken.get(tokenId)) {                                             // cold SLOAD
            return false;
        } 
        return tokenId < _nextTokenId() && _startTokenId() <= tokenId;              // cold SLOAD
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalMinted() - _burned();
    }

    /**
     * @dev Returns number of token burned.
     */
    function _burned() internal view returns (uint256 burned){
        uint256 startBucket = _startTokenId() >> 8;
        uint256 lastBucket = (_nextTokenId() >> 8) + 1;

        for(uint256 i=startBucket; i < lastBucket; i++) {
            uint256 bucket = _burnedToken.getBucket(i);
            burned += _popcount(bucket);
        }
    }

    /**
     * @dev Returns number of set bits.
     */
    function _popcount(uint256 x) private pure returns (uint256 count) {
        unchecked{
            for (count = 0; x != 0; count++)
                x &= x - 1;
        }
    }
}