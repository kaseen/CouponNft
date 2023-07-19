require('@nomicfoundation/hardhat-toolbox');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: '0.8.17',
    gasReporter: {
        enabled: true,
        noColors: true,
        outputFile: 'gasReport.txt'
    },
};
