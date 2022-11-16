const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { setupShopContractForTesting } = require('../scripts/setupForTesting');
const { expect } = require('chai');

describe('Contract: Shop.sol', () => {
	it('Should emit CouponMinted', async () => {
		const { ShopContract, owner } = await loadFixture(setupShopContractForTesting);

		await expect(ShopContract.buyProduct(0, 0, { value: ethers.utils.parseUnits('1') }))
			.to.emit(ShopContract, 'CouponMinted')
			.withArgs(owner.address);
	});
	it('Should revert ProductPriceNotReducible', async () => {
		const { ShopContract, ID_COUPON } = await loadFixture(setupShopContractForTesting);

		await expect(ShopContract.buyProduct(0, ID_COUPON, { value: ethers.utils.parseUnits('1') }))
			.to.revertedWithCustomError(ShopContract, 'ProductPriceNotReducible');
	});
	it('Should use Coupon', async () => {
		const { ShopContract, ID_COUPON } = await loadFixture(setupShopContractForTesting); 

		//await ShopContract.buyProduct(0, 0, { value: ethers.utils.parseUnits('1') });
		//await CouponContract.approve(ShopContract.address, 1);

		await expect(ShopContract.buyProduct(1, ID_COUPON, { value: ethers.utils.parseUnits('1') }))
			.to.emit(ShopContract, 'CouponUsed');
	});
});