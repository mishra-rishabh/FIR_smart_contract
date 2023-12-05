// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0 <= 0.9.0;

contract PoliceComplaint {
    address public officerAddr;                     // Address of the police officer
    address public ownerAddr;                       // Address of the contract owner
    uint public nextId;                             // Next available ID for tracking complaints

    uint[] public pendingApprovals;                 // Complaints pending officer approval
    uint[] public pendingResolutions;               // Complaints pending resolution
    uint[] public resolvedCases;                    // Resolved complaints

    struct complaint {
        uint id;                                    // Unique complaint ID
        address complaintRegisteredBy;              // Address of the person who filed the complaint
        string title;                               // Title of the complaint
        string description;                         // Description of the complaint
        string approvalRemark;                      // Remark for approval status
        string resolutionRemark;                    // Remark for resolution status
        bool isApproved;                            // Flag indicating whether the complaint is approved
        bool isResolved;                            // Flag indicating whether the complaint is resolved
        bool isExist;                               // Flag indicating whether the complaint exists
    }

    // Mapping to store complaints with their respective IDs
    mapping(uint => complaint) public complaints;

    // Event emitted when a new complaint is filed
    event complaintFiled(uint id, address complaintRegisteredBy, string title);

    // Constructor function to initialize the contract with the officer's address
    constructor(address _officerAddr) {
        ownerAddr = msg.sender;                     // Set the contract owner as the deployer
        officerAddr = _officerAddr;                 // Set the provided officer's address
        nextId = 1;                                 // Start with ID 1 for the first complaint
    }

    // Modifier to restrict certain functions to only the contract owner
    modifier onlyOwner() {
        require(msg.sender == ownerAddr, "You are not the owner!");
        _;
    }

    // Modifier to restrict certain functions to only the police officer
    modifier onlyOfficer() {
        require(msg.sender == officerAddr, "You are not the officer!");
        _;
    }

    // Function for filing a new complaint
    function fileAComplaint(string memory _title, string memory _description) public {
        complaint storage newComplaint = complaints[nextId];

        // Initialize the new complaint
        newComplaint.id = nextId;
        newComplaint.complaintRegisteredBy = msg.sender;
        newComplaint.title = _title;
        newComplaint.description = _description;
        newComplaint.approvalRemark = "Pending Approval";
        newComplaint.resolutionRemark = "Pending Resolution";
        newComplaint.isApproved = false;
        newComplaint.isResolved = false;
        newComplaint.isExist = true;

        // Emit an event indicating the filing of a new complaint
        emit complaintFiled(nextId, msg.sender, _title);

        // Increment the ID for the next complaint
        nextId++;
    }

    // Function for the officer to approve a complaint
    function approveComplaint(uint _id, string memory _approvalRemark) public onlyOfficer {
        require(complaints[_id].isExist == true, "Complaint not found!");
        require(complaints[_id].isApproved == false, "Complaint already approved!");

        // Mark the complaint as approved and set the approval remark
        complaints[_id].isApproved = true;
        complaints[_id].approvalRemark = _approvalRemark;
    }

    // Function for the officer to decline a complaint
    function declineComplaint(uint _id, string memory _approvalRemark) public onlyOfficer {
        require(complaints[_id].isExist == true, "Complaint not found!");
        require(complaints[_id].isApproved == false, "Complaint already approved!");

        // Mark the complaint as non-existent and provide a rejection remark
        complaints[_id].isExist = false;
        complaints[_id].approvalRemark = string.concat("This complaint is rejected. Reason: ", _approvalRemark);
    }

    // Function for the officer to resolve a complaint
    function resolveComplaint(uint _id, string memory _resolutionRemark) public onlyOfficer {
        require(complaints[_id].isExist == true, "Complaint not found!");
        require(complaints[_id].isApproved == true, "Complaint is not yet approved!");
        require(complaints[_id].isResolved == false, "Complaint is already resolved!");

        // Mark the complaint as resolved and set the resolution remark
        complaints[_id].isResolved = true;
        complaints[_id].resolutionRemark = _resolutionRemark;
    }

    // Function to calculate the IDs of complaints pending officer approval
    function calculatePendingApprovalIds() public {
        delete pendingApprovals;                    // delete the previously stored values

        // Loop through all complaints and add IDs with pending approval status
        for(uint i = 1; i < nextId; i++) {
            if(complaints[i].isApproved == false && complaints[i].isExist == true) {
                pendingApprovals.push(complaints[i].id);
            }
        }
    }

    // Function to calculate the IDs of complaints pending resolution
    function calculatePendingResolutionIds() public {
        delete pendingResolutions;                  // delete the previously stored values

        // Loop through all complaints and add IDs with pending resolution status
        for(uint i = 1; i < nextId; i++) {
            if(complaints[i].isResolved == false && complaints[i].isApproved == true && complaints[i].isExist == true) {
                pendingResolutions.push(complaints[i].id);
            }
        }
    }

    // Function to calculate the IDs of resolved complaints
    function calculateResolvedIds() public {
        delete resolvedCases;                       // delete the previously stored values

        // Loop through all complaints and add IDs with resolved status
        for(uint i = 1; i < nextId; i++) {
            if(complaints[i].isResolved == true) {
                resolvedCases.push(complaints[i].id);
            }
        }
    }

    // Function to set the officer's address (can only be called by the contract owner)
    function setOfficerAddress(address _officer) public onlyOwner {
        officerAddr = _officer;
    }
}
