const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { deployAndSetup } = require('../scripts/deployAndSetup');
const { expect } = require('chai');

// TODO: expect to emit
// TODO: after transfer or mint to equal balance 1
describe('Coupon', () => {
	
	describe('Minting', () => {
		it('Should revert with MintInvalidPercentage', async () => {
			const { CouponContract, owner } = await loadFixture(deployAndSetup);

			await expect(CouponContract.mintSoulbind(owner.address, 1, 1000, 10))
				.to.be.revertedWithCustomError(CouponContract, 'MintInvalidPercentage');

		});
		it('Should revert with MintInvalidDays', async () => {
			const { CouponContract, owner } = await loadFixture(deployAndSetup);

			await expect(CouponContract.mintSoulbind(owner.address, 1, 10, 100000))
				.to.be.revertedWithCustomError(CouponContract, 'MintInvalidDays');
		});		
	});

	describe('Transfer', () => {
		it('Should revert with TransferSoulbindToken', async () => {
			const { CouponContract, owner, altAcc, ID_SOULDBIND } = await loadFixture(deployAndSetup);
	
			await expect(CouponContract.transferFrom(owner.address, altAcc.address, ID_SOULDBIND))
				.to.be.revertedWithCustomError(CouponContract, 'TransferSoulbindToken');
		});
	});

	describe('Other', () => {
		it('Should revert OwnerQueryForNonexistentToken', async () => {
			const { CouponContract, nextTokenId } = await loadFixture(deployAndSetup);

			// Using coupon that has not yet been minted
			await expect(CouponContract.useCoupon(nextTokenId))
				.to.be.revertedWithCustomError(CouponContract, 'OwnerQueryForNonexistentToken');
		})

		it('Should revert CouponExpired', async () => {
			const { CouponContract, owner, nextTokenId } = await loadFixture(deployAndSetup);

			await CouponContract.mintSoulbind(owner.address, 1, 10, 0);
			// Wait 1 second
			await new Promise(resolve => setTimeout(resolve, Number(1)*1000));

			await expect(CouponContract.connect(owner).useCoupon(nextTokenId))
				.to.be.revertedWithCustomError(CouponContract, 'CouponExpired');
		});

		it('Should revert NotOwner', async () => {
			const { CouponContract, altAcc, ID_NONSOULBIND } = await loadFixture(deployAndSetup);

			await expect(CouponContract.connect(altAcc).useCoupon(ID_NONSOULBIND))
				.to.be.revertedWithCustomError(CouponContract, 'NotOwner');
		});
	});

	describe('ERC721A__IERC721Receiver', () => {
		it('Should safeMint to ERC721Receiver contract', async () => {
			const { CouponContract, ERC721ReceiverContract } = await loadFixture(deployAndSetup);

			await CouponContract.safeMintSoulbind(ERC721ReceiverContract.address, 1, 10, 10);
		});

		it('Should revert safeMint to NonERC721Receiver contract', async () => {
			const { CouponContract, NonERC721ReceiverContract } = await loadFixture(deployAndSetup);

			await expect(CouponContract.safeMintSoulbind(NonERC721ReceiverContract.address, 1, 10, 10))
				.to.be.revertedWithCustomError(CouponContract, 'TransferToNonERC721ReceiverImplementer');
		});
		
		it('Should safeTransfer to ERC721Receiver contract', async () => {
			const { CouponContract, ERC721ReceiverContract, owner, nextTokenId } = await loadFixture(deployAndSetup);

			await CouponContract.mintNonSoulbind(owner.address, 1, 10, 10);
			await CouponContract['safeTransferFrom(address,address,uint256)']
				(owner.address, ERC721ReceiverContract.address, nextTokenId);
		});

		it('Should revert safeTransfer to NonERC721Receiver contract', async () => {
			const { CouponContract, NonERC721ReceiverContract, owner, nextTokenId } = await loadFixture(deployAndSetup);

			await CouponContract.mintNonSoulbind(owner.address, 1, 10, 10);
			await expect(CouponContract['safeTransferFrom(address,address,uint256)']
				(owner.address, NonERC721ReceiverContract.address, nextTokenId))
				.to.be.rejectedWith(CouponContract, 'TransferToNonERC721ReceiverImplementer');
		});
	});

	describe('Approval', () => {
		it('Should approve and transfer', async () => {
			const { CouponContract, owner, altAcc, ID_NONSOULBIND } = await loadFixture(deployAndSetup);

			await expect(await CouponContract.getApproved(ID_NONSOULBIND))
				.to.be.equal('0x0000000000000000000000000000000000000000');

			await CouponContract.approve(altAcc.address, ID_NONSOULBIND);

			await expect(await CouponContract.getApproved(ID_NONSOULBIND))
				.to.be.equal(altAcc.address);

			await CouponContract.connect(altAcc).transferFrom(owner.address, altAcc.address, ID_NONSOULBIND);
		});
		it('Sould operator approve and transfer', async () => {
			const { CouponContract, owner, altAcc, nextTokenId } = await loadFixture(deployAndSetup);

			await CouponContract.mintNonSoulbind(owner.address, 2, 10, 100);

			await expect(await CouponContract.isApprovedForAll(owner.address, altAcc.address))
				.to.be.equal(false);

			await CouponContract.setApprovalForAll(altAcc.address, true);

			await expect(await CouponContract.isApprovedForAll(owner.address, altAcc.address))
				.to.be.equal(true);

			await CouponContract.connect(altAcc).transferFrom(owner.address, altAcc.address, nextTokenId);
			await CouponContract.connect(altAcc).transferFrom(owner.address, altAcc.address, Number(nextTokenId) + 1);
		});
	});
});