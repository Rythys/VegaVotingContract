// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.33;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";


contract VegaVoteResults is ERC721, AccessControl {
    event VotePublished(bytes32 indexed ID, uint256 timestamp, uint256 yesPower, uint256 noPower);

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

    uint256 private _tokenIdCounter;

    mapping(uint256 => Voting) public archive;

    constructor() ERC721("VegaVoteResults", "VVR") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mintResult(address to, Voting memory meta) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _safeMint(to, _tokenIdCounter);
        archive[_tokenIdCounter] = meta;
        ++_tokenIdCounter;

        emit VotePublished(meta.id, block.timestamp, meta.yesPower, meta.noPower);
    }

    // ОБЯЗАТЕЛЬНО для компиляции при наследовании от двух контрактов с этой функцией
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
