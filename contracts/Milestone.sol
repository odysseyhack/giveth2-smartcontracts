pragma solidity ^0.5.0;

import "./ConvictionVoting.sol";
import "./CommonsToken.sol";

contract Milestone {

    using SafeMath for uint;

	// Roles
    address public milestoneManager;
    address public reviewer;
    address payable public receiver;

    // Donation numbers
    uint public received;
    uint public requested;
    uint public commonsDonation;

    // Contract interactions
    ConvictionVoting public commons;
    address public bondedTokenAddress;

    // Process flags
    bool public isFunded;
    bool public done;
    bool public reviewed;
    bool public paid;

    // Events
    // Review events 
    event MilestoneReviewRequested();
    event MilestoneReviewRequestRejected(address reviewer);
    event MilestoneReviewRequestApproved(address reviewer);
    // Payment events
    event DonationReceived(uint amount, address donator, bool commonsPledge);
    event MilestoneFunded();
    event PaymentCollected();

    constructor(address payable _receiver, uint _amountRequested) public {
    	receiver = _receiver;
    	requested = _amountRequested;
    	milestoneManager = msg.sender;
    	reviewer = msg.sender;
    }

    // Allow direct donations
    function() external payable {
        donate();
    }

    function fakeDonate(address payable commonsAddress) public payable {
        // Disallow donations after work is completed 
        require(msg.value > 0, "Donations with no value are not accepted.");
        require(!done, "Donations are disallowed after a milestone is marked done.");

        received = received.add(msg.value);

        if(isCommons(commonsAddress)) {
            // Currently only one Commons donation is supported
            require(commonsDonation == 0, "Only one Commons donation currently supported.");
            commonsDonation = msg.value;
            // Set commons addresses (DAO & token)
            commons = ConvictionVoting(commonsAddress);
            bondedTokenAddress = address(commons.token());
            emit DonationReceived(msg.value, commonsAddress, true);
        } else {
            emit DonationReceived(msg.value, commonsAddress, false);
        }

        // Mark as funded
        if(received >= requested) {
            if(!isFunded) {
                emit MilestoneFunded();
            }
            isFunded = true;
        }
    }

    function donate() public payable {
    	// Disallow donations after work is completed 
        require(msg.value > 0, "Donations with no value are not accepted.");
    	require(!done, "Donations are disallowed after a milestone is marked done.");

		received = received.add(msg.value);

    	if(isCommons(msg.sender)) {
	    	// Currently only one Commons donation is supported
	    	require(commonsDonation == 0, "Only one Commons donation currently supported.");
    		commonsDonation = msg.value;
            // Set commons addresses (DAO & token)
            commons = ConvictionVoting(msg.sender);
            bondedTokenAddress = address(commons.token());
			emit DonationReceived(msg.value, msg.sender, true);
    	} else {
			emit DonationReceived(msg.value, msg.sender, false);
    	}

    	// Mark as funded
    	if(received >= requested) {
    		if(!isFunded) {
    			emit MilestoneFunded();
    		}
    		isFunded = true;
    	}
    }

    function getAskAmount() public view returns (uint _askAmount) {
    	if(done) {
    		return 0;
    	} else {
    		uint askAmount = requested.sub(received);
    		return askAmount;
    	}
    }

    // TODO: Implement correctly. Currently checks if donator is a contract.
    function isCommons(address payable _donator) internal view returns (bool _isCommons) {
        uint32 size;
        assembly {
            size := extcodesize(_donator)
        }
        return (size > 0);
    }

    // Setters
    function setReviewer(address _newReviewer) public {
    	require(msg.sender == milestoneManager, "Only the milestone manager can change the reviewer.");
    	reviewer = _newReviewer;
    }

    function markAsDone(bool _done) public {
    	// Disallow change if milestone is already positively reviewed.
    	require(!reviewed, "Status of the milestone cannot be changed after review.");
    	// Only receiver can (un)mark done.
    	require(msg.sender == receiver, "Only the receiver of the milestone can mark this milestone done.");

    	if(_done) {
	    	require(!done, "Milestone was already marked done.");
	    	done = true;
	    	emit MilestoneReviewRequested();
    	} else {
    		require(done, "Cannot mark milestone as unfinished when it is already marked as unfinished.");
    		done = false;
    	}		
    }

    function approve() public {
    	// Must not be reviewed yet.
        require(isFunded, "Unfunded milestones cannot be approved.");
        // TODO: Possible disallow approving when it's not marked done.
    	require(!reviewed, "Milestone is already reviewed.");
    	// Can only be reviewed by manager and reviewer
    	require(msg.sender == milestoneManager || msg.sender == reviewer, "Only reviewers can approve a milestone.");

    	reviewed = true;
    	emit MilestoneReviewRequestApproved(msg.sender);
    }

    function reject() public {
    	// ATTN!: Can be rejected AFTER approve (so reviewers can veto).

    	// Can only be reviewed by manager and reviewer
    	require(msg.sender == milestoneManager || msg.sender == reviewer, "msg.sender not in reviewer chain.");

    	done = false;
    	emit MilestoneReviewRequestRejected(msg.sender);
    }

    function payout() public {
    	require(msg.sender == receiver, "Only the receiver of the milestone can request payout.");
    	require(reviewed, "Payout can only happen after milestone is reviewed.");

    	paid = true;
    	// Send funds to Commons for tokens
    	// TODO: This call sends the tokens directly to the receiver. Might have to do two-step process.
        uint remaining = received.sub(commonsDonation);
        if(commonsDonation > 0) {
            CommonsToken bondedToken = CommonsToken(bondedTokenAddress);
            //bondedToken.mint.value(msg.value)();
            //bondedToken.mint(commonsDonation);
            //bondedToken.transfer(receiver, commonsDonation);
            //bondedToken.fundsAllocated(commonsDonation);
        }
    	
    	// Send remaining funds
    	receiver.transfer(remaining);

    	emit PaymentCollected();
    }

    function convertToDAI(uint tokenAmount) public {
    	// Only the receiver can convert their tokens here
    	require(msg.sender == receiver);
        require(bondedTokenAddress != address(0), "No token address was registered for conversion.");
        //require(tokenAmount <= commonsDonation, "Amount exceeds commons donation.");
    	CommonsToken commonsToken = CommonsToken(bondedTokenAddress);
        uint tokenAmount = commonsToken.burn(tokenAmount);
        ERC20 externalToken = commonsToken.externalToken();
        externalToken.transfer(msg.sender, tokenAmount);
    }

    function proposeToCommons(address payable _commonsAddress) public {
    	ConvictionVoting cv = ConvictionVoting(_commonsAddress);
    	uint proposalId = uint(address(this));
        uint amountRequired = getAskAmount();
    	cv.addProposal(amountRequired, proposalId);
    }
}
