require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');

const privateKeys = [
  process.env.DEV_PRIVATE1,
  process.env.DEV_PRIVATE2
];

module.exports = {
	plugins: ['truffle-plugin-verify'],

	networks: {
		development: {
			provider: () =>
				new HDWalletProvider({
				privateKeys: privateKeys,
				providerOrUrl: 'http://127.0.0.1:7545',
				chainId: 123
			}),
			network_id: 5777,
			skipDryRun: true
		},
	},

	compilers: {
		solc: {
			version: '0.8.17',
			settings: {
				optimizer: {
					enabled: true,
					runs: 200
				},
			}
		}
	},
};