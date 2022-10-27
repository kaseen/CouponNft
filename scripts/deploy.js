const hre = require('hardhat');

async function main() {

	const Coupon = await hre.ethers.getContractFactory('Coupon');
	const coupon = await Coupon.deploy('NAME_TEST', 'SYMBOL_TEST');

	await coupon.deployed();
}

main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
