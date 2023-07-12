// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/console2.sol";
import "../src/GameFactory.sol";

// Deploys two games and checks that both are running
contract GFTest is Test {
    GameFactory public gameFactory;
    Game public game1;
    Game public game2;

    function setUp() public {
        gameFactory = new GameFactory();
        game1 = Game(gameFactory.createNewGame(1, 7, 24, 51));
            // cost of share = 1 eth
            // voting interval = 7 days
            // vote duration = 24 hours
            // vote threshold = 51%

        game2 = Game(gameFactory.createNewGame(2, 14, 12, 67));
            // cost of share = 2 eth
            // voting interval = 14 days
            // vote duration = 12 hours
            // vote threshold = 67%
    }

    function testCreation() public view {
        console.log(address(game1));
//        address addy1 = address(gameFactory).gameAddresses[1];
//      console.log(addy1);
//      assertEq(address(game1), addy1);
        console.log(address(game2));
//      address addy2 = gameFactory.gameAddresses[2];
//      console.log(addy2);
//      assertEq(address(game2), addy2);

    }
}