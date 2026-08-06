// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {BaseScript} from "./BaseScript.sol";
import {SushiSwapV4CLPoolManagerOwner} from "../src/pool-cl/SushiSwapV4CLPoolManagerOwner.sol";
import {ICLPoolManagerWithPauseOwnable} from "../src/pool-cl/CLPoolManagerOwner.sol";

/**
 * Step 1: Deploy
 * forge script script/06_DeployCLPoolManagerOwner.s.sol:DeployCLPoolManagerOwnerScript -vvv \
 *     --rpc-url $RPC_URL \
 *     --broadcast \
 *     --slow \
 *     --verify
 * Do not perform setup or ownership transactions after this script. Continue with the four Periphery
 * deployments at nonces 4 through 7, then run 08_ConfigureCL.s.sol.
 */
contract DeployCLPoolManagerOwnerScript is BaseScript {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        validateDeployer(deployerPrivateKey, 3);

        address clPoolManager = getAddressFromConfig("clPoolManager");
        validateContract(clPoolManager);
        console.log("clPoolManager address: ", address(clPoolManager));

        vm.startBroadcast(deployerPrivateKey);
        SushiSwapV4CLPoolManagerOwner clPoolManagerOwner =
            new SushiSwapV4CLPoolManagerOwner(ICLPoolManagerWithPauseOwnable(clPoolManager));
        vm.stopBroadcast();

        validateDeployment(address(clPoolManagerOwner), "clPoolManagerOwnerContract");
        console.log("SushiSwapV4CLPoolManagerOwner contract deployed at ", address(clPoolManagerOwner));
    }
}
