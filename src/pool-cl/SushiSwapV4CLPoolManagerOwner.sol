// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (C) 2026 Sushi Labs
pragma solidity 0.8.26;

import {CLPoolManagerOwner, ICLPoolManagerWithPauseOwnable} from "./CLPoolManagerOwner.sol";

/// @title SushiSwap V4 CL Pool Manager Owner
/// @notice Owns and administers the SushiSwap V4 CL pool manager.
contract SushiSwapV4CLPoolManagerOwner is CLPoolManagerOwner {
    constructor(ICLPoolManagerWithPauseOwnable poolManager) CLPoolManagerOwner(poolManager) {}
}
