## Upgradeable LayerZero V2 Foundry Starter Pack 🛠️🚀

This repository can be cloned to quickly start building upgradeable applications on top of LayerZero V2. It includes libraries required for development, contains test setup and working multichain deployment script written in Solidity.

These are the potential advantages of using this repository instead of official [LZ V2](https://github.com/LayerZero-Labs/LayerZero-v2) repository:
1. Multichain deployment script written in Solidity
2. OpenZeppelin V4 upgradeability for applications configured out of the box ([vide LZ-V2/PR-#9](https://github.com/LayerZero-Labs/LayerZero-v2/pull/9))
3. Native Foundry config - no NPM dependencies ([vide LZ-V2/Issue-#6](https://github.com/LayerZero-Labs/LayerZero-v2/issues/6)), no TypeScript
4. CREATE2 by default for deterministic addresses in multichain deployment
5. Very simple Counter example just to get started without advanced functionality

I still recommend to consult [official repository of LayerZero](https://github.com/LayerZero-Labs/LayerZero-v2) whenever you need to bring more advanced functionality such as composability, nested calls etc. Examples of such aren't part of this repository as of now.

## Quickstart

```
git clone https://github.com/Kuzirashi/layerzero-starter-kit.git
cd layerzero-starter-kit
forge install
```

*Note: If you don't have Foundry installed yet please follow [installation guide](https://book.getfoundry.sh/getting-started/installation).*

## Usage

### Build

```shell
forge build
```

### Test

```shell
forge test
```

*Note: if you want to execute single test file you can add a flag, eg.: `--match-path ./test/CounterUpgradeability.t.sol`.*

### Deploy

Preparation:
```
cp .env.example .env
```

Fill `TEST_DEPLOYER_KEY` and `TEST_OWNER_ADDRESS` before running deployment script.

Dry run:

```shell
forge script DeployCounter -s "deployCounterTestnet(uint256, uint256)" 1 1 --force --multi
```

To send transactions and actually deploy just add `--broadcast` flag to the command above.

*Note: `1 1` parameters are respectively: `uint256 _counterSalt, uint256 _counterProxySalt`. It affects generated addresses. If you have problem with deployment script failing try changing `1 1` to some random numbers instead. You can't deploy with the same salt twice - it fails with message: `script failed: <no data>`.*

*Note: Don't use automatic `--verify` flag because it doesn't seem to work.*

### Upgrade

Please set `TEST_COUNTER_PROXY_ADDRESS` in `.env` to make sure correct proxy is updated.

```
forge script UpgradeCounter -s "upgradeTestnet()" --force --multi
```

Add `--broadcast` when you're ready to send actual transactions ([example tx](https://sepolia.etherscan.io/tx/0xea00205afe187a984676c68e50d59b5493be72cd1204a7e424ffccdc7c80e1fa)).

### Verify

[Read VERIFICATION.md.](./VERIFICATION.md)

### Demo deployment

[Read EXISTING_DEPLOYMENT.md.](./EXISTING_DEPLOYMENT.md)

### Compatibility

Tested with:
```
forge 0.2.0 (71d8ea5 2024-01-09T14:41:14.837767655Z)
```

## Inspiration 💡

This repository is, to a significant extent, a compilation of other people's work. I just put these separate pieces together to achieve best developer experience possible.

LayerZero libraries and examples are based on: https://github.com/LayerZero-Labs/LayerZero-v2.

Multichain script deployment setup is heavily based on: https://github.com/timurguvenkaya/foundry-multichain by @timurguvenkaya.

LayerZero OApp Upgradeability is taken from: https://github.com/Zodomo/LayerZero-v2/tree/main by @Zodomo.

*Note: Initially I have used my own implementation but I think @Zodomo version is slightly better structured. I've noticed that implementation after I created this repository.*

## License

[MIT](./LICENSE.md)
