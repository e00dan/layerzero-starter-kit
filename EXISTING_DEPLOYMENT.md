### Existing deployment

For demo purposes here are example contracts deployed on Sepolia and Mumbai.

1. Sepolia Proxy: https://sepolia.etherscan.io/address/0x43d4e075bdF270513d6c76F59eCC5C4479322A3a#readProxyContract
2. Mumbai Proxy: https://mumbai.polygonscan.com/address/0x43d4e075bdF270513d6c76F59eCC5C4479322A3a

Both proxies and implementations are verified on [Sourcify](https://sourcify.dev/#/lookup/0x43d4e075bdF270513d6c76F59eCC5C4479322A3a).

```
== Logs ==
Counter address: 0xA13e2fa62b771887F383F4a95c4D8E9eA1A0d748 
Counter Proxy address: 0x43d4e075bdF270513d6c76F59eCC5C4479322A3a 
```

Example cross-chain transaction from Sepolia to Mumbai: [LayerZero Scan](https://testnet.layerzeroscan.com/tx/0xa236623f7cab080c706edf3889fe8dd2c55f0750fc5dc29cb4794dffc361b0e7)

Example message options that can be used for quoting and then calling `increment()`: `0x00030100110100000000000000000000000000030d40` (pay 200k gas to Executor and trigger LZ Receive).

![message delivered](./img/message-delivered.png)