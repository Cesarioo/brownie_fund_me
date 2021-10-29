// SPDX-License-Identifier: MIT

//https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol LINK FOR INTERFACE
//https://docs.chain.link/docs/ethereum-addresses/ ADDRESSES FOR TOKEN PRICES
pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol"; //import the interface to get prices

contract FundMe {
    address public owner; //set a variable address type called owner
    mapping(address => uint256) public AddressToAmountFunded; //creates a mapping which will be interprated later
    address[] public aFunder; //creates an array of addresses calles aFunder
    uint256 moneyin;
    AggregatorV3Interface public pricefeed;

    constructor(address _pricefeed) public {
        //at the initialisation of the contract, set the owner address to the msg.sender address
        owner = msg.sender;
        pricefeed = AggregatorV3Interface(_pricefeed);
    }

    function value() public view returns (uint256) {
        return moneyin;
    }

    function getDecimals() public view returns (uint256) {
        //get the decimals of our eth

        return pricefeed.decimals();
    }

    function getPrice() public view returns (uint256) {
        //get the price of our eth and sets in wei standart
        (, int256 answer, , , ) = pricefeed.latestRoundData();
        return uint256(answer * 10**10); //getprice has already 8 decimals so *10 for wei price
    }

    function getConversionRate(uint256 _ethAmount)
        public
        view
        returns (uint256)
    {
        //return a conversion rate in wei
        uint256 ethPriceUSD = getPrice();
        uint256 ethInUSD = (_ethAmount * ethPriceUSD) / 10**18; //the ethInUSD has 18 more decimals so erase them
        return ethInUSD;
    }

    function getEntranceFee() public view returns (uint256) {
        // mimimumUSD
        uint256 mimimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (mimimumUSD * precision) / price;
    }

    function fund() public payable {
        //fund function,
        uint256 minimumValueUSD = 5 * 10**18; //since getConversionRate is in wei, we also want minimumValueUSD in wei
        require(getConversionRate(msg.value) >= minimumValueUSD);
        aFunder.push(msg.sender);
        moneyin += msg.value;

        AddressToAmountFunded[msg.sender] += msg.value;
    }

    modifier onlyOwner() {
        //creates a modifier which can be used as a condition
        require(msg.sender == owner);
        _;
    }

    function withdraw() public payable onlyOwner {
        msg.sender.transfer(address(this).balance);
        for (
            uint256 _funderIndex = 0;
            _funderIndex < aFunder.length;
            _funderIndex++
        ) {
            // creates an index, as long as the index < lenght of the array, add +1 to the index
            address funders = aFunder[_funderIndex]; // creates à funders variable address type which is equal to the index
            AddressToAmountFunded[funders] = 0; //reinitialize the amount funded by the funder in the index
        }
        aFunder = new address[](0); //creates a new array
        moneyin = 0;
    }
}
