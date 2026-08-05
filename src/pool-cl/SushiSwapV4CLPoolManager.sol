// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (C) 2026 Sushi Labs
pragma solidity 0.8.26;

import {IVault} from "../interfaces/IVault.sol";
import {CLPoolManager} from "./CLPoolManager.sol";

/// @title SushiSwap V4 CL Pool Manager
/// @notice Manages concentrated-liquidity pools for SushiSwap V4.
contract SushiSwapV4CLPoolManager is CLPoolManager {
    constructor(IVault vault) CLPoolManager(vault) {}
}
