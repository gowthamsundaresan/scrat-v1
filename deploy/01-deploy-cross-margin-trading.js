const { ethers } = require("hardhat")

module.exports = async function () {
    console.log("-------------------------------------------")
    const ContractFactory = await ethers.getContractFactory("CrossMarginTrading")
    const contract = await ContractFactory.deploy({ gasLimit: 30000000 })
    console.log(`CrossMarginTrading.sol deployed at ${contract.address}`)
    console.log("-------------------------------------------")
}
