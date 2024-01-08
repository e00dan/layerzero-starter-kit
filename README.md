## Upgradeable LayerZero V2 Foundry Starter Pack

This repository can be cloned to quickly start building upgradeable applications on top of LayerZero V2. It already includes libraries required for development and contains working test setup.

This example repository uses Foundry, has no NPM dependencies, contains OpenZeppelin upgradeability by default.

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Deploy

```shell
forge script DeployCounter -s "deployCounterTestnet(uint256, uint256)" 5 6 --force --multi --broadcast
```

## Inspiration

LayerZero libraries and examples are based on: https://github.com/LayerZero-Labs/LayerZero-v2.

Multichain script deployment setup is heavily based on: https://github.com/timurguvenkaya/foundry-multichain.