// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.33;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract VegaVoteToken is ERC20, AccessControl {
    error ZeroAmount();
    error ETHTransferFailed();
    error AlreadyVoted();
    error NotEnoughAvailableTokens();
    error InvalidDuration();

    event Mint(address indexed account, uint256 amount);
    event Burn(address indexed account, uint256 amount);

    bytes32 public constant STAKER_ROLE = keccak256("Staker");

    struct TimestampTokenPair {
        uint256 expiryTimestamp;
        uint256 amount;
        bool usedForVoting;
    }

    mapping(address => uint256) public stakerVotePower;
    mapping(address => TimestampTokenPair[]) private _stakerTokenHistory;

    constructor() ERC20("VegaVotingToken", "VV") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(uint256 duration) external payable {
        if (msg.value == 0) revert ZeroAmount();
        if (duration < 365 days || duration > 4 * 365 days) revert InvalidDuration();
        
        uint256 expiry = block.timestamp + duration;
        _mint(msg.sender, msg.value);

        if (!hasRole(STAKER_ROLE, msg.sender)) {
            _grantRole(STAKER_ROLE, msg.sender);
        }

        _stakerTokenHistory[msg.sender].push(TimestampTokenPair({
            expiryTimestamp: expiry,
            amount: msg.value,
            usedForVoting: false
        }));

        emit Mint(msg.sender, msg.value);
    }

    function calculateVotePower(address account) public returns(uint256) {
        _checkRole(STAKER_ROLE, account);

        uint256 votePower = 0;
        for(uint256 i = 0; i < _stakerTokenHistory[account].length; ++i) {
            TimestampTokenPair storage stake = _stakerTokenHistory[account][i];
            
            if (stake.usedForVoting) {
                revert AlreadyVoted();
            }

            if (stake.expiryTimestamp > block.timestamp) {
                uint256 dRemain = stake.expiryTimestamp - block.timestamp;
                uint256 dDays = dRemain / 1 days; 
                votePower += stake.amount * (dDays ** 2);
            }
            stake.usedForVoting = true;
        }
        
        stakerVotePower[account] = votePower;
        return votePower;
    }

    function burn(uint256 amount) external onlyRole(STAKER_ROLE) {
        if (amount == 0) revert ZeroAmount();
        
        uint256 available = 0;
        for (uint256 i = 0; i < _stakerTokenHistory[msg.sender].length; i++) {
            if (block.timestamp >= _stakerTokenHistory[msg.sender][i].expiryTimestamp) {
                available += _stakerTokenHistory[msg.sender][i].amount;
            }
        }
        if (available < amount) revert NotEnoughAvailableTokens();

        _burn(msg.sender, amount);

        uint256 remainingToClear = amount;
        // Уменьшаем балансы в истории стейкинга
        for (uint256 i = _stakerTokenHistory[msg.sender].length; i > 0 && remainingToClear > 0; i--) {
            TimestampTokenPair storage stake = _stakerTokenHistory[msg.sender][i-1];
            
            if (block.timestamp >= stake.expiryTimestamp) {
                if (stake.amount <= remainingToClear) {
                    remainingToClear -= stake.amount;
                    stake.amount = 0;
                } else {
                    stake.amount -= remainingToClear;
                    remainingToClear = 0;
                }
            }
        }
    
        (bool ok, ) = payable(msg.sender).call{value: amount}("");
        if (!ok) revert ETHTransferFailed();
        emit Burn(msg.sender, amount);
    }
}