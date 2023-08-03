// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title IERC20Token
 * @dev Interface for ERC20 token contract, providing necessary functions for token transfer and allowance.
 */
interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Marketplace
 * @dev Smart contract for a marketplace that allows users to buy, sell, and search for houses.
 */
contract Marketplace {

    uint internal housesLength = 0;
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    struct House {
        address payable owner;
        string name;
        string image;
        string description;
        string location;
        uint price;
        uint sold;
        uint supply;
    }

    mapping (uint => House) internal houses;
    mapping (address => uint[]) internal ownedHouses;

    /**
     * @dev Add a new house to the marketplace.
     * @param _name Name of the house.
     * @param _image Image URL of the house.
     * @param _description Description of the house.
     * @param _location Location of the house.
     * @param _price Price of the house in cUSD tokens.
     * @param _supply Total supply of the house.
     */
    function writeHouse(
        string memory _name,
        string memory _image,
        string memory _description, 
        string memory _location, 
        uint _price,
        uint _supply
    ) public {
        require(_price > 0, "Price must be greater than zero.");
        require(_supply > 0, "Supply must be greater than zero.");

        uint _sold = 0;
        houses[housesLength] = House(
            payable(msg.sender),
            _name,
            _image,
            _description,
            _location,
            _price,
            _sold,
            _supply
        );

        ownedHouses[msg.sender].push(housesLength);

        housesLength++;
    }

    /**
     * @dev Get the details of a house by its index.
     * @param _index Index of the house in the marketplace.
     * @return House details: owner, name, image, description, location, price, and number of houses sold.
     */
    function readHouse(uint _index) public view returns (
        address payable,
        string memory, 
        string memory, 
        string memory, 
        string memory, 
        uint, 
        uint
    ) {
        require(_index < housesLength, "Invalid house index.");

        return (
            houses[_index].owner,
            houses[_index].name, 
            houses[_index].image, 
            houses[_index].description, 
            houses[_index].location, 
            houses[_index].price,
            houses[_index].sold
        );
    }

    /**
     * @dev Buy a house from the marketplace using cUSD tokens.
     * @param _index Index of the house to be bought.
     */
    function buyHouse(uint _index) public payable {
        require(_index < housesLength, "Invalid house index.");
        require(houses[_index].supply > houses[_index].sold, "Ticket sold out");

        bool transferSuccess = IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            houses[_index].owner,
            houses[_index].price
        );
        require(transferSuccess, "Transfer failed.");

        houses[_index].sold++;
    }
    
    /**
     * @dev Get the total number of houses in the marketplace.
     * @return Total number of houses in the marketplace.
     */
    function getHousesLength() public view returns (uint) {
        return housesLength;
    }

    /**
     * @dev Get the total supply of a house by its index.
     * @param _index Index of the house in the marketplace.
     * @return Total supply of the house.
     */
    function readSupply(uint _index) public view returns(uint) {
        require(_index < housesLength, "Invalid house index.");

        return houses[_index].supply;
    }
    
    /**
     * @dev Check if a house can be bought.
     * @param _index Index of the house in the marketplace.
     * @return Boolean indicating if the house can be bought.
     */
    function disableBuy(uint _index) public view returns(bool) {
        require(_index < housesLength, "Invalid house index.");

        return houses[_index].supply == houses[_index].sold;
    }

    /**
     * @dev Get the indexes of all houses owned by the caller of the function.
     * @return Array of house indexes owned by the caller.
     */
    function getHousesIOwn() public view returns (uint[] memory) {
        return ownedHouses[msg.sender];
    }

    /**
     * @dev Get the indexes of all houses owned by a specific user.
     * @param _user Address of the user.
     * @return Array of house indexes owned by the user.
     */
    function getHousesOwnedByUser(address _user) public view returns (uint[] memory) {
        return ownedHouses[_user];
    }

    /**
     * @dev Search for houses by their location.
     * @param _location Location to search for.
     * @return Array of house indexes that match the specified location.
     */
    function searchHousesByLocation(string memory _location) public view returns (uint[] memory) {
        uint[] memory foundHouses = new uint[](housesLength);
        uint count = 0;

        for (uint i = 0; i < housesLength; i++) {
            if (keccak256(bytes(houses[i].location)) == keccak256(bytes(_location))) {
                foundHouses[count] = i;
                count++;
            }
        }

        uint[] memory result = new uint[](count);
        for (uint i = 0; i < count; i++) {
            result[i] = foundHouses[i];
        }

        return result;
    }
}
