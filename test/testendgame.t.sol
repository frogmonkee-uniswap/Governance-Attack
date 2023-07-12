// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/console2.sol";
import "../src/GameFactory.sol";
import "../src/CoreGame.sol";
import "../src/Voting.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// Tests when game ends
contract GFTest is Test {
    GameFactory public gameFactory;
    Game public game;
    Voting public voting;
    IERC20 public shares;

    address userA;
    address userB;
    address userC;
    address userD;

    function setUp() public {
        gameFactory = new GameFactory();
        game = Game(gameFactory.createNewGame(1, 7, 24, 51, 4));
            // cost of share = 1 eth
            // voting interval = 7 days
            // vote duration = 24 hours
            // vote threshold = 51%
            // expiration = 4 weeks
        voting = game.votingContract();
        shares = game.sharesContract();

        userA = makeAddr("User A");
        vm.deal(userA, 4.1 ether);
        userB = makeAddr("User B");
        vm.deal(userB, 3 ether);
        userC = makeAddr("User C");
        vm.deal(userC, 2 ether);        
        userD = makeAddr("User D");
        vm.deal(userD, 2 ether);        
    }

    function testEndGame() public {
        /*
        +--------+----------------+
        |  User  | Deposit Amount |
        +--------+----------------+
        | User A |              4 |
        | User B |              3 |
        | User C |              2 |
        | User D |              2 |
        +--------+----------------+
        */
        vm.prank(userA);
        game.deposit{ value: 4 ether } ();
        vm.prank(userB);
        game.deposit{ value: 3 ether } ();
        vm.prank(userC);
        game.deposit{ value: 2 ether } ();
        vm.prank(userD);
        game.deposit{ value: 2 ether } ();
        assertEq(address(game).balance, 11e18); // Confirms balance is 11 ETH

        vm.expectRevert(bytes("Game is still ongoing."));
        game.endGame();

        // Skip to game expiry timestamp + 1
        uint256 newTimestamp = block.timestamp + 4 * 7 * 24 * 60 * 60 + 1;
        vm.warp(newTimestamp);

        assertEq(userA.balance, 0.1e18);
        assertEq(userB.balance, 0);
        assertEq(userC.balance, 0);
        assertEq(userD.balance, 0);

        game.endGame();

        assertEq(userA.balance, 4.1e18);
        assertEq(userB.balance, 3e18);
        assertEq(userC.balance, 2e18);
        assertEq(userD.balance, 2e18);
    }


    function testPassingVote() public {
        /*
        +--------+----------------+
        |  User  | Deposit Amount |
        +--------+----------------+
        | User A |              4 |
        | User B |              3 |
        | User C |              2 |
        | User D |              2 |
        +--------+----------------+
        */
        vm.prank(userA);
        game.deposit{ value: 4 ether } ();
        vm.prank(userB);
        game.deposit{ value: 3 ether } ();
        vm.prank(userC);
        game.deposit{ value: 2 ether } ();
        vm.prank(userD);
        game.deposit{ value: 2 ether } ();
        assertEq(address(game).balance, 11e18); // Confirms balance is 11 ETH
 
        /*
        +-------+------+-------------+
        | User  | Vote | Vote Weight |
        +-------+------+-------------+
        | UserA | Yes  |           4 |
        | UserB | Yes  |           3 |
        | UserC | No   |           2 |
        | UserD | No   |           2 |
        +-------+------+-------------+
        */
        vm.prank(userA);
        voting.vote{ value: 0.1 ether }(true); // Vote True
        vm.prank(userB);
        voting.vote(false); // Vote false
        vm.prank(userC);
        voting.vote(false); // Vote False
        vm.prank(userD);
        voting.vote(false); // Vote False

        // Skip to game expiry timestamp + 1
        uint256 newTimestamp = block.timestamp + 4 * 7 * 24 * 60 * 60 + 1;
        vm.warp(newTimestamp);

        voting.endVote();

        assertEq(4036363636363636363, userA.balance);
        assertEq(3027272727272727272, userB.balance);
        assertEq(2018181818181818181, userC.balance);
        assertEq(2018181818181818181, userD.balance);
    }

}
