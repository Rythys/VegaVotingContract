// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.33;

import {Script} from "forge-std/Script.sol";
import {VegaVoteToken} from "../src/VegaVoteToken.sol";
import {VegaVoteResults} from "../src/VegaVoteResults.sol";
import {VegaVoting} from "../src/VegaVoting.sol";

contract DeployVegaVoting is Script {
    function run() external {
        vm.startBroadcast();
        VegaVoteToken token = new VegaVoteToken();
        VegaVoteResults results = new VegaVoteResults();
        VegaVoting voting = new VegaVoting(address(token), address(results));
        results.grantRole(results.DEFAULT_ADMIN_ROLE(), address(voting));
        vm.stopBroadcast();
    }
}