// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.33;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {VegaVoteToken} from "../src/VegaVoteToken.sol";
import {VegaVoteResults} from "../src/VegaVoteResults.sol";
import {VegaVoting} from "../src/VegaVoting.sol";

contract DeployVegaVoting is Script {
    function run() external {
        vm.startBroadcast();

        // 1. Создаем токен (если конструктор без параметров)
        VegaVoteToken token = new VegaVoteToken(); 

        // 2. Создаем результаты (без параметров)
        VegaVoteResults results = new VegaVoteResults();

        // 3. Создаем голосование — ПЕРЕДАЕМ ТОЛЬКО 2 АРГУМЕНТА
        // Ошибка была здесь, если ты передавал еще длительность и порог
        VegaVoting voting = new VegaVoting(address(token), address(results));

        // 4. Настройка ролей
        results.grantRole(results.DEFAULT_ADMIN_ROLE(), address(voting));

        // 5. Запуск голосования (это функция, а не конструктор!)
        voting.releaseVoting("Build on Ethereum?", 1 days, 200000 * 1 ether);

        vm.stopBroadcast();
    }
}