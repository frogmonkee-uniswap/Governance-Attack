// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// This test doesn't run for some reason...

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
        game1 = Game(gameFactory.createNewGame(1, 7, 24, 51, 4));
            // cost of share = 1 eth
            // voting interval = 7 days
            // vote duration = 24 hours
            // vote threshold = 51%
            // expiration = 4 weeks

        game2 = Game(gameFactory.createNewGame(2, 14, 12, 67, 8));
            // cost of share = 2 eth
            // voting interval = 14 days
            // vote duration = 12 hours
            // vote threshold = 67%
            // expiration = 8 weeks
    }

    function testGameAddresses() public {
        // Asserts that address is stored in mapping
        assertEq(gameFactory.getGameAddresses(1), address(game1));
        assertEq(gameFactory.getGameAddresses(2), address(game2));
    }
}