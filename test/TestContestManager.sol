pragma solidity ^0.4.18;
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ContestManager.sol";
import "../contracts/Contest.sol";

contract TestContestManager 
{
    ContestManager cm = new ContestManager();

    function testBalanceOf0() public
    {
        uint b = cm.balanceOf(0);
        Assert.equal(b, 0, "testBalanceOf() failed, balance should be 0");
    }

    function testAddTokens() public
    {
        cm.addTokens(10,address(this));
        Assert.equal(10, cm.balanceOf(address(this)), "testAddTokens() failed, balance should be 10");
    }
    
    function testNewContest() public
    {
        Contest contest = Contest(cm.newContest(1525937318, 1525937319, "testNewContest",100, 2));
        Assert.equal(address(cm), address(contest.cm()), "testNewContest() failed, bad contest->cm");
        Assert.equal(cm.contests(contest), true, "testNewContest() failed, ContestManager->contests[] array not updated");
    }

    function testClaimTicket() public
    {
        // solium-disable-next-line security/no-block-members
        uint contestdeadline = now + 86400; // contest is tomorrow!
        Contest contest = Contest(cm.newContest(contestdeadline, contestdeadline + 1, "testClaimTicket",100, 2));
        Assert.equal(10, cm.balanceOf(address(this)), "testClaimTicket() failed, initial balance should be 10");
        Assert.equal(false, contest.claimedTickets(address(this)), "testClaimTicket() failed, ticket is already claimed");
        Assert.equal(contest.claimTicket(), true, "testClaimTicket() failed");
        Assert.equal(8, cm.balanceOf(address(this)), "testClaimTicket() failed, final balance should be 8");
        Assert.equal(true, contest.claimedTickets(address(this)), "testClaimTicket() failed, ticket is unclaimed");
    }

    function testClaimLastTicket() public
    {
        // solium-disable-next-line security/no-block-members
        uint contestdeadline = now + 86400; // contest is tomorrow!
        Contest contest = Contest(cm.newContest(contestdeadline, contestdeadline + 1, "testClaimLastTicket", 1, 2));
        Assert.equal(contest.claimTicket(), true, "testClaimLastTicket() failed");
        Assert.equal(6, cm.balanceOf(address(this)), "testClaimLastTicket() failed, final balance should be 6");
        Assert.equal(true, contest.claimedTickets(address(this)), "testClaimLastTicket() failed, ticket is unclaimed");
    }

    function testSpendLastToken() public
    {
        // solium-disable-next-line security/no-block-members
        uint contestdeadline = now + 86400; // contest is tomorrow!
        Contest contest = Contest(cm.newContest(contestdeadline, contestdeadline + 1, "testClaimTicket",100, 2));
        cm.setTotalTokens(address(this), 2);
        contest.claimTicket();
        Assert.equal(0, cm.balanceOf(address(this)), "testSpendLastToken() failed, final balance should be 0");
        Assert.equal(true, contest.claimedTickets(address(this)), "testSpendLastToken() failed, ticket is unclaimed");
    }

    function testFreeTicket() public
    {
        // solium-disable-next-line security/no-block-members
        uint contestdeadline = now + 86400; // contest is tomorrow!
        Contest contest = Contest(cm.newContest(contestdeadline, contestdeadline + 1, "testFreeTicket",100, 2));
        cm.setTotalTokens(address(this), 2);
        contest.claimTicket();
        Assert.equal(true, contest.freeTicket(), "testFreeTicket() failed, freeTicket() failed");
        Assert.equal(1, cm.balanceOf(address(this)), "testFreeTicket() failed, balance should be 1");
        Assert.equal(false, contest.claimedTickets(address(this)), "testFreeTicket() failed, ticket is claimed");
        Assert.equal(100, contest.availableTickets(), "testFreeTicket() failed, availableTickets should be 100");
    }
}
