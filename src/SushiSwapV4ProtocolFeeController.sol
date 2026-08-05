// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (C) 2026 Sushi Labs
pragma solidity 0.8.26;

import {ProtocolFeeController} from "./ProtocolFeeController.sol";

/// @title SushiSwap V4 Protocol Fee Controller
/// @notice Controls protocol fees for the SushiSwap V4 pool manager.
contract SushiSwapV4ProtocolFeeController is ProtocolFeeController {
    constructor(address poolManager) ProtocolFeeController(poolManager) {}
}
