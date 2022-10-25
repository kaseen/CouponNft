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

	it('should burn token', async () => {
		// Arrange
		await contractInstance.mintSoulbind(accounts[0], 1, 11, 201);
		// Act
		await contractInstance.useCoupon(0);
		// Assert
		const tx = await contractInstance.exists(0);
		expect(tx).to.equal(false);
	});

});