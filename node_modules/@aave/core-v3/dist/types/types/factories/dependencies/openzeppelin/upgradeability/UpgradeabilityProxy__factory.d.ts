import { Signer, ContractFactory, PayableOverrides, BytesLike } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { PromiseOrValue } from "../../../../common";
import type { UpgradeabilityProxy, UpgradeabilityProxyInterface } from "../../../../dependencies/openzeppelin/upgradeability/UpgradeabilityProxy";
type UpgradeabilityProxyConstructorParams = [signer?: Signer] | ConstructorParameters<typeof ContractFactory>;
export declare class UpgradeabilityProxy__factory extends ContractFactory {
    constructor(...args: UpgradeabilityProxyConstructorParams);
    deploy(_logic: PromiseOrValue<string>, _data: PromiseOrValue<BytesLike>, overrides?: PayableOverrides & {
        from?: PromiseOrValue<string>;
    }): Promise<UpgradeabilityProxy>;
    getDeployTransaction(_logic: PromiseOrValue<string>, _data: PromiseOrValue<BytesLike>, overrides?: PayableOverrides & {
        from?: PromiseOrValue<string>;
    }): TransactionRequest;
    attach(address: string): UpgradeabilityProxy;
    connect(signer: Signer): UpgradeabilityProxy__factory;
    static readonly bytecode = "0x608060405260405161042938038061042983398101604081905261002291610207565b61004d60017f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbd6102d5565b60008051602061040983398151915214610069576100696102fa565b610072826100ea565b8051156100e3576000826001600160a01b0316826040516100939190610310565b600060405180830381855af49150503d80600081146100ce576040519150601f19603f3d011682016040523d82523d6000602084013e6100d3565b606091505b50509050806100e157600080fd5b505b505061032c565b6100fd8161018560201b61003b1760201c565b6101735760405162461bcd60e51b815260206004820152603b60248201527f43616e6e6f742073657420612070726f787920696d706c656d656e746174696f60448201527f6e20746f2061206e6f6e2d636f6e747261637420616464726573730000000000606482015260840160405180910390fd5b60008051602061040983398151915255565b6000813f7fc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a4708181148015906101b957508115155b949350505050565b634e487b7160e01b600052604160045260246000fd5b60005b838110156101f25781810151838201526020016101da565b83811115610201576000848401525b50505050565b6000806040838503121561021a57600080fd5b82516001600160a01b038116811461023157600080fd5b60208401519092506001600160401b038082111561024e57600080fd5b818501915085601f83011261026257600080fd5b815181811115610274576102746101c1565b604051601f8201601f19908116603f0116810190838211818310171561029c5761029c6101c1565b816040528281528860208487010111156102b557600080fd5b6102c68360208301602088016101d7565b80955050505050509250929050565b6000828210156102f557634e487b7160e01b600052601160045260246000fd5b500390565b634e487b7160e01b600052600160045260246000fd5b600082516103228184602087016101d7565b9190910192915050565b60cf8061033a6000396000f3fe6080604052600a600c565b005b603960357f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc5490565b6076565b565b6000813f7fc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470818114801590606e57508115155b949350505050565b3660008037600080366000845af43d6000803e8080156094573d6000f35b3d6000fdfea264697066735822122015c7de4dd915af3877661b40f61e1fbfc70a0a654d44f123810045fc949c500464736f6c634300080a0033360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc";
    static readonly abi: ({
        inputs: {
            internalType: string;
            name: string;
            type: string;
        }[];
        stateMutability: string;
        type: string;
        anonymous?: undefined;
        name?: undefined;
    } | {
        anonymous: boolean;
        inputs: {
            indexed: boolean;
            internalType: string;
            name: string;
            type: string;
        }[];
        name: string;
        type: string;
        stateMutability?: undefined;
    } | {
        stateMutability: string;
        type: string;
        inputs?: undefined;
        anonymous?: undefined;
        name?: undefined;
    })[];
    static createInterface(): UpgradeabilityProxyInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): UpgradeabilityProxy;
}
export {};
//# sourceMappingURL=UpgradeabilityProxy__factory.d.ts.map