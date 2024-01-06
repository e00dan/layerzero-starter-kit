## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

This repository uses multichain setup based on: https://github.com/timurguvenkaya/foundry-multichain.

Latest deployment:

Sepolia:
- Proxy: [0x367eb2816F98B8b1337112640B28d4c72010004D](https://sepolia.etherscan.io/address/0x367eb2816F98B8b1337112640B28d4c72010004D#readProxyContract)
- Implementation: 0x313e2BC58a29DB7696515747512A1076F6044a94

Mumbai:
- Proxy: [0xC3533761D6c58e5755301ccA980b0D3405847075](https://mumbai.polygonscan.com/address/0xC3533761D6c58e5755301ccA980b0D3405847075#readProxyContract)
- Implementation: [0x313e2BC58a29DB7696515747512A1076F6044a94](https://mumbai.polygonscan.com/address/0x313e2BC58a29DB7696515747512A1076F6044a94#code)

Example Increment Counter TX from Sepolia -> Mumbai: https://testnet.layerzeroscan.com/tx/0x5bd0993eb6f76ab3ea24861bacfe4a4419e7b6cddcadca69512d848987ee3c42

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
forge script DeployCounter -s "deployCounterTestnet(uint256, uint256)" 5 6 --force --multi --broadcast
```

It fails with message: `script failed: <no data>` please bump `5 6` eg. to `7 8` or other random numbers.

Note: `--verify` isn't used here because it fails with the message: `Fail - Unable to verify. Compiled contract deployment bytecode does NOT match the transaction deployment bytecode.`. Looks like Foundry error similar to ones already reported in their repository.

### Manual verify

Verifying Counter seems to be more or less automatic but verifying UUPSProxy seems to require manually copying last bytes from calldata from Etherscan transaction and then manually marking the contract as proxy in Etherscan interface by clicking "Is this proxy?" and then verifying that it is.

```
forge verify-contract COUNTER_ADDRESS Counter --watch --chain sepolia
forge verify-contract 0xb957d0b6AcE7e804A22cAFa72d15A2082042A8c2 UUPSProxy \
    --constructor-args "0x0000000000000000000000008d8b043cb51f9cf55b61034277a1d6c159b9f2e700000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000044485cc95500000000000000000000000073b31ac967f46db2c45280c7f5d1d3ee7f38e122000000000000000000000000464570ada09869d8741132183721b4f0769a028700000000000000000000000000000000000000000000000000000000" \
    --watch --chain sepolia
```

Mumbai:
```
forge verify-contract 0x4Bf783A795E41C3C8bE89a9905656323d255eE26 Counter --chain mumbai --show-standard-json-input > etherscan.json
```

And then manually upload that JSON file as Standard Input into Mumbai Polygonscan. Automatic verification is broken, error:
```
Encountered an error verifying this contract:
Response: `NOTOK`
Details: `Invalid API Key`
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
