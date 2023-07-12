// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Voting} from "./Voting.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "forge-std/console.sol";


contract SharesContract is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mintShares(address recipient, uint256 amount) external {
        _mint(recipient, amount);
    }
}

contract Game {
    event RemainderTransferred(address recipient, uint256 amount);
    event TotalSharesIssued(address depositor, uint256 shares);

    uint public costOfShare; // How much ETH a single share costs
    uint public votingPeriod; // How long between each new vote instance (days)
    uint public votingInterval; // How long a single vote lasts (hours)
    uint public votingThreshold; // What percentage of yes votes are need (%)
    uint public expiration; // Game ends if no votes pass (weeks)
    uint public playerCounter = 0;
    mapping(uint => address) depositors;
    mapping(address => uint) winnerPayout;
    address[] public winnerPayoutIndex; // Keeps index of all addresses in `winnerPayout`

    Voting public votingContract; // Declare variable to hold voting contract type
    SharesContract public sharesContract; // Declare variable to hold ERC20 contract type

    constructor(
    uint _costOfShare, 
    uint _votingPeriod, 
    uint _votingInterval, 
    uint _votingThreshold,
    uint _expiration) 
    {
        costOfShare = _costOfShare * 10**18; // Converts into ETH
        votingPeriod = _votingPeriod;
        votingInterval = _votingInterval;
        votingThreshold = _votingThreshold;
        expiration = (_expiration * 604800) + block.timestamp; // Converts weeks into seconds

        sharesContract = new SharesContract("GovernanceAttack", "ATK"); // Will store address of ERC20 contract
        votingContract = new Voting(votingPeriod, votingInterval, votingThreshold, expiration, address(sharesContract), payable(address(this))); // Will store address of voting contract

    }
    modifier gameOngoing() {
        require(block.timestamp < expiration, "This game has expired.");
        _; // Checks if the game has passed it expiry timestamp
    }

    function deposit() public payable gameOngoing returns (uint256) {
        // Require that vote is not ongoing
        uint256 quotient = msg.value / costOfShare; // Shares issued
        uint256 remainder = msg.value % costOfShare; // Remainder to be reverted

        if (remainder > 0) { // Refunds remainder
            payable(msg.sender).transfer(remainder);
            emit RemainderTransferred(msg.sender, remainder);
        }
        sharesContract.mintShares(msg.sender, quotient); // Mints ERC20 token as shares
        uint shares = sharesContract.balanceOf(msg.sender);
        playerCounter +=1; // Increment player counter
        depositors[playerCounter] = msg.sender; // Log depositor in mapping
        emit TotalSharesIssued(msg.sender, shares); // Emits alert for # of shares owned
        return shares; // # of total shares
    }

    function distribute() external {
        require(msg.sender == address(votingContract)); // Requires that only voting contract can call distribute
        address votingContractAddress = address(votingContract);
        uint256 totalYesVotes = Voting(votingContract).getTotalYesVotes(); // sum of all yes votes
        for (uint i=0; i < Voting(votingContractAddress).voterListLength(); i++) { // Calculates payout value for winners
            if(Voting(votingContractAddress).getVotedYes(i)) {
                uint balance = sharesContract.balanceOf(Voting(votingContractAddress).getVoter(i)); // Balance of tokens
                uint payout = balance * address(this).balance / totalYesVotes; // Calculate payout
                winnerPayout[Voting(votingContractAddress).getVoter(i)] = payout; // Payout mapping
                winnerPayoutIndex.push(Voting(votingContractAddress).getVoter(i)); // Add to indexed array of winners
            } else {
                // Do nothing
            }
        }
        for (uint i=0; i < winnerPayoutIndex.length; i++) { // Pay
            payable(winnerPayoutIndex[i]).transfer(winnerPayout[winnerPayoutIndex[i]]);
        }
    }

    function endGame() public {
        // The additional ETH deposited with "Yes" votes is distributed pro-rata among all depositors, not back to those who voted "Yes". This is because I'm lazy. 
        require(block.timestamp >= expiration, "Game is still ongoing.");
        uint256 totalSupply = sharesContract.totalSupply();
        uint256 balance = address(this).balance;
        for (uint256 i = 1 ; i <= playerCounter; i++) {
            uint256 shares = sharesContract.balanceOf(depositors[i]);
            uint256 amountRefunded =  balance * shares / totalSupply;
            payable(depositors[i]).transfer(amountRefunded);
        }
    }

    receive() external payable {
    }
}