const networkConfig = {
    1: {
        name: "hardhat",
        USDC_TOKEN_ADDRESS: "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174",
        USDC_ATOKEN_ADDRESS: "0x625E7708f30cA75bfd92586e17077590C60eb4cD",
        USDC_VTOKEN_ADDRESS: "0xFCCf3cAbbe80101232d343252614b6A3eE81C989",
        WMATIC_TOKEN_ADDRESS: "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270",
        WMATIC_ATOKEN_ADDRESS: "0x6d80113e533a2C0fe82EaBD35f1875DcEA89Ea97",
        WMATIC_VTOKEN_ADDRESS: "0x4a1c3aD6Ed28a636ee1751C69071f6be75DEb8B8",
        UNIV3_FACTORY_ADDRESS: "0x1F98431c8aD98523631AE4a59f267346ea31F984",
        UNIV3_SWAP_ROUTER_01_ADDRESS: "0xE592427A0AEce92De3Edee1F18E0157C05861564",
        UNIV3_SWAP_ROUTER_02_ADDRESS: "0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45",
        UNIV3_QUOTER_ADDRESS: "0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6",
        UNIV3_WMATIC_WETH_POOL_ADDRESS: "0x167384319B41F7094e62f7506409Eb38079AbfF8",
        UNIV3_WMATIC_USDC_POOL_ADDRESS: "0xA374094527e1673A86dE625aa59517c5dE346d32",
        UNIV3_WMATIC_DAI_POOL_ADDRESS: "0xFE530931dA161232Ec76A7c3bEA7D36cF3811A0d",
        AAVE_V3_IPOOL_ADDRESSESPROVIDER_ADDRESS: "0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb",
        BALANCER_V2_IVAULT_ADDRESS: "0xBA12222222228d8Ba445958a75a0704d566BF2C8",
        BLOCKEXPLORER_API_KEY: process.env.POLYGONSCAN_API_KEY,
    },

    137: {
        name: "polygon",
        USDC_TOKEN_ADDRESS: "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174",
        USDC_ATOKEN_ADDRESS: "0x625E7708f30cA75bfd92586e17077590C60eb4cD",
        USDC_VTOKEN_ADDRESS: "0xFCCf3cAbbe80101232d343252614b6A3eE81C989",
        WMATIC_TOKEN_ADDRESS: "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270",
        WMATIC_ATOKEN_ADDRESS: "0x6d80113e533a2C0fe82EaBD35f1875DcEA89Ea97",
        WMATIC_VTOKEN_ADDRESS: "0x4a1c3aD6Ed28a636ee1751C69071f6be75DEb8B8",
        UNIV3_FACTORY_ADDRESS: "0x1F98431c8aD98523631AE4a59f267346ea31F984",
        UNIV3_SWAP_ROUTER_01_ADDRESS: "0xE592427A0AEce92De3Edee1F18E0157C05861564",
        UNIV3_SWAP_ROUTER_02_ADDRESS: "0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45",
        UNIV3_QUOTER_ADDRESS: "0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6",
        UNIV3_WMATIC_WETH_POOL_ADDRESS: "0x167384319B41F7094e62f7506409Eb38079AbfF8",
        UNIV3_WMATIC_USDC_POOL_ADDRESS: "0xA374094527e1673A86dE625aa59517c5dE346d32",
        UNIV3_WMATIC_DAI_POOL_ADDRESS: "0xFE530931dA161232Ec76A7c3bEA7D36cF3811A0d",
        AAVE_V3_IPOOL_ADDRESSESPROVIDER_ADDRESS: "0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb",
        BALANCER_V2_IVAULT_ADDRESS: "0xBA12222222228d8Ba445958a75a0704d566BF2C8",
        BLOCKEXPLORER_API_KEY: process.env.POLYGONSCAN_API_KEY,
    },

    31337: {
        name: "localhost",
        USDC_TOKEN_ADDRESS: "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174",
        USDC_ATOKEN_ADDRESS: "0x625E7708f30cA75bfd92586e17077590C60eb4cD",
        USDC_VTOKEN_ADDRESS: "0xFCCf3cAbbe80101232d343252614b6A3eE81C989",
        WMATIC_TOKEN_ADDRESS: "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270",
        WMATIC_ATOKEN_ADDRESS: "0x6d80113e533a2C0fe82EaBD35f1875DcEA89Ea97",
        WMATIC_VTOKEN_ADDRESS: "0x4a1c3aD6Ed28a636ee1751C69071f6be75DEb8B8",
        UNIV3_FACTORY_ADDRESS: "0x1F98431c8aD98523631AE4a59f267346ea31F984",
        UNIV3_SWAP_ROUTER_01_ADDRESS: "0xE592427A0AEce92De3Edee1F18E0157C05861564",
        UNIV3_SWAP_ROUTER_02_ADDRESS: "0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45",
        UNIV3_QUOTER_ADDRESS: "0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6",
        UNIV3_WMATIC_WETH_POOL_ADDRESS: "0x167384319B41F7094e62f7506409Eb38079AbfF8",
        UNIV3_WMATIC_USDC_POOL_ADDRESS: "0xA374094527e1673A86dE625aa59517c5dE346d32",
        UNIV3_WMATIC_DAI_POOL_ADDRESS: "0xFE530931dA161232Ec76A7c3bEA7D36cF3811A0d",
        AAVE_V3_IPOOL_ADDRESSESPROVIDER_ADDRESS: "0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb",
        BALANCER_V2_IVAULT_ADDRESS: "0xBA12222222228d8Ba445958a75a0704d566BF2C8",
        BLOCKEXPLORER_API_KEY: process.env.POLYGONSCAN_API_KEY,
    },
}

const developmentChains = ["hardhat", "localhost"]

module.exports = {
    networkConfig,
    developmentChains,
}
