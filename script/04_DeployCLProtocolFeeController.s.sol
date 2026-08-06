// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {BaseScript} from "./BaseScript.sol";
import {SushiSwapV4CLProtocolFeeController} from "../src/SushiSwapV4CLProtocolFeeController.sol";

/**
 * Step 1: Deploy
 * forge script script/04_DeployCLProtocolFeeController.s.sol:DeployCLProtocolFeeControllerScript -vvv \
 *     --rpc-url $RPC_URL \
 *     --broadcast \
 *     --slow \
 *     --verify
 * Do not perform setup or ownership transactions after this script. Continue the protected deployment
 * sequence through Periphery nonce 7, then run 08_ConfigureCL.s.sol.
 */
contract DeployCLProtocolFeeControllerScript is BaseScript {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        validateDeployer(deployerPrivateKey, 2);

        address clPoolManager = getAddressFromConfig("clPoolManager");
        validateContract(clPoolManager);
        console.log("clPoolManager address: ", address(clPoolManager));

        vm.startBroadcast(deployerPrivateKey);
        SushiSwapV4CLProtocolFeeController clProtocolFeeController =
            new SushiSwapV4CLProtocolFeeController(clPoolManager);
        vm.stopBroadcast();

        validateDeployment(address(clProtocolFeeController), "clProtocolFeeController");
        console.log("SushiSwapV4CLProtocolFeeController contract deployed at ", address(clProtocolFeeController));
    }
}
