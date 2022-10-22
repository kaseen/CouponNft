const coupon = artifacts.require('Coupon');

contract("FactoryERC1155", async (accounts) => {

	let contractInstance = null;

	before(async () => {
		contractInstance = await coupon.deployed();
	})

	it('should mint both soulbind and nonsoulbind tokens', async () => {
		// Mint 5 coupons to account[0] and 4 to account[1]
		await contractInstance.mintSoulbind(accounts[0], 5, 0, 0);
		await contractInstance.mintNonSoulbind(accounts[1], 4, 10, 100);
	})

	it('transfer token', async () => {
		// ID:	0	1	2	3	4	5	6	7	8	9	10
		//		a0	0	0	0	0	a1	0	0	0	0	ptr
		let tx = await contractInstance.ownershipOf(1);
		console.log(tx);

		await contractInstance.transferFrom(accounts[0], accounts[1], 1);
		
		tx = await contractInstance.ownershipOf(1);
		console.log(tx);
	});

});