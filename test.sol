// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract Auction_Contract {
    address payable public seller;

    bool public started;
    bool public ended;
    uint public endAt;

    uint public highestBid;
    address public highestBidder;

    event Start();
    event End(uint highestBid, address highestBidder);
    event Bid(uint amount, address indexed sender);
    event Withdraw(uint amount, address indexed bidder);

    mapping (address => uint) public bids;

    constructor () {
        seller = payable(msg.sender);
    }

    function startAuction (uint _startingBid) external {
        require(msg.sender == seller, "Only seller can start the auction!");
        require(!started, "Auction already started!");

        started = true;
        endAt = block.timestamp + 5 days;
        highestBid = _startingBid;
        emit Start();
    }

    function endAuction () external {
        require(started, "Auction should be started first before it ends!");
        require(block.timestamp > endAt, "Auction is still ongoing");
        require (!ended, "Auction already ended!");

        ended = true;

        emit End(highestBid, highestBidder);
    }

    function bid() external payable {
        require(started, "Auction should be started first!");
        require(block.timestamp < endAt, "Auction already ended!");
        require(msg.value > highestBid, "Value is less than highestBid!");

        highestBid = msg.value;
        highestBidder = msg.sender;

        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        emit Bid(highestBid, highestBidder);
    }

    function withdraw () external payable {
        uint balance = bids[msg.sender];
        bids[msg.sender] = 0;
        (bool isSent, ) = payable(msg.sender).call{value: balance}("");
        require(isSent, "Withdrawing failled!");

        emit Withdraw(balance, msg.sender);
    }
}