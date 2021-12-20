pragma solidity 0.8.4;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

    // Point at which the contract can be executed or withdrawn
    uint256 contractDeadline = block.timestamp + 72 hours;
    // Has balance past threshold before contractDeadline
    bool ableToExecute = false;

    ExampleExternalContract public exampleExternalContract;
    // Upper bound that must be hit before all parties can execute the external contract
    uint256 public constant threshold = 2 ether;
    // The amount staked by each participant
    mapping(address => uint256) public stakedBalances;

    // Callback that an amount has been staked
    event Stake(address,uint256);

    constructor(address exampleExternalContractAddress) public {
        exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    function stake() public payable {
        require(this.timeLeft() != 0, "No time left on contract");
        stakedBalances[msg.sender] = stakedBalances[msg.sender] + msg.value;

        if (address(this).balance >= threshold) {
            ableToExecute = true;
        }

        emit Stake(msg.sender, msg.value);
    }


    // If contract balance is passed the threshold before the deadline then execute external contract
    function execute() external pastTimeThreshold {
        require(ableToExecute, "Staked balance has not passed threshold");
        require(!exampleExternalContract.completed(), "Contract has already been executed");

        exampleExternalContract.complete{value: address(this).balance}();
    }


    // if the `threshold` was not met, allow everyone to call a `withdraw()` function
    function withdraw() external pastTimeThreshold {
        uint256 sendersBalance = stakedBalances[msg.sender];
        require(sendersBalance != 0, "User has no balance to withdraw");
        stakedBalances[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: sendersBalance}("");
        require(success, "Failed to withdraw Ether");
    }


    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= contractDeadline) {
            return 0;
        }

        return contractDeadline - block.timestamp;
    }

    // TODO: Delete
    function inbetweenStake() external payable {
        stake();
    }

    // Fallback function for any eth sent to contract (special function so does not need function keyword)
    receive() external payable {
        stake(); // If you use this.stake{value: msg.value}() then msg.sender will be address(this)
    }

    // Ensures function is only called after contractDeadline
    modifier pastTimeThreshold() {
        require(this.timeLeft() == 0, "Contract has not ended yet");
        _;
    }
}
