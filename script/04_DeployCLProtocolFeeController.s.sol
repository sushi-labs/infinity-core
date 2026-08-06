// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {BaseScript} from "./BaseScript.sol";
import {SushiSwapV4CLProtocolFeeController} from "../src/SushiSwapV4CLProtocolFeeController.sol";
import {IProtocolFees} from "../src/interfaces/IProtocolFees.sol";

/**
 * Step 1: Deploy
 * forge script script/04_DeployCLProtocolFeeController.s.sol:DeployCLProtocolFeeControllerScript -vvv \
 *     --rpc-url $RPC_URL \
 *     --broadcast \
 *     --slow \
 *     --verify
 *
 * Step 2: Update config file
 *
 * Step 3: Proceed to poolOwner contract and call protocolFeeController.acceptOwnership
 *
 * Step 4: Call setProtocolFeeController() for the clPoolManager (if first time deploy)
 * forge script script/04_DeployCLProtocolFeeController.s.sol:DeployCLProtocolFeeControllerScript -vvv \
 *     --sig "setProtocolFeeController()" \
 *     --rpc-url $RPC_URL \
 *     --broadcast \
 *     --slow
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

    function setProtocolFeeController() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address clPoolManager = getAddressFromConfig("clPoolManager");
        console.log("clPoolManager address: ", address(clPoolManager));

        address clProtocolFeeController = getAddressFromConfig("clProtocolFeeController");
        console.log("clProtocolFeeController address: ", address(clProtocolFeeController));

        /// @notice set the protocol fee controller for the clPoolManager
        IProtocolFees(clPoolManager)
            .setProtocolFeeController(SushiSwapV4CLProtocolFeeController(clProtocolFeeController));

        vm.stopBroadcast();
    }
}
