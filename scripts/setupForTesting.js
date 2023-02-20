const setupShopContractForTesting = async () => {

	const [owner, altAcc] = await hre.ethers.getSigners();

	const Shop = await hre.ethers.getContractFactory('Shop');
	const ShopContract = await Shop.deploy('', '', '');
	await ShopContract.deployed();

	const couponAddress = await ShopContract.getCouponContractAddress();
	const CouponContract = await hre.ethers.getContractAt('Coupon', couponAddress);

	// Arrange for minting coupon
	await ShopContract["buyProduct(uint256)"](0, { value: ethers.utils.parseUnits('1') });

	// Approve minted coupon
	await CouponContract.approve(ShopContract.address, 1);

	const ID_COUPON = 1;

	return { ShopContract, CouponContract, owner, altAcc, ID_COUPON };
}

const setupCouponContractForTesting = async () => {

	const [owner, altAcc] = await hre.ethers.getSigners();

	const Coupon = await hre.ethers.getContractFactory('Coupon');
	const CouponContract = await Coupon.deploy('', '', '');
	await CouponContract.deployed();

	const ERC721Receiver = await hre.ethers.getContractFactory('ERC721Receiver');
	const ERC721ReceiverContract = await ERC721Receiver.deploy();
	await ERC721ReceiverContract.deployed();

	const NonERC721Receiver = await hre.ethers.getContractFactory('NonERC721Receiver');
	const NonERC721ReceiverContract = await NonERC721Receiver.deploy();
	await NonERC721ReceiverContract.deployed();

	await CouponContract.mintSoulbound(altAcc.address, 1, 10, 100);
	await CouponContract.mintNonSoulbound(altAcc.address, 1, 10, 100);

	const ID_SOULBOUND = 1;
	const ID_NONSOULBOUND = 2;
	const nextTokenId = Number(await CouponContract.totalSupply()) + 1;

	return { 
		CouponContract,
		ERC721ReceiverContract,
		NonERC721ReceiverContract,
		owner,
		altAcc, 
		ID_SOULBOUND,
		ID_NONSOULBOUND,
		nextTokenId
	};
}

module.exports = {
	setupShopContractForTesting,
	setupCouponContractForTesting
}
