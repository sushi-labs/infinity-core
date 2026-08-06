// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {BaseScript} from "./BaseScript.sol";
import {BinPoolManagerOwner, IBinPoolManagerWithPauseOwnable} from "../src/pool-bin/BinPoolManagerOwner.sol";

/**
 * Step 1: Deploy
 * forge script script/07_DeployBinPoolManagerOwner.s.sol:DeployBinPoolManagerOwnerScript -vvv \
 *     --rpc-url $RPC_URL \
 *     --broadcast \
 *     --slow \
 *     --verify
 *
 * Step 2: (Manual) Ask 'poolOwner' proceed to BinPoolManagerOwner.acceptOwnership
 *
 * Step 3: (Manual) Proceed to call binPoolManager.transferOwnership(binPoolManagerOwner)
 */
contract DeployBinPoolManagerOwnerScript is BaseScript {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address binPoolManager = getAddressFromConfig("binPoolManager");
        console.log("binPoolManager address: ", address(binPoolManager));

        BinPoolManagerOwner binPoolManagerOwner =
            new BinPoolManagerOwner(IBinPoolManagerWithPauseOwnable(binPoolManager));
        console.log("BinPoolManagerOwner contract deployed at ", address(binPoolManagerOwner));

        vm.stopBroadcast();
    }
}
