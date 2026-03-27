// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.33;

import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {VegaVoteToken} from "./VegaVoteToken.sol";
import {VegaVoteResults} from "./VegaVoteResults.sol";

interface IVegaToken {
    function calculateVotePower(address account) external returns (uint256);
}

contract VegaVoting is AccessControl {
    error VotingClosed();
    error AccessDenied();

    event VotingStarted(bytes32 indexed id, string description);
    event VoteCast(address indexed voter, bool variant, uint256 power);

    struct Voting {
        bytes32 id;
        string description;
        uint256 deadline;
        uint256 votingPowerThreshold;
        uint256 totalVotes;
        uint256 yesPower;
        uint256 noPower;
        bool closed;
    }

    bytes32 public constant STAKER_ROLE = keccak256("Staker");

    Voting public currentVote;
    VegaVoteToken public token;
    VegaVoteResults public nftContract;

    constructor(address tokenAddress, address nftAddress) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        token = VegaVoteToken(tokenAddress);
        nftContract = VegaVoteResults(nftAddress);
    }

    function releaseVoting(
        string memory _description,
        uint256 _durationSeconds, 
        uint256 _threshold
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        currentVote = Voting({
            id: keccak256(abi.encode(_description, block.timestamp)),
            description: _description,
            deadline: block.timestamp + _durationSeconds,
            votingPowerThreshold: _threshold,
            yesPower: 0,
            noPower: 0,
            totalVotes: 0,
            closed: false
        });
        
        emit VotingStarted(currentVote.id, _description);
    }

    function vote(bool variant) external {
        if (!IAccessControl(address(token)).hasRole(STAKER_ROLE, msg.sender)) {
            revert AccessDenied();
        }

        if (block.timestamp > currentVote.deadline || currentVote.closed) {
            revert VotingClosed();
        }
        uint256 power = IVegaToken(address(token)).calculateVotePower(msg.sender);
        
        if (variant) {
            currentVote.yesPower += power;
        } else {
            currentVote.noPower += power;
        }
        
        currentVote.totalVotes += 1;
        emit VoteCast(msg.sender, variant, power);

        if (currentVote.yesPower >= currentVote.votingPowerThreshold || 
            currentVote.noPower >= currentVote.votingPowerThreshold) {
            _finalize();
        }
    }

    function closeVoting() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _finalize();
    }

    function _finalize() internal {
        if (currentVote.closed) return;
        currentVote.closed = true;

        VegaVoteResults.Voting memory resultForNft = VegaVoteResults.Voting({
            id: currentVote.id,
            description: currentVote.description,
            deadline: currentVote.deadline,
            votingPowerThreshold: currentVote.votingPowerThreshold,
            totalVotes: currentVote.totalVotes,
            yesPower: currentVote.yesPower,
            noPower: currentVote.noPower,
            closed: true
        });

        nftContract.mintResult(msg.sender, resultForNft);
    }
}