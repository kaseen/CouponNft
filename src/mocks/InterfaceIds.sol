//SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
}

interface IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes calldata data) external;
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external;
}

interface IERC1155MetadataURI is IERC1155 {
    function uri(uint256 id) external view returns (string memory);
}

interface IERC1155Delta {
    error ApprovalCallerNotOwnerNorApproved();
    error BalanceQueryForZeroAddress();
    error MintToZeroAddress();
    error MintZeroQuantity();
    error BurnFromZeroAddress();
    error BurnFromNonOnwerAddress();
    error TransferCallerNotOwnerNorApproved();
    error TransferFromIncorrectOwnerOrInvalidAmount();
    error TransferToNonERC1155ReceiverImplementer();
    error TransferToZeroAddress();
    error InputLengthMistmatch();
    function isOwnerOf(address account, uint256 id) external view returns(bool);
}

contract InterfaceIds {

    // 0x01ffc9a7
    function __ERC165__interfaceId() public pure returns (bytes4) {
        return type(IERC165).interfaceId;
    }

    // 0x80ac58cd
    function __ERC721__interfaceId() public pure returns (bytes4) {
        return type(IERC721).interfaceId;
    }

    // 0x5b5e139f
    function __ERC721Metadata__interfaceId() public pure returns (bytes4) {
        return type(IERC721Metadata).interfaceId;
    }

    // 0x780e9d63
    function __ERC721Enumerable__interfaceId() public pure returns (bytes4) {
        return type(IERC721Enumerable).interfaceId;
    }

    // 0xd9b67a26
    function __ERC1155__interfaceId() public pure returns (bytes4) {
        return type(IERC1155).interfaceId;
    }

    // 0x0e89341c
    function __ERC1155MetadataURI__interfaceId() public pure returns (bytes4) {
        return type(IERC1155MetadataURI).interfaceId;
    }

    // 0xc5b8f772
    function __ERC1155Delta__interfaceId() public pure returns (bytes4) {
        return type(IERC1155Delta).interfaceId;
    }
}