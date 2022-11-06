const deployAndSetup = async () => {

	const [owner, altAcc] = await hre.ethers.getSigners();

	const Coupon = await hre.ethers.getContractFactory('Coupon');
	const CouponContract = await Coupon.deploy('NAME_TEST', 'SYMBOL_TEST');

	const ERC721Receiver = await hre.ethers.getContractFactory('ERC721Receiver');
	const ERC721ReceiverContract = await ERC721Receiver.deploy();

	const NonERC721Receiver = await hre.ethers.getContractFactory('NonERC721Receiver');
	const NonERC721ReceiverContract = await NonERC721Receiver.deploy();

	await CouponContract.mintSoulbind(owner.address, 1, 10, 100);
	await CouponContract.mintNonSoulbind(owner.address, 1, 10, 100);
	const ID_SOULDBIND = 0;
	const ID_NONSOULBIND = 1;
	const nextTokenId = await CouponContract.totalSupply();

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
	deployAndSetup
}
