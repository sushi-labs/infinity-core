// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {BaseScript} from "./BaseScript.sol";
import {IVault} from "../src/interfaces/IVault.sol";
import {IProtocolFees} from "../src/interfaces/IProtocolFees.sol";
import {Ownable as PoolManagerOwnable} from "../src/base/Ownable.sol";
import {SushiSwapV4CLProtocolFeeController} from "../src/SushiSwapV4CLProtocolFeeController.sol";
import {SushiSwapV4CLPoolManagerOwner} from "../src/pool-cl/SushiSwapV4CLPoolManagerOwner.sol";
import {Ownable as OpenZeppelinOwnable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/// @notice Read-only post-deployment verification for Core setup and governance handoff.
contract VerifyCLDeploymentScript is BaseScript {
    uint256 private constant EXPECTED_PROTOCOL_FEE_SPLIT_RATIO = 33 * 1e4;

    function run() public {
        address deployer = getAddressFromConfig("deployer");
        address poolOwner = getAddressFromConfig("poolOwner");
        address protocolFeeControllerOwner = getAddressFromConfig("protocolFeeControllerOwner");
        address vault = getAddressFromConfig("vault");
        address clPoolManager = getAddressFromConfig("clPoolManager");
        address clProtocolFeeController = getAddressFromConfig("clProtocolFeeController");
        address clPoolManagerOwner = getAddressFromConfig("clPoolManagerOwnerContract");

        require(vm.getNonce(deployer) >= 8, "CL deployment sequence incomplete");
        validateContract(vault);
        validateContract(clPoolManager);
        validateContract(clProtocolFeeController);
        validateContract(clPoolManagerOwner);
        require(IVault(vault).isAppRegistered(clPoolManager), "CL manager not registered");
        require(address(IProtocolFees(clPoolManager).vault()) == vault, "CL manager Vault mismatch");
        require(
            address(IProtocolFees(clPoolManager).protocolFeeController()) == clProtocolFeeController,
            "CL fee controller mismatch"
        );
        require(PoolManagerOwnable(clPoolManager).owner() == clPoolManagerOwner, "CL manager owner mismatch");
        require(
            SushiSwapV4CLProtocolFeeController(clProtocolFeeController).poolManager() == clPoolManager,
            "Fee controller manager mismatch"
        );
        require(
            SushiSwapV4CLProtocolFeeController(clProtocolFeeController).protocolFeeSplitRatio()
                == EXPECTED_PROTOCOL_FEE_SPLIT_RATIO,
            "Protocol fee split mismatch"
        );
        require(
            address(SushiSwapV4CLPoolManagerOwner(clPoolManagerOwner).poolManager()) == clPoolManager,
            "Owner contract manager mismatch"
        );

        _requireTransferredOrPending(vault, poolOwner);
        _requireTransferredOrPending(clPoolManagerOwner, poolOwner);
        _requireTransferredOrPending(clProtocolFeeController, protocolFeeControllerOwner);

        console.log("Core deployment and governance handoff verified");
    }

    function _requireTransferredOrPending(address target, address expectedOwner) private view {
        address currentOwner = OpenZeppelinOwnable(target).owner();
        address pendingOwner = Ownable2Step(target).pendingOwner();
        require(currentOwner == expectedOwner || pendingOwner == expectedOwner, "Governance handoff missing");
    }
}
