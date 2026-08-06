# Infinity Core

## Running test

1. Install dependencies with `forge install` and `yarn`
2. Run test with `forge test --isolate`

See https://github.com/pancakeswap/infinity-core/pull/35 on why `--isolate` flag is used.

## Update dependencies

1. Run `forge update`

## Deployment

The scripts are located in `/script` folder, deployed contract address can be found in `script/config`

### Pre-req: before deployment, the follow env variable needs to be set
```bash
// set script config: /script/config/{SCRIPT_CONFIG}.json
export SCRIPT_CONFIG=ethereum-sepolia

// set rpc url
export RPC_URL=https://

// private key need to be prefixed with 0x
export PRIVATE_KEY=0x

// optional. Only set if you want to verify contract on explorer
export ETHERSCAN_API_KEY=xx
```

### Execute

Refer to the script source code for the exact command

Example. within `script/01_DeployVault.s.sol`
```bash
forge script script/01_DeployVault.s.sol:DeployVaultScript -vvv \
    --rpc-url $RPC_URL \
    --broadcast \
    --slow
```

The SushiSwap V4 CL release uses direct EVM `CREATE` from a dedicated deployment account. Run the
four Core deployment scripts at nonces 0 through 3 exactly as numbered. Do not send any other
transaction from the deployment account until the four Periphery deployments at nonces 4 through 7
are also complete. Each script validates the signer, nonce, and expected address before continuing.

Only after all eight contracts are deployed, run `08_ConfigureCL.s.sol`, then initiate the governance
handoff with `09_TransferPoolManagerOwner.s.sol`. The configured multisig must accept ownership of the
Vault, CL protocol fee controller, and CL pool-manager owner contract.

### Verifying

Each script includes a verification command. Verification may be performed after the nonce-sensitive
deployment sequence is complete.


Example. within `script/01_DeployVault.s.sol`
```bash
forge verify-contract <address> Vault --watch --chain <chain_id>
```
