// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";

contract ElectionTime is Ownable {
    uint256 private startTime;
    uint256 private endTime;

    //modifier to check if the voting has already started
    modifier votingStarted() {
        if (startTime != 0) {
            require(block.timestamp < startTime, "Voting has already started.");
        }
        _;
    }

    //modifier to check if the voting has ended
    modifier votingEnded() {
        if (endTime != 0) {
            require(block.timestamp < endTime, "Voting has already ended.");
        }
        _;
    }

    //modifier to check if the voting is active or not
    modifier votingDuration() {
        require(block.timestamp > startTime, "voting hasn't started");
        require(block.timestamp < endTime, "voting has already ended");
        _;
    }
    //modifier to check if the vote Duration and Locking periods are valid or not
    modifier voteValid(uint256 _startTime, uint256 _endTime) {
        require(
            block.timestamp < _startTime,
            "Starting time is less than current TimeStamp!"
        );
        require(_startTime < _endTime, "Invalid vote Dates!");
        _;
    }

    //function to get the voting start time
    function getStartTime() public view returns (uint256) {
        return startTime;
    }

    //function to get the voting end time
    function getEndTime() public view returns (uint256) {
        return endTime;
    }

    //function to set voting duration and locking periods
    function setVotingPeriodParams(uint256 _startTime, uint256 _endTime)
        external
        onlyOwner
        votingStarted
        voteValid(_startTime, _endTime)
    {
        startTime = _startTime;
        endTime = _endTime;
    }

    // Stop the voting
    function stopVoting() external onlyOwner {
        require(block.timestamp > startTime, "Voting hasn't started yet!");
        if (block.timestamp < endTime) {
            endTime = block.timestamp;
        }
    }
}
