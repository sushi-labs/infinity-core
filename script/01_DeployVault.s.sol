// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {BaseScript} from "./BaseScript.sol";
import {SushiSwapV4Vault} from "../src/SushiSwapV4Vault.sol";

/**
 *
 * Step 1: Deploy
 * forge script script/01_DeployVault.s.sol:DeployVaultScript -vvv \
 *     --rpc-url $RPC_URL \
 *     --broadcast \
 *     --slow \
 *     --verify
 *
 * This must be the deployer's nonce 0 transaction on every chain.
 */
contract DeployVaultScript is BaseScript {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        validateDeployer(deployerPrivateKey, 0);

        vm.startBroadcast(deployerPrivateKey);
        SushiSwapV4Vault vault = new SushiSwapV4Vault();
        vm.stopBroadcast();

        validateDeployment(address(vault), "vault");
        console.log("SushiSwapV4Vault contract deployed at ", address(vault));
    }
}
