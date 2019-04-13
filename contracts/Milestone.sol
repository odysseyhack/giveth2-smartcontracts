pragma solidity 0.5.0;

contract Milestone {

    using SafeMath for uint;

	// Roles
    address public milestoneManager;
    address public reviewer;
    address public receiver;

    // Donation numbers
    uint public received;
    uint public requested;
    uint public commonsDonation;
    address public commonsAddress;

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
    event DonationReceived(uint amount, address donator, boolean commonsPledge);
    event MilestoneFunded();
    event PaymentCollected();

    constructor(address _receiver, uint _amountRequested) public {
    	recipient = _receiver;
    	requested = _amountRequested;
    	milestoneManager = msg.sender;
    	reviewer = msg.sender;
    }

    function donate(uint amount) public {
    	// Disallow donations after work is completed 
    	require(!done, "Donations are disallowed after a milestone is marked done.");

		received = received.add(amount);

    	// TODO: Implement isCommons!
    	if(isCommons(msg.sender)) {
	    	// Currently only one Commons donation is supported
	    	require(commonsDonation == 0, "Only one Commons donation currently supported.");
    		commonsDonation = amount;
    		commonsAddress = msg.sender;
			emit DonationReceived(amount, msg.sender, true);
    	} else {
			emit DonationReceived(amount, msg.sender, false);
    	}

    	// Mark as funded
    	if(received >= requested) {
    		if(!isFunded) {
    			emit MilestoneFunded();
    		}
    		isFunded = true;
    	}
    }

    function getAskAmount() public view returns (uint askAmount) {
    	if(done) {
    		return 0;
    	} else {
    		uint askAmount = requested.sub(received);
    		return askAmount;
    	}
    }

    function isCommons(address _donator) internal view returns (bool isCommons) {
    	uint random = uint(_donator);
    	if(random % 2 == 0) {
    		return true;
    	} else {
    		return false;
    	}
    }

    // Setters
    function setReviewer(address _newReviewer) public {
    	// Only milestone manager can change the reviewer.
    	require(msg.sender == milestoneManager);
    	reviewer = _newReviewer;
    }

    function markAsDone(boolean _done) public {
    	// Disallow change if milestone is already positively reviewed.
    	require(!reviewed);
    	// Only receiver can (un)mark done.
    	require(msg.sender == _receiver);

    	if(_done) {
	    	require(!done);
	    	done = true;
	    	emit MilestoneReviewRequested();
    	} else {
    		require(done);
    		done = false;
    	}		
    }

    function approve() public {
    	// Must not be reviewed yet.
    	require(!reviewed);
    	// Can only be reviewed by manager and reviewer
    	require(msg.sender == milestoneManager || msg.sender == reviewer);

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
    	require(msg.sender == receiver);
    	require(done);
    	require(reviewed);

    	paid = true;
    	// Send funds to Commons for tokens
    	// TODO: This call sends the tokens directly to the receiver. Might have to do two-step process.
    	uint remaining = received.sub(commonsDonation);
    	commonsAddress.mint(receiver, commonsDonation);

    	// Send remaining funds
    	receiver.transfer(remaining);

    	emit PaymentCollected();
    }

    function convertToDAI(uint tokenAmount) public {
    	// Only the receiver can convert their tokens here
    	//require(msg.sender == receiver);

    	commonsAddress.burn(tokenAmount);
    }
}

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }

}