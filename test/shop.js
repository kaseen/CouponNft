const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { setupShopContractForTesting } = require('../scripts/setupForTesting');
const { expect } = require('chai');

describe('Contract: Shop.sol', () => {

	it('Should cancel burnt coupon if not enough funds', async () => {
		const { ShopContract, CouponContract, owner, ID_COUPON } = await loadFixture(setupShopContractForTesting);

		await expect(ShopContract["buyProduct(uint256,uint256)"](1, ID_COUPON, { value: ethers.utils.parseUnits('0.1') }))
			.to.emit(ShopContract, 'CouponUsed').withArgs(owner.address, ID_COUPON)
			.to.revertedWithCustomError(ShopContract, 'NotEnoughFunds');

		expect(await CouponContract.exists(ID_COUPON))
			.to.be.equal(true);
	});

	it('Should emit 2xTransfer', async () => {
		const { ShopContract, CouponContract, buyProducts, owner } = await loadFixture(setupShopContractForTesting);

		await buyProducts(5);
		await expect(ShopContract.mintCoupon())
			.to.emit(CouponContract, 'Transfer').withArgs(ethers.constants.AddressZero, owner.address, 2)
			.to.emit(CouponContract, 'Transfer').withArgs(ethers.constants.AddressZero, owner.address, 3);
	});

	it('Should use Coupon', async () => {
		const { ShopContract, CouponContract, owner, ID_COUPON } = await loadFixture(setupShopContractForTesting); 

		await expect(ShopContract["buyProduct(uint256,uint256)"](1, ID_COUPON, { value: ethers.utils.parseUnits('1') }))
			.to.emit(CouponContract, 'Transfer').withArgs(owner.address, ethers.constants.AddressZero, ID_COUPON)
			.to.emit(ShopContract, 'CouponUsed').withArgs(owner.address, ID_COUPON);
	});

	it('Should revert ProductPriceNotReducible', async () => {
		const { ShopContract, ID_COUPON } = await loadFixture(setupShopContractForTesting);

		await expect(ShopContract["buyProduct(uint256,uint256)"](0, ID_COUPON, { value: ethers.utils.parseUnits('1') }))
			.to.revertedWithCustomError(ShopContract, 'ProductPriceNotReducible');
	});

	it('Should revert using same Coupon twice', async () => {
		const { ShopContract, CouponContract, ID_COUPON } = await loadFixture(setupShopContractForTesting); 

		await expect(ShopContract["buyProduct(uint256,uint256)"](1, ID_COUPON, { value: ethers.utils.parseUnits('1') }))
			.to.emit(ShopContract, 'CouponUsed');

		await expect(ShopContract["buyProduct(uint256,uint256)"](1, ID_COUPON, { value: ethers.utils.parseUnits('1') }))
			.to.revertedWithCustomError(CouponContract, 'OwnerQueryForNonexistentToken');
	});
});