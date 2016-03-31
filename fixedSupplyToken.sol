contract Token {
    function transfer(address receiver, uint amount) {}
}


contract Crowdsale {
    address public beneficiary;
    uint public fundingGoal;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    Token public tokenReward;
    Funder[] public funders;
    bool crowdsaleClosed;

    event FundTransfer(address backer, uint amount, bool isContribution);

    /* Data structure to hold information about campain contributors */
    struct Funder {
        address addr;
        uint amount;
    }

    /* At initialization, setup the owner */
    function Crowdsale(
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint durationInMinutes,
        uint etherCostOfEachToken,
        token addressOfTokenUsedAsReward
    ) {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = etherCostOfEachToken * 1 ether;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    /* The function without name is the default function that is called whenever anyone sends funds to a contract */
    function () {
        if (crowdsaleClosed)
            throw;
        uint amount = msg.value;
        funders[funders.length++] = Funder({addr: msg.sender, amount: amount});
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount / price);
        FundTransfer(msg.sender, amount, true);
    }

    modifier afterDeadLine() {
        if (now >= deadline)
            _
    }

    /* Checks if the goal or time limit has been reached and ends the campain */
    function checkGoalReached() afterDeadLine {
        if (crowdsaleClosed)
            throw;

        if (amountRaised > fundingGoal) {
            beneficiary.send(amountRaised);
            FundTransfer(beneficiary, amountRaised, false);
        }
        else {
            for (uint i = 0; i < funders.length; i++) {
                funders[i].addr.send(funders[i].amount);
                FundTransfer(funders[i].addr, funders[i].amount, false);
            }
        }

        // Send any remaining balance to beneficiary anyway
        beneficiary.send(this.balance);
        crowdsaleClosed = true;
    }
}
