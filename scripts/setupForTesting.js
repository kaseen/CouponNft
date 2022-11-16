const setupShopContractForTesting = async () => {

	const [owner, altAcc] = await hre.ethers.getSigners();

	const Shop = await hre.ethers.getContractFactory('Shop');
	const ShopContract = await Shop.deploy();
	await ShopContract.deployed();

	const couponAddress = await ShopContract.getCouponContractAddress();
	const CouponContract = await hre.ethers.getContractAt('Coupon', couponAddress);

	// Arrange for minting coupon
	await ShopContract.buyProduct(0, 0, { value: ethers.utils.parseUnits('1') });
	// Approve minted coupon
	await CouponContract.approve(ShopContract.address, 1);

	const ID_COUPON = 1;

	return { ShopContract, CouponContract, owner, altAcc, ID_COUPON };
}

const setupCouponContractForTesting = async () => {

	const [owner, altAcc] = await hre.ethers.getSigners();

	const Coupon = await hre.ethers.getContractFactory('Coupon');
	const CouponContract = await Coupon.deploy('NAME_TEST', 'SYMBOL_TEST');
	await CouponContract.deployed();

	const ERC721Receiver = await hre.ethers.getContractFactory('ERC721Receiver');
	const ERC721ReceiverContract = await ERC721Receiver.deploy();
	await ERC721ReceiverContract.deployed();

	const NonERC721Receiver = await hre.ethers.getContractFactory('NonERC721Receiver');
	const NonERC721ReceiverContract = await NonERC721Receiver.deploy();
	await NonERC721ReceiverContract.deployed();

	await CouponContract.mintSoulbind(altAcc.address, 1, 10, 100);
	await CouponContract.mintNonSoulbind(altAcc.address, 1, 10, 100);

	const ID_SOULDBIND = 1;
	const ID_NONSOULBIND = 2;
	const nextTokenId = Number(await CouponContract.totalSupply()) + 1;

	return { 
		CouponContract,
		ERC721ReceiverContract,
		NonERC721ReceiverContract,
		owner,
		altAcc, 
		ID_SOULDBIND,
		ID_NONSOULBIND,
		nextTokenId
	};
}

module.exports = {
	setupShopContractForTesting,
	setupCouponContractForTesting
}
