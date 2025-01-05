// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Crowdfunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;
    }
    // Mapping from campaign id to campaign -> Required in solidity as opposed to JS for arrays
    mapping(uint256 => Campaign) public campaigns;
    uint256 public numberOfCampaigns = 0;

    function createCampaign(address _owner, string memory _title, string memory _description, uint256 _target, uint256 _deadline, string memory _image) public returns (uint256){
        // 
        Campaign storage campaign = campaigns[numberOfCampaigns];
        
        // Check if everything is ok?
        require(campaign.deadline < block.timestamp, "Deadline must be in the future");

        // Create a new campaign with the given parameters
        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.image = _image;

        numberOfCampaigns++;

        return numberOfCampaigns-1;
    }


    // payable -> function can receive ether
    function donateToCampaign(uint256 _id) public payable {

        // The value we want to donate from frontend
        uint256 amount = msg.value;

        Campaign storage campaign = campaigns[_id];

        // Push the donator and the amount to the campaign array
        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);


        // Send the amount to the owner of the campaign
        (bool sent,) = payable(campaign.owner).call{value: amount}("");

        if (sent) {
            campaign.amountCollected = campaign.amountCollected + amount;
        }
    }


    // Parameters are the id of the campaign and the address of the donator in array
    // Returns the address of the donator and the amount donated
    function getDonators(uint256 _id) view public returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, campaigns[_id].donations);

    }


    // Returns the campaign with the given id
    function getCampaigns() public view returns (Campaign[] memory) { 
        // Create a new var of allCampaigns is a type of multiple campaign structs 
        // Create array of empty elements as the same number of the no. of campaigns
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        // Loop through all the campaigns and add them to the allCampaigns array
        for (uint i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];

            allCampaigns[i] = item;
        }

        return allCampaigns;
    }

    
}