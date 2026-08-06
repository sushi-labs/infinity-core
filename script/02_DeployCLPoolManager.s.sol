// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {BaseScript} from "./BaseScript.sol";
import {IVault} from "../src/interfaces/IVault.sol";
import {SushiSwapV4CLPoolManager} from "../src/pool-cl/SushiSwapV4CLPoolManager.sol";

/**
 *
 * Step 1: Deploy
 * forge script script/02_DeployCLPoolManager.s.sol:DeployCLPoolManagerScript -vvv \
 *     --rpc-url $RPC_URL \
 *     --broadcast \
 *     --slow \
 *     --verify
 */
contract DeployCLPoolManagerScript is BaseScript {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        validateDeployer(deployerPrivateKey, 1);

        address vault = getAddressFromConfig("vault");
        validateContract(vault);
        console.log("vault address: ", address(vault));

        vm.startBroadcast(deployerPrivateKey);
        SushiSwapV4CLPoolManager clPoolManager = new SushiSwapV4CLPoolManager(IVault(vault));
        vm.stopBroadcast();

        validateDeployment(address(clPoolManager), "clPoolManager");
        console.log("SushiSwapV4CLPoolManager contract deployed at ", address(clPoolManager));
    }
}
