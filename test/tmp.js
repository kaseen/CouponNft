const coupon = artifacts.require('Coupon');

contract("FactoryERC1155", async (accounts) => {

	let contractInstance = null;

	before(async () => {
		contractInstance = await coupon.deployed();
	})

	it('should mint both soulbind and nonsoulbind tokens', async () => {
		// Mint 5 coupons to account[0] and 4 to account[1]
		await contractInstance.mintSoulbind(accounts[0], 2, 10000);
		await contractInstance.mintNonSoulbind(accounts[1], 1, 5000);
	})

	it('coupon details of', async () => {
		// ID:	0	1	2	3
		//		a0	0	a2	ptr
		const tx = await contractInstance.ownershipOf(0);
		const tx2 = await contractInstance.ownershipOf(1);
		const tx3 = await contractInstance.ownershipOf(2);

		console.log(tx);
		console.log(tx2);
		console.log(tx3);
	});

});