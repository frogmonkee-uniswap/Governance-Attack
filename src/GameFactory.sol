// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Game} from "./CoreGame.sol";

contract GameFactory {
    uint256 internal gameCount = 0;
    Game public coreGame; // Address for deployed CoreGame.sol contract
    mapping(uint256 => address) public gameAddresses;

    function createNewGame(
        uint256 _costOfShare, 
        uint256 _votingPeriod, 
        uint256 _votingInterval, 
        uint256 _votingThreshold) 
        public returns(address payable) {
            coreGame = new Game(_costOfShare, _votingPeriod, _votingInterval, _votingThreshold);
            gameCount +=1;
            gameAddresses[gameCount] = address(coreGame);
            return payable(address(coreGame)); // Would this be sent to the FE so user know where the game contract is?
        }
}