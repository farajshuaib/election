// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./Types.sol";
import "./ElectionTime.sol";

/**
 * @title Election
 * @author Faraj Shuauib
 * @dev Implements voting process along with winning candidate
 */
contract Election is Ownable, ElectionTime {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using Address for address payable;

    Counters.Counter private _voterIds;
    Counters.Counter private _ccandidateIds;
    Counters.Counter private _voteIds;

    uint256 private _service_fees = 3 ether;

    constructor() {
        _voterIds.increment();
        _ccandidateIds.increment();
    }

    mapping(uint256 => Types.Voter) idVoter;
    mapping(uint256 => Types.Candidate) idCandidate;
    mapping(uint256 => Types.Vote) idVote;

    /**
     * @notice To check if the voter's age is greater than or equal to 18
     */
    modifier isEligibleVote(uint256 voterIndex, uint256 candidateIndex) {
        require(msg.sender != address(0), "address not found !!");
        require(
            idVoter[voterIndex].nationalId != 0,
            "You are not registered as a voter"
        );
        require(
            idCandidate[candidateIndex].nationalId != 0,
            "You are not trying to vote for not registered candidate"
        );
        require(
            idVote[voterIndex].voterId == 0,
            "You are already voted for this election, you can't vote again"
        );
        _;
    }

    modifier isEligibleToRegisterAsVoter(
        uint256 nationalId,
        string memory name,
        uint8 age
    ) {
        require(msg.sender != address(0), "address not found !!");
        require(
            idVoter[nationalId].nationalId == 0,
            "You are already registered as a voter"
        );
        require(age >= 18, "You are not eligible to register as a voter");
        require(
            bytes(name).length > 0,
            "You must enter your name to register as a voter"
        );
        _;
    }

    modifier isEligibleToRegisterAsCandidate(
        uint256 nationalId,
        string memory name,
        uint8 age,
        string memory kyc_hash_link
    ) {
        require(msg.sender != address(0), "address not found !!");
        require(
            idCandidate[nationalId].nationalId == 0,
            "You are already registered as a candidate"
        );
        require(age >= 18, "You are not eligible to register as a candidate");
        require(
            bytes(name).length > 0,
            "You must enter your name to register as a candidate"
        );
        require(
            bytes(kyc_hash_link).length > 0,
            "You must enter your kyc_hash_link to register as a candidate"
        );
        _;
    }

    event CandidateCreated(
        uint256 id,
        uint256 nationalId,
        string name,
        string kyc_hash_link
    );

    event FeeTransferedSuccessfully(address from, address to, uint256 amount);

    function getServiceFees() public view returns (uint256) {
        return _service_fees;
    }

    function setServiceFees(uint256 service_fees) public onlyOwner {
        _service_fees = service_fees;
    }

    function createVoter(
        string memory name,
        uint256 nationalId,
        uint8 age
    ) public votingDuration isEligibleToRegisterAsVoter(nationalId, name, age) {
        _voterIds.increment();
        uint256 newVoterId = _voterIds.current();

        idVoter[newVoterId] = Types.Voter({
            id: newVoterId,
            nationalId: nationalId,
            name: name,
            age: age
        });
    }

    function createCandidate(
        string memory name,
        uint256 nationalId,
        uint8 age,
        string memory kyc_hash_link
    )
        public
        payable
        votingDuration
        isEligibleToRegisterAsCandidate(nationalId, name, age, kyc_hash_link)
    {
        _ccandidateIds.increment();
        uint256 newCandidateId = _ccandidateIds.current();

        idCandidate[newCandidateId] = Types.Candidate({
            id: newCandidateId,
            nationalId: nationalId,
            name: name,
            age: age,
            kyc_hash_link: kyc_hash_link
        });

        emit CandidateCreated(newCandidateId, nationalId, name, kyc_hash_link);

        payable(owner()).transfer(getServiceFees());

        emit FeeTransferedSuccessfully(msg.sender, owner(), getServiceFees());
    }

    function vote(
        uint256 voterIndex,
        uint256 candidateIndex
    ) public votingDuration isEligibleVote(voterIndex, candidateIndex) {
        _voteIds.increment();
        uint256 newVoteId = _voteIds.current();

        idVote[newVoteId] = Types.Vote({
            id: newVoteId,
            voterId: voterIndex,
            candidateId: candidateIndex
        });
    }

    function getVoter(
        uint256 voterIndex
    ) public view returns (Types.Voter memory) {
        return idVoter[voterIndex];
    }

    function getCandidate(
        uint256 candidateIndex
    ) public view returns (Types.Candidate memory) {
        return idCandidate[candidateIndex];
    }

    function getVote(
        uint256 voteIndex
    ) public view returns (Types.Vote memory) {
        return idVote[voteIndex];
    }

    function getVoterCount() public view returns (uint256) {
        return _voterIds.current();
    }

    function getCandidateCount() public view returns (uint256) {
        return _ccandidateIds.current();
    }

    function getVoteCount() public view returns (uint256) {
        return _voteIds.current();
    }

    function getVotersList() public view returns (Types.Voter[] memory) {
        uint256 voterCount = getVoterCount();
        Types.Voter[] memory voters = new Types.Voter[](voterCount);
        for (uint256 i = 1; i <= voterCount; i++) {
            voters[i - 1] = getVoter(i);
        }
        return voters;
    }

    function getCandidatesList()
        public
        view
        returns (Types.Candidate[] memory)
    {
        uint256 candidateCount = getCandidateCount();
        Types.Candidate[] memory candidates = new Types.Candidate[](
            candidateCount
        );
        for (uint256 i = 1; i <= candidateCount; i++) {
            candidates[i - 1] = getCandidate(i);
        }
        return candidates;
    }

    function getVotesList() public view returns (Types.Vote[] memory) {
        uint256 voteCount = getVoteCount();
        Types.Vote[] memory votes = new Types.Vote[](voteCount);
        for (uint256 i = 1; i <= voteCount; i++) {
            votes[i - 1] = getVote(i);
        }
        return votes;
    }

    function getCandidateVotes(
        uint256 candidateIndex
    ) public view returns (Types.Vote[] memory) {
        uint256 voteCount = getVoteCount();
        Types.Vote[] memory votes = new Types.Vote[](voteCount);
        uint256 j = 0;
        for (uint256 i = 1; i <= voteCount; i++) {
            if (idVote[i].candidateId == candidateIndex) {
                votes[j] = getVote(i);
                j++;
            }
        }
        return votes;
    }

    function getWinnerCandidate() public view returns (Types.Candidate memory) {
        uint256 candidateCount = getCandidateCount();
        uint256 maxVotes = 0;
        uint256 winnerCandidateId = 0;
        for (uint256 i = 1; i <= candidateCount; i++) {
            uint256 candidateVotesCount = getCandidateVotes(i).length;
            if (candidateVotesCount > maxVotes) {
                maxVotes = candidateVotesCount;
                winnerCandidateId = i;
            }
        }
        return getCandidate(winnerCandidateId);
    }
}
