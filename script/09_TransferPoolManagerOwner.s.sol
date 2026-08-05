// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {BaseScript} from "./BaseScript.sol";
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
        address clPoolManagerOwner = getAddressFromConfig("clPoolManagerOwnerContract");
        address clProtocolFeeController = getAddressFromConfig("clProtocolFeeController");

        validateContract(vault);
        validateContract(clPoolManagerOwner);
        validateContract(clProtocolFeeController);
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
