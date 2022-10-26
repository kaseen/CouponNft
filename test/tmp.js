const Coupon = artifacts.require('Coupon');
const { expect } = require('chai');

contract('Coupon', async (accounts) => {

	let contractInstance = null;

	beforeEach(async () => {
		contractInstance = await Coupon.deployed();
	});

	xit('should revert invalid minting', async () => {
		// Revert error MintInvalidPercentage()
		await expect(contractInstance.mintSoulbind(accounts[0], 1, 1000, 10), 'RuntimeError');

		// Revert error MintInvalidDays()
		await expect(contractInstance.mintSoulbind(accounts[0], 1, 10, 100000), 'RuntimeError');
	});

	xit('should revert transfering soulbind token', async () => {
		await contractInstance.mintSoulbind(accounts[0], 1, 10, 200);
		// Revert error TransferSoulbindToken()
		await expect(contractInstance.transferFrom(accounts[0], accounts[1], 0), 'RuntimeError');
	});

	xit('should revert expired token', async () => {
		await contractInstance.mintSoulbind(accounts[0], 1, 10, 0);
		// Wait 5 seconds
		await new Promise(resolve => setTimeout(resolve, Number(5)*1000));
		// Revert error CouponExpired()
		await expect(contractInstance.useCoupon(0), 'RuntimeError');
	});

	xit('should revert using not ownable coupon', async () => {
		await contractInstance.mintSoulbind(accounts[0], 1, 10, 10);
		// Revert error NotOwner()
		await expect(contractInstance.useCoupon(0, { from: accounts[1] }), 'RuntimeError');
	});

	it('should transfer and then use coupon', async () => {
		await contractInstance.mintNonSoulbind(accounts[0], 1, 10, 10);
		await contractInstance.transferFrom(accounts[0], accounts[1], 0);
		// Wait 5 seconds
		await new Promise(resolve => setTimeout(resolve, Number(5)*1000));
		await contractInstance.useCoupon(0, { from: accounts[1] });
	});

});