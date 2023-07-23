require("@nomiclabs/hardhat-waffle")
require("hardhat-gas-reporter")
require("@nomiclabs/hardhat-etherscan")
require("solidity-coverage")
require("hardhat-deploy")
require("dotenv").config()

const POLYGON_RPC_URL = process.env.POLYGON_RPC_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY

module.exports = {
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            chainId: 1,
            forking: {
                url: POLYGON_RPC_URL,
            },
        },
        localhost: {
            chainId: 31337,
            port: 8545,
        },
        polygon: {
            url: POLYGON_RPC_URL,
            accounts: [PRIVATE_KEY],
            chainId: 137,
            blockConfirmations: 6,
            allowUnlimitedContractSize: true,
        },
    },

    solidity: {
        compilers: [
            {
                version: "0.8.8",
            },
            {
                version: "0.6.12",
            },
            {
                version: "0.4.19",
            },
            {
                version: "0.5.12",
            },
            {
                version: "0.8.17",
            },
            {
                version: "0.8.10",
            },
            {
                version: "0.7.6",
            },
            {
                version: "0.8.7",
            },
        ],
    },
    allowUnlimitedContractSize: true,
    namedAccounts: {
        deployer: {
            default: 0, // here this will by default take the first account as deployer
            1: 0, // similarly on mainnet it will take the first account as deployer. Note though that depending on how hardhat network are configured, the account 0 on one network can be different than on another
            137: 0,
        },
    },
}
