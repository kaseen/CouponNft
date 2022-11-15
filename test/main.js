const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { setupMainContractForTesting } = require('../scripts/setupForTesting');
const { expect } = require('chai');

describe('Main', () => {
	it('Should emit CouponMinted', async () => {
		const { MainContract, owner } = await loadFixture(setupMainContractForTesting);

		await expect(MainContract.buyProduct(0, 0, { value: ethers.utils.parseUnits('1') }))
			.to.emit(MainContract, 'CouponMinted')
			.withArgs(owner.address);
	});
	it('Should use Coupon', async () => {
		const { MainContract, CouponContract } = await loadFixture(setupMainContractForTesting); 

		await MainContract.buyProduct(0, 0, { value: ethers.utils.parseUnits('1') });
		await CouponContract.approve(MainContract.address, 1);

		await expect(MainContract.buyProduct(1, 1, { value: ethers.utils.parseUnits('1') }))
			.to.emit(MainContract, 'CouponUsed')
	});
});