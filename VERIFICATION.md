# Verification

The automatic verification process in Foundry, initiated by the --verify flag during deployment, appears to be non-functional. This issue is likely attributed to a Foundry error. Nonetheless, verifying contracts manually using command-line and Etherscan website remains a relatively straightforward process.

**Counter**

Verifying Counter seems to be more or less automatic.

Verifying Counter:
```
forge verify-contract COUNTER_ADDRESS Counter --watch --chain sepolia
```

*Note: You can obtain `COUNTER_ADDRESS` from deployment logs, it is "Counter address".*

On Mumbai it requires more effort to verify the contract. Run:
```
forge verify-contract COUNTER_ADDRESS Counter --chain mumbai --show-standard-json-input > etherscan.json
```

Sometimes even manually uploading the file doesn't seem to work for Mumbai network.

And then manually upload that JSON file as Standard Input into Mumbai Polygonscan. Automatic verification is broken, error:
```
Encountered an error verifying this contract:
Response: `NOTOK`
Details: `Invalid API Key`
```

**Proxy**

Verifying UUPSProxy seems to require marking the contract as proxy in Etherscan interface by clicking "Is this proxy?"

![proxy verification](./img/proxy-verification.png)

Full verification can be done by manually obtaining constructor args and executing following command:
```
forge verify-contract PROXY_ADDRESS UUPSProxy \
    --constructor-args "0x0000000000000000000000002ac921d0e2ae6f9248cd4a5d92e4ad7b1f0777f600000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000044485cc955000000000000000000000000464570ada09869d8741132183721b4f0769a028700000000000000000000000073b31ac967f46db2c45280c7f5d1d3ee7f38e12200000000000000000000000000000000000000000000000000000000" \
    --watch --chain sepolia
```

Constructor arguments can be obtained from `./broadcast/multi/Counter.s.sol-latest/deployCounterTestnet.json` after running deployment script. Last 384 characters prefixed by 0x of transaction data from `UUPSProxy` deployment.