// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {GameFactory} from "src/GameFactory.sol";


contract deployFactoryScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        GameFactory GFContract = new GameFactory();
        GFContract.createNewGame(1, 24, 7, 51, 4);
        vm.stopBroadcast();
    }
}
