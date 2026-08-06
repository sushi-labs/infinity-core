// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {BaseScript} from "./BaseScript.sol";
import {IVault} from "../src/interfaces/IVault.sol";
import {IProtocolFees} from "../src/interfaces/IProtocolFees.sol";
import {Ownable as PoolManagerOwnable} from "../src/base/Ownable.sol";
import {Ownable as OpenZeppelinOwnable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 *
 * Starts the governance handoff after all deployments and CL setup are complete.
 * The multisig must subsequently call acceptOwnership on each two-step contract.
 *
 * forge script script/09_TransferPoolManagerOwner.s.sol:TransferGovernanceOwnership -vvv \
 *     --rpc-url $RPC_URL \
 *     --broadcast \
 *     --slow
 *
 */
contract TransferGovernanceOwnership is BaseScript {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        require(deployer == getAddressFromConfig("deployer"), "Unexpected deployer");
        require(vm.getNonce(deployer) >= 8, "CL deployment sequence incomplete");

        address poolOwner = getAddressFromConfig("poolOwner");
        address protocolFeeControllerOwner = getAddressFromConfig("protocolFeeControllerOwner");
        address vault = getAddressFromConfig("vault");
        address clPoolManager = getAddressFromConfig("clPoolManager");
        address clPoolManagerOwner = getAddressFromConfig("clPoolManagerOwnerContract");
        address clProtocolFeeController = getAddressFromConfig("clProtocolFeeController");

        validateContract(vault);
        validateContract(clPoolManager);
        validateContract(clPoolManagerOwner);
        validateContract(clProtocolFeeController);
        validateContract(poolOwner);
        validateContract(protocolFeeControllerOwner);
        require(IVault(vault).isAppRegistered(clPoolManager), "Run 08_ConfigureCL first");
        require(
            address(IProtocolFees(clPoolManager).protocolFeeController()) == clProtocolFeeController,
            "CL fee controller not configured"
        );
        require(PoolManagerOwnable(clPoolManager).owner() == clPoolManagerOwner, "CL manager owner not configured");
        require(OpenZeppelinOwnable(vault).owner() == deployer, "Deployer does not own Vault");
        require(OpenZeppelinOwnable(clPoolManagerOwner).owner() == deployer, "Deployer does not own manager owner");
        require(
            OpenZeppelinOwnable(clProtocolFeeController).owner() == deployer,
            "Deployer does not own protocol fee controller"
        );

        vm.startBroadcast(deployerPrivateKey);
        OpenZeppelinOwnable(vault).transferOwnership(poolOwner);
        OpenZeppelinOwnable(clPoolManagerOwner).transferOwnership(poolOwner);
        OpenZeppelinOwnable(clProtocolFeeController).transferOwnership(protocolFeeControllerOwner);

        console.log("Governance ownership transfers initiated");

        vm.stopBroadcast();
    }
}
