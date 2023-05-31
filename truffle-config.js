const Web3 = require('web3')

const {
  SUPER_ADMIN_PRIVATE_KEY,
  GENERAL_PARTNER_PRIVATE_KEY,
  SUPER_ADMIN_BSC_PRIVATE_KEY,
  INFURA_KEY
} = process.env;

const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  networks: {
    mainnet: {
      provider: () => new HDWalletProvider(SUPER_ADMIN_PRIVATE_KEY, `https://mainnet.infura.io/v3/${INFURA_KEY}`),
      network_id: 1,
      gasPrice: Web3.utils.toWei('55', 'gwei'),
      confirmations: 2,      // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 10000,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true       // Skip dry run before migrations? (default: false for public nets )
    },

    ropsten: {
      provider: () => new HDWalletProvider(SUPER_ADMIN_PRIVATE_KEY, `https://ropsten.infura.io/v3/${INFURA_KEY}`),
      network_id: 3,
      gasPrice: Web3.utils.toWei('70', 'gwei'),
      // gas: 8000000,
      confirmations: 2,       // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 100000,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true        // Skip dry run before migrations? (default: false for public nets )
    },

    kovan: {
      provider: () => new HDWalletProvider(SUPER_ADMIN_PRIVATE_KEY, `https://kovan.infura.io/v3/${INFURA_KEY}`),
      network_id: 42,
      gasPrice: Web3.utils.toWei('40', 'gwei'),
      // gas: 8000000,
      confirmations: 2,       // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 100000,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true        // Skip dry run before migrations? (default: false for public nets )
    },
    bsctestnet: {
      /*
      https://data-seed-prebsc-1-s1.binance.org:8545/
      https://data-seed-prebsc-2-s1.binance.org:8545/
      https://data-seed-prebsc-1-s2.binance.org:8545/
      https://data-seed-prebsc-2-s2.binance.org:8545/
      https://data-seed-prebsc-1-s3.binance.org:8545/
      https://data-seed-prebsc-2-s3.binance.org:8545/
      */

      provider: () => new HDWalletProvider(SUPER_ADMIN_PRIVATE_KEY, `https://data-seed-prebsc-1-s1.binance.org:8545/`),
      network_id: 97,
      confirmations: 5,       // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true,        // Skip dry run before migrations? (default: false for public nets )
      // gas:29000000,
      // production: true
    },
    bscmainnet: {
      provider: () => new HDWalletProvider(SUPER_ADMIN_BSC_PRIVATE_KEY, `https://bsc-dataseed.binance.org/`), // https://bscproject.org/#/rpcserver
      network_id: 56,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    matictestnet: {
      provider: () => new HDWalletProvider(SUPER_ADMIN_PRIVATE_KEY, `https://matic-mumbai.chainstacklabs.com`),//https://rpc-mainnet.maticvigil.com/v1/ddc83a13efa487e53990af87e032489e03438c61
      // provider: () => new HDWalletProvider(SUPER_ADMIN_PRIVATE_KEY, `https://rpc-mumbai.maticvigil.com/v1/ddc83a13efa487e53990af87e032489e03438c61`),//https://rpc-mainnet.maticvigil.com/v1/ddc83a13efa487e53990af87e032489e03438c61
      network_id: 80001,
      gas:20000000,
      confirmations: 20,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    matic: {
      provider: () => new HDWalletProvider(GENERAL_PARTNER_PRIVATE_KEY, 'https://matic-mainnet.chainstacklabs.com'),//`https://polygon-mainnet.g.alchemy.com/v2/wMqeUdJiEXD0tS9gwZgwD9wEDuVTkXH3`),//https://rpc-mainnet.maticvigil.com/v1/ddc83a13efa487e53990af87e032489e03438c61
      // provider: () => new HDWalletProvider(SUPER_ADMIN_PRIVATE_KEY, `https://rpc-mumbai.maticvigil.com/v1/ddc83a13efa487e53990af87e032489e03438c61`),//https://rpc-mainnet.maticvigil.com/v1/ddc83a13efa487e53990af87e032489e03438c61
      network_id: 137,
      // gas:17042678,
      maxPriorityFeePerGas:258,
      // maxFeePerGas:841.52057629525,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    auroramainnet: {
      provider: () => new HDWalletProvider(SUPER_ADMIN_PRIVATE_KEY, `https://mainnet.aurora.dev`),//https://mainnet.aurora.dev
      network_id: 1313161554,
      // gas: 10000000
    }

  },

  compilers: {
    solc: {
      version: "0.8.2",       // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 200
        },
        // evmVersion: "byzantium"
      }
    },
  },

  plugins: [
    'truffle-plugin-verify',
    'truffle-contract-size'
  ],

  api_keys: {
    etherscan: process.env.ETHERSCAN_API_KEY,
    bscscan: process.env.BCSSCAN_API_KEY,
    polygonscan: "WUW5D7XICFDRFJN4EJGTHTAHJSJJP71FUG"
  }
};
