// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {BaseScript} from "./BaseScript.sol";
import {ProtocolFeeController} from "../src/ProtocolFeeController.sol";
import {IProtocolFees} from "../src/interfaces/IProtocolFees.sol";

/**
 * Step 1: Deploy
 * forge script script/05_DeployBinProtocolFeeController.s.sol:DeployBinProtocolFeeControllerScript -vvv \
 *     --rpc-url $RPC_URL \
 *     --broadcast \
 *     --slow \
 *     --verify
 *
 * Step 2: Update config file
 *
 * Step 3: Proceed to poolOwner contract and call protocolFeeController.acceptOwnership
 *
 * Step 4: Call setProtocolFeeController() for the binPoolManager (if first time deploy)
 * forge script script/05_DeployBinProtocolFeeController.s.sol:DeployBinProtocolFeeControllerScript -vvv \
 *     --sig "setProtocolFeeController()" \
 *     --rpc-url $RPC_URL \
 *     --broadcast \
 *     --slow
 */
contract DeployBinProtocolFeeControllerScript is BaseScript {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address binPoolManager = getAddressFromConfig("binPoolManager");
        console.log("binPoolManager address: ", address(binPoolManager));

        ProtocolFeeController binProtocolFeeController = new ProtocolFeeController(binPoolManager);

        console.log("BinProtocolFeeController contract deployed at ", address(binProtocolFeeController));

        vm.stopBroadcast();
    }

    function setProtocolFeeController() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address binPoolManager = getAddressFromConfig("binPoolManager");
        console.log("binPoolManager address: ", address(binPoolManager));

        address binProtocolFeeController = getAddressFromConfig("binProtocolFeeController");
        console.log("binProtocolFeeController address: ", address(binProtocolFeeController));

        /// @notice set the protocol fee controller for the binPoolManager
        IProtocolFees(binPoolManager).setProtocolFeeController(ProtocolFeeController(binProtocolFeeController));

        vm.stopBroadcast();
    }
}
