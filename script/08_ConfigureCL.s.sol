// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {BaseScript} from "./BaseScript.sol";
import {IVault} from "../src/interfaces/IVault.sol";
import {IProtocolFees} from "../src/interfaces/IProtocolFees.sol";
import {IProtocolFeeController} from "../src/interfaces/IProtocolFeeController.sol";
import {Ownable} from "../src/base/Ownable.sol";
import {SushiSwapV4CLProtocolFeeController} from "../src/SushiSwapV4CLProtocolFeeController.sol";

/// @notice Performs deployer-controlled CL setup only after all nonce 0-7 deployments exist.
contract ConfigureCLScript is BaseScript {
    uint256 private constant EXPECTED_PROTOCOL_FEE_SPLIT_RATIO = 33 * 1e4;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        require(deployer == getAddressFromConfig("deployer"), "Unexpected deployer");
        require(vm.getNonce(deployer) >= 8, "CL deployment sequence incomplete");

        address vault = getAddressFromConfig("vault");
        address clPoolManager = getAddressFromConfig("clPoolManager");
        address clProtocolFeeController = getAddressFromConfig("clProtocolFeeController");
        address clPoolManagerOwner = getAddressFromConfig("clPoolManagerOwnerContract");

        require(vault.code.length > 0, "Vault not deployed");
        require(clPoolManager.code.length > 0, "CL pool manager not deployed");
        require(clProtocolFeeController.code.length > 0, "CL fee controller not deployed");
        require(clPoolManagerOwner.code.length > 0, "CL pool manager owner not deployed");
        require(
            SushiSwapV4CLProtocolFeeController(clProtocolFeeController).protocolFeeSplitRatio()
                == EXPECTED_PROTOCOL_FEE_SPLIT_RATIO,
            "Unexpected protocol fee split ratio"
        );

        vm.startBroadcast(deployerPrivateKey);
        IVault(vault).registerApp(clPoolManager);
        IProtocolFees(clPoolManager).setProtocolFeeController(IProtocolFeeController(clProtocolFeeController));
        Ownable(clPoolManager).transferOwnership(clPoolManagerOwner);
        vm.stopBroadcast();
    }
}
