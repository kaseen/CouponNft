const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { setupCouponContractForTesting } = require('../scripts/setupForTesting');
const { expect } = require('chai');

describe('Contract: Coupon.sol', () => {
	describe('Minting', () => {
		it('Should revert with MintInvalidPercentage', async () => {
			const { CouponContract, owner } = await loadFixture(setupCouponContractForTesting);

			await expect(CouponContract.mintSoulbound(owner.address, 1, 1000, 10))
				.to.be.revertedWithCustomError(CouponContract, 'MintInvalidPercentage');

		});
		it('Should revert with MintInvalidDays', async () => {
			const { CouponContract, owner } = await loadFixture(setupCouponContractForTesting);

			await expect(CouponContract.mintSoulbound(owner.address, 1, 10, 100000))
				.to.be.revertedWithCustomError(CouponContract, 'MintInvalidDays');
		});		
	});

	describe('Transfer', () => {
		it('Should revert with TransferSoulboundToken', async () => {
			const { CouponContract, owner, altAcc, ID_SOULBOUND } = await loadFixture(setupCouponContractForTesting);
	
			await expect(CouponContract.transferFrom(altAcc.address, owner.address, ID_SOULBOUND))
				.to.be.revertedWithCustomError(CouponContract, 'TransferSoulboundToken');
		});
	});

	describe('Other', () => {
		it('Should revert OwnerQueryForNonexistentToken', async () => {
			const { CouponContract, nextTokenId } = await loadFixture(setupCouponContractForTesting);

			// Using coupon that has not yet been minted
			await expect(CouponContract.useCoupon(nextTokenId))
				.to.be.revertedWithCustomError(CouponContract, 'OwnerQueryForNonexistentToken');
		});
		it('Should revert CouponExpired', async () => {
			const { CouponContract, owner, nextTokenId } = await loadFixture(setupCouponContractForTesting);

			await CouponContract.mintSoulbound(owner.address, 1, 10, 0);
			// Wait 1 second
			await new Promise(resolve => setTimeout(resolve, Number(1)*1000));

			await expect(CouponContract.connect(owner).useCoupon(nextTokenId))
				.to.be.revertedWithCustomError(CouponContract, 'CouponExpired');
		});
		it('Should revert NotOwner', async () => {
			const { CouponContract, ID_NONSOULBOUND } = await loadFixture(setupCouponContractForTesting);

			await expect(CouponContract.useCoupon(ID_NONSOULBOUND))
				.to.be.revertedWithCustomError(CouponContract, 'NotApproved');
		});
	});

	describe('ERC721A__IERC721Receiver', () => {
		it('Should safeMint to ERC721Receiver contract', async () => {
			const { CouponContract, ERC721ReceiverContract, nextTokenId } = await loadFixture(setupCouponContractForTesting);

			await expect(CouponContract.safeMintSoulbound(ERC721ReceiverContract.address, 1, 10, 10))
				.to.emit(CouponContract, 'Transfer')
				.withArgs(ethers.constants.AddressZero, ERC721ReceiverContract.address, nextTokenId);
		});
		it('Should revert safeMint to NonERC721Receiver contract', async () => {
			const { CouponContract, NonERC721ReceiverContract } = await loadFixture(setupCouponContractForTesting);

			await expect(CouponContract.safeMintSoulbound(NonERC721ReceiverContract.address, 1, 10, 10))
				.to.be.revertedWithCustomError(CouponContract, 'TransferToNonERC721ReceiverImplementer');
		});
		it('Should safeTransfer to ERC721Receiver contract', async () => {
			const { CouponContract, ERC721ReceiverContract, owner, nextTokenId } = await loadFixture(setupCouponContractForTesting);

			await CouponContract.mintNonSoulbound(owner.address, 1, 10, 10);
			await expect(CouponContract['safeTransferFrom(address,address,uint256)']
				(owner.address, ERC721ReceiverContract.address, nextTokenId))
				.to.emit(CouponContract, 'Transfer')
				.withArgs(owner.address, ERC721ReceiverContract.address, nextTokenId);
		});
		it('Should revert safeTransfer to NonERC721Receiver contract', async () => {
			const { CouponContract, NonERC721ReceiverContract, owner, nextTokenId } = await loadFixture(setupCouponContractForTesting);

			await CouponContract.mintNonSoulbound(owner.address, 1, 10, 10);
			await expect(CouponContract['safeTransferFrom(address,address,uint256)']
				(owner.address, NonERC721ReceiverContract.address, nextTokenId))
				.to.be.rejectedWith(CouponContract, 'TransferToNonERC721ReceiverImplementer');
		});
	});

	describe('Approval', () => {
		it('Should approve and transfer', async () => {
			const { CouponContract, owner, altAcc, ID_NONSOULBOUND } = await loadFixture(setupCouponContractForTesting);

			await expect(await CouponContract.getApproved(ID_NONSOULBOUND))
				.to.be.equal(ethers.constants.AddressZero);

			await expect(CouponContract.connect(altAcc).approve(owner.address, ID_NONSOULBOUND))
				.to.emit(CouponContract, 'Approval')
				.withArgs(altAcc.address, owner.address, ID_NONSOULBOUND);

			await expect(await CouponContract.getApproved(ID_NONSOULBOUND))
				.to.be.equal(owner.address);

			await expect(CouponContract.transferFrom(altAcc.address, owner.address, ID_NONSOULBOUND))
				.to.emit(CouponContract, 'Transfer')
				.withArgs(altAcc.address, owner.address, ID_NONSOULBOUND);
		});
		it('Sould operator approve and transfer', async () => {
			const { CouponContract, owner, altAcc, nextTokenId } = await loadFixture(setupCouponContractForTesting);

			await expect(CouponContract.mintNonSoulbound(owner.address, nextTokenId, 10, 100))
				.to.emit(CouponContract, 'Transfer')
				.withArgs(ethers.constants.AddressZero, owner.address, nextTokenId);

			await expect(await CouponContract.isApprovedForAll(owner.address, altAcc.address))
				.to.be.equal(false);

			await expect(CouponContract.setApprovalForAll(altAcc.address, true))
				.to.emit(CouponContract, 'ApprovalForAll')
				.withArgs(owner.address, altAcc.address, true);

			await expect(await CouponContract.isApprovedForAll(owner.address, altAcc.address))
				.to.be.equal(true);

			await CouponContract.connect(altAcc).transferFrom(owner.address, altAcc.address, nextTokenId);
			await CouponContract.connect(altAcc).transferFrom(owner.address, altAcc.address, Number(nextTokenId) + 1);
		});
	});
});