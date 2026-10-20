// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title GeoDigitalRWA
 * @dev Fractionalized Real-World Asset (RWA) Token for Geological Perimeter Exploitation Rights
 *      Includes automated 2% protocol fee and automated academic/research royalty routing.
 */
contract GeoDigitalRWA is ERC20, Ownable {
    string public perimeterID;
    address public academicRoyaltyAddress;
    address public protocolTreasury;
    
    uint256 public constant PROTOCOL_FEE_BPS = 200; // 2.00%
    uint256 public constant ROYALTY_FEE_BPS = 100;  // 1.00%

    event DepositAndMint(address indexed investor, uint256 amountTokenized, uint256 protocolFee);
    event RoyaltyPaid(address indexed researcher, uint256 amount);

    constructor(
        string memory _perimeterID,
        string memory _tokenName,
        string memory _tokenSymbol,
        address _academicRoyaltyAddress,
        address _protocolTreasury,
        uint256 _initialSupply
    ) ERC20(_tokenName, _tokenSymbol) Ownable(msg.sender) {
        require(_academicRoyaltyAddress != address(0), "Invalid royalty address");
        require(_protocolTreasury != address(0), "Invalid treasury address");

        perimeterID = _perimeterID;
        academicRoyaltyAddress = _academicRoyaltyAddress;
        protocolTreasury = _protocolTreasury;

        _mint(msg.sender, _initialSupply * 10**decimals());
    }

    /**
     * @dev Process query royalty to academic IP contributors
     */
    function executeQueryRoyalty() external payable {
        require(msg.value > 0, "Query fee required");
        
        uint256 protocolShare = (msg.value * PROTOCOL_FEE_BPS) / 10000;
        uint256 academicShare = msg.value - protocolShare;

        payable(protocolTreasury).transfer(protocolShare);
        payable(academicRoyaltyAddress).transfer(academicShare);

        emit RoyaltyPaid(academicRoyaltyAddress, academicShare);
    }

    function setAcademicRoyaltyAddress(address _newAddress) external onlyOwner {
        require(_newAddress != address(0), "Invalid address");
        academicRoyaltyAddress = _newAddress;
    }
}
