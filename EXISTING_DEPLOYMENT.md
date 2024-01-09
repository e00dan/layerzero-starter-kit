### Existing deployment

For demo purposes here are example contracts deployed on Sepolia and Mumbai.

1. Sepolia Proxy: https://sepolia.etherscan.io/address/0xb90bC30922CF87F0CCD44402d8bAfE5c6d736F6e#readProxyContract
2. Mumbai Proxy: https://mumbai.polygonscan.com/address/0xb90bC30922CF87F0CCD44402d8bAfE5c6d736F6e

Both proxies and implementations are verified on [Sourcify](https://sourcify.dev/#/lookup/0xb90bC30922CF87F0CCD44402d8bAfE5c6d736F6e).

```
== Logs ==
Deploying to chain: sepolia 

Counter address: 0x2ac921D0E2ae6F9248CD4a5D92e4Ad7B1f0777F6 
Counter Proxy address: 0xb90bC30922CF87F0CCD44402d8bAfE5c6d736F6e 

Deploying to chain: mumbai

Counter address: 0x2ac921D0E2ae6F9248CD4a5D92e4Ad7B1f0777F6 
Counter Proxy address: 0xb90bC30922CF87F0CCD44402d8bAfE5c6d736F6e 
```

Example cross-chain transaction from Sepolia to Mumbai: [LayerZero Scan](https://testnet.layerzeroscan.com/tx/0x10afbb616943a29187b3e268a89c9eefc7672858dff77c52b5609b81497543ab)

Example message options that can be used for quoting and then calling `increment()`: `0x00030100110100000000000000000000000000030d40` (pay 200k gas to Executor and trigger LZ Receive).

![message delivered](./img/message-delivered.png)