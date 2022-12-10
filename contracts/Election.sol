// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Types.sol";
import "./ElectionTime.sol";

/**
 * @title Election
 * @author Faraj Shuauib
 * @dev Implements voting process along with winning candidate
 */
contract Election is Ownable, ElectionTime {
    Types.Candidate[] public candidates;
    mapping(uint256 => Types.Voter) voter;
    mapping(uint256 => Types.Candidate) candidate;
    mapping(uint256 => uint256) internal votesCount;

    /**
     * @dev Get candidate list.
     * @return candidatesList_ All the politicians who participate in the election
     */
    function getCandidateList(uint256 voterIndex) public view returns (Types.Candidate[] memory) {
        Types.Voter storage voter_ = voter[voterIndex];
        uint256 _politicianOfMyConstituencyLength = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (
                voter_.stateCode == candidates[i].stateCode &&
                voter_.constituencyCode == candidates[i].constituencyCode
            ) _politicianOfMyConstituencyLength++;
        }
        Types.Candidate[] memory cc = new Types.Candidate[](
            _politicianOfMyConstituencyLength
        );

        uint256 _indx = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (
                voter_.stateCode == candidates[i].stateCode &&
                voter_.constituencyCode == candidates[i].constituencyCode
            ) {
                cc[_indx] = candidates[i];
                _indx++;
            }
        }
        return cc;
    }

    /**
     * @dev Get candidate list.
     * @return voterEligible_ Whether the voter with provided aadhar is eligible or not
     */
    function isVoterEligible(uint256 voterIndex)
        public
        view
        returns (bool voterEligible_)
    {
        Types.Voter storage voter_ = voter[voterIndex];
        if (voter_.age >= 18 && voter_.isAlive) voterEligible_ = true;
    }

    /**
     * @dev Know whether the voter casted their vote or not. If casted get candidate object.
     * @return userVoted_ Boolean value which gives whether current voter casted vote or not
     * @return candidate_ Candidate details to whom voter casted his/her vote
     */
    function didCurrentVoterVoted(uint256 voterIndex)
        public
        view
        returns (bool userVoted_, Types.Candidate memory candidate_)
    {
        userVoted_ = (voter[voterIndex].votedTo != 0);
        if (userVoted_) candidate_ = candidate[voter[voterIndex].votedTo];
    }

    /**
     * @dev Give your vote to candidate.
     */
    function vote(uint256 nominationNumber, uint256 voterIndex)
        public
        votingDuration
        isEligibleVote(voterIndex, nominationNumber)
    {
        // updating the current voter values
        voter[voterIndex].votedTo = nominationNumber;

        // updates the votes the politician
        uint256 voteCount_ = votesCount[nominationNumber];
        votesCount[nominationNumber] = voteCount_ + 1;
    }

    /**
     * @dev sends all candidate list with their votes count
     * @return candidateList_ List of Candidate objects with votes count
     */
    function getResults() public view returns (Types.Results[] memory) {
        Types.Results[] memory resultsList_ = new Types.Results[](
            candidates.length
        );
        for (uint256 i = 0; i < candidates.length; i++) {
            resultsList_[i] = Types.Results({
                name: candidates[i].name,
                partyShortcut: candidates[i].partyShortcut,
                partyFlag: candidates[i].partyFlag,
                nominationNumber: candidates[i].nominationNumber,
                stateCode: candidates[i].stateCode,
                constituencyCode: candidates[i].constituencyCode,
                voteCount: votesCount[candidates[i].nominationNumber]
            });
        }
        return resultsList_;
    }

    /**
     * @notice To check if the voter's age is greater than or equal to 18
     */
    modifier isEligibleVote(uint256 voterIndex, uint256 nominationNumber_) {
        Types.Voter memory voter_ = voter[voterIndex];
        Types.Candidate memory politician_ = candidate[nominationNumber_];
        require(voter_.age >= 18, "Voter is not eligible to vote");
        require(voter_.isAlive, "Voter is not alive");
        require(voter_.votedTo == 0, "Voter already voted");
        require(
            (politician_.stateCode == voter_.stateCode &&
                politician_.constituencyCode == voter_.constituencyCode),
            "Voter is not eligible to vote for this candidate"
        );
        _;
    }
}
