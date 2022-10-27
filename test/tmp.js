const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { expect } = require('chai');

// TODO: expect to emit
describe('Coupon', () => {
	const deploy = async () => {
		const [owner, altAcc] = await hre.ethers.getSigners();

		const Coupon = await hre.ethers.getContractFactory('Coupon');
		const CouponContract = await Coupon.deploy('NAME_TEST', 'SYMBOL_TEST');

		return { CouponContract, owner, altAcc };
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
			const { CouponContract, owner, altAcc } = await loadFixture(deploy);

			await CouponContract.mintSoulbind(owner.address, 1, 10, 100);
	
			await expect(CouponContract.transferFrom(owner.address, altAcc.address, 0))
				.to.be.revertedWithCustomError(CouponContract, 'TransferSoulbindToken');
		});
	});

	describe('Other', () => {
		it('Should revert OwnerQueryForNonexistentToken', async () => {
			const { CouponContract } = await loadFixture(deploy);

			// Using coupon that has not yet been minted
			await expect(CouponContract.useCoupon(0))
				.to.be.revertedWithCustomError(CouponContract, 'OwnerQueryForNonexistentToken');
		})

		it('Should revert CouponExpired', async () => {
			const { CouponContract, owner } = await loadFixture(deploy);

			await CouponContract.mintSoulbind(owner.address, 1, 10, 0);
			// Wait 1 second
			await new Promise(resolve => setTimeout(resolve, Number(1)*1000));

			await expect(CouponContract.connect(owner).useCoupon(0))
				.to.be.revertedWithCustomError(CouponContract, 'CouponExpired');
		});

		it('Should revert NotOwner', async () => {
			const { CouponContract, owner, altAcc } = await loadFixture(deploy);

			await CouponContract.mintSoulbind(owner.address, 1, 10, 10);

			await expect(CouponContract.connect(altAcc).useCoupon(0))
				.to.be.revertedWithCustomError(CouponContract, 'NotOwner');
		});
	});

});