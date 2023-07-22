// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC721A } from 'src/ERC721A.sol';
import { User } from './User.sol';
import 'forge-std/Test.sol';
import 'forge-std/console.sol';

contract ERC721ATest is ERC721A, Test {

    constructor() ERC721A('Test', 'Test'){}

    User public user1;
    User public user2;

    function setUp() public {
        user1 = new User(address(this));
        user2 = new User(address(this));

        // Setup
        super._mint(address(user1), 2, false, 10, 100);
        super._mint(address(user2), 1, false, 10, 100);
        super._mint(address(user1), 2, false, 10, 100);

        user1.approveTo(address(user2), 1);
        user2.approveTo(address(user1), 3);

        /*
        console.log('===================================================');
        console.log('Address this: %s', address(this));
        console.log('Address user1: %s', address(user1));
        console.log('Address user2: %s', address(user2));
        console.log('===================================================');
        console.log();
        */
    }

    function testMintSingle() public {
        super._mint(msg.sender, 1, true, 10, 50);
    }

    function testMintMultiple() public {
        super._mint(msg.sender, 6, true, 10, 50);
    }

    function testTransferSingle() public {
        user2.transferTo(address(user1), 3);
    }

    function testTransferMultiple() public {
        user1.transferTo(address(user2), 1);
    }

    function printTokenInfo(uint256 tokenId) public {
        TokenOwnership memory token = _ownershipOf(tokenId);
        console.log('===================== ID: %s =======================', tokenId);
        console.log('Address: %s', token.addr);
        console.log('startTimestamp: %s', token.startTimestamp);
        console.log('burned: %s', token.burned);
        console.log('soulbound: %s', token.soulbound);
        console.log('percentage: %s', token.percentage);
        console.log('daysValid: %s', token.daysValid);
        console.log('===================================================');
    }

    function Print() public {
        // getNextFlag
    }
}
