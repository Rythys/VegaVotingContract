// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.33;

import {Test, console} from "forge-std/Test.sol";
import {VegaVoteToken} from "../src/VegaVoteToken.sol";
import {VegaVoteResults} from "../src/VegaVoteResults.sol";
import {VegaVoting} from "../src/VegaVoting.sol";

contract VegaVotingTest is Test {
    VegaVoteToken internal token;
    VegaVoteResults internal results;
    VegaVoting internal voting;

    address internal admin = address(1);
    address internal alice = address(2);
    address internal bob = address(3);

    function setUp() public {
        vm.startPrank(admin);

        token = new VegaVoteToken();
        results = new VegaVoteResults();

        voting = new VegaVoting(address(token), address(results));

        results.grantRole(results.DEFAULT_ADMIN_ROLE(), address(voting));

        vm.stopPrank();

        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }


    function test_Burn_AfterExpiry() public {
        vm.prank(alice);
        token.mint{value: 1 ether}(365 days);

        vm.prank(alice);
        vm.expectRevert(); 
        token.burn(1 ether);

        vm.warp(block.timestamp + 365 days + 1);

        uint256 balBefore = alice.balance;
        vm.prank(alice);
        token.burn(1 ether);
        
        assertEq(alice.balance, balBefore + 1 ether, "Should return ETH after expiry");
    }

    function test_Fail_DoubleVoting() public {
        vm.prank(alice);
        token.mint{value: 1 ether}(365 days);

        vm.prank(admin);
        voting.releaseVoting("Test", 1 days, 1000);

        vm.prank(alice);
        voting.vote(true);

        vm.prank(alice);
        vm.expectRevert(); 
        voting.vote(true);
    }
}