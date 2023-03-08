// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

/**
 * @title Types
 * @author Faraj Shuauib
 * @dev All custom types that we have used in E-Voting will be declared here
 */
library Types {
    struct Voter {
        uint256 id;
        uint256 nationalId; // voter unique ID example: الرقم الوطني
        string name;
        uint8 age;
    }

    struct Candidate {
        // Note: If we can limit the length to a certain number of bytes,
        // we can use one of bytes1 to bytes32 because they are much cheaper
        uint256 id;
        uint256 nationalId; // candidate unique ID example: الرقم الوطني
        string name;
        uint8 age;
        string kyc_hash_link;
    }

    struct Vote {
        uint256 id;
        uint256 voterId;
        uint256 candidateId;
    }

    struct Result {
        uint256 candidateId;
        uint256 votes;
    }
}
