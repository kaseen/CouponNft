const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { expect } = require('chai');

// TODO: expect to emit
// TODO: after transfer or mint to equal balance 1
describe('Coupon', () => {
	const deploy = async () => {
		const [owner, altAcc] = await hre.ethers.getSigners();

		const Coupon = await hre.ethers.getContractFactory('Coupon');
		const CouponContract = await Coupon.deploy('NAME_TEST', 'SYMBOL_TEST');

		const ERC721Receiver = await hre.ethers.getContractFactory('ERC721Receiver');
		const ERC721ReceiverContract = await ERC721Receiver.deploy();

		const NonERC721Receiver = await hre.ethers.getContractFactory('NonERC721Receiver');
		const NonERC721ReceiverContract = await NonERC721Receiver.deploy();

		await CouponContract.mintSoulbind(owner.address, 2, 10, 100);
		const nextTokenId = await CouponContract.totalSupply();

		return { CouponContract, ERC721ReceiverContract, NonERC721ReceiverContract, owner, altAcc, nextTokenId };
	}

	describe('Minting', () => {
		it('Should revert with MintInvalidPercentage', async () => {
			const { CouponContract, owner } = await loadFixture(deploy);

			await expect(CouponContract.mintSoulbind(owner.address, 1, 1000, 10))
				.to.be.revertedWithCustomError(CouponContract, 'MintInvalidPercentage');

		});
		it('Should revert with MintInvalidDays', async () => {
			const { CouponContract, owner } = await loadFixture(deploy);

			await expect(CouponContract.mintSoulbind(owner.address, 1, 10, 100000))
				.to.be.revertedWithCustomError(CouponContract, 'MintInvalidDays');
		});		
	});

	describe('Transfer', () => {
		it('Should revert with TransferSoulbindToken', async () => {
			const { CouponContract, owner, altAcc, nextTokenId } = await loadFixture(deploy);

			await CouponContract.mintSoulbind(owner.address, 1, 10, 100);
	
			await expect(CouponContract.transferFrom(owner.address, altAcc.address, nextTokenId))
				.to.be.revertedWithCustomError(CouponContract, 'TransferSoulbindToken');
		});
	});

	describe('Other', () => {
		it('Should revert OwnerQueryForNonexistentToken', async () => {
			const { CouponContract, nextTokenId } = await loadFixture(deploy);

			// Using coupon that has not yet been minted
			await expect(CouponContract.useCoupon(nextTokenId))
				.to.be.revertedWithCustomError(CouponContract, 'OwnerQueryForNonexistentToken');
		})

		it('Should revert CouponExpired', async () => {
			const { CouponContract, owner, nextTokenId } = await loadFixture(deploy);

			await CouponContract.mintSoulbind(owner.address, 1, 10, 0);
			// Wait 1 second
			await new Promise(resolve => setTimeout(resolve, Number(1)*1000));

			await expect(CouponContract.connect(owner).useCoupon(nextTokenId))
				.to.be.revertedWithCustomError(CouponContract, 'CouponExpired');
		});

		it('Should revert NotOwner', async () => {
			const { CouponContract, owner, altAcc } = await loadFixture(deploy);

			await CouponContract.mintSoulbind(owner.address, 1, 10, 10);

			await expect(CouponContract.connect(altAcc).useCoupon(0))
				.to.be.revertedWithCustomError(CouponContract, 'NotOwner');
		});
	});

	describe('ERC721A__IERC721Receiver', () => {
		it('Should safeMint to ERC721Receiver contract', async () => {
			const { CouponContract, ERC721ReceiverContract } = await loadFixture(deploy);

			await CouponContract.safeMintSoulbind(ERC721ReceiverContract.address, 1, 10, 10);
		});

		it('Should revert safeMint to NonERC721Receiver contract', async () => {
			const { CouponContract, NonERC721ReceiverContract } = await loadFixture(deploy);

			await expect(CouponContract.safeMintSoulbind(NonERC721ReceiverContract.address, 1, 10, 10))
				.to.be.revertedWithCustomError(CouponContract, 'TransferToNonERC721ReceiverImplementer');
		});
		
		it('Should safeTransfer to ERC721Receiver contract', async () => {
			const { CouponContract, ERC721ReceiverContract, owner, nextTokenId } = await loadFixture(deploy);

			await CouponContract.mintNonSoulbind(owner.address, 1, 10, 10);
			await CouponContract['safeTransferFrom(address,address,uint256)']
				(owner.address, ERC721ReceiverContract.address, nextTokenId);
		});

		it('Should revert safeTransfer to NonERC721Receiver contract', async () => {
			const { CouponContract, NonERC721ReceiverContract, owner, nextTokenId } = await loadFixture(deploy);

			await CouponContract.mintNonSoulbind(owner.address, 1, 10, 10);
			await expect(CouponContract['safeTransferFrom(address,address,uint256)']
				(owner.address, NonERC721ReceiverContract.address, nextTokenId))
				.to.be.rejectedWith(CouponContract, 'TransferToNonERC721ReceiverImplementer');
		});
	});

	describe('Approval', () => {
		it('bla', async () => {
			const { CouponContract } = await loadFixture(deploy);


		});
	});
});