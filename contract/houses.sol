// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

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

contract Marketplace {

    uint internal housesLength = 0;
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

       event HouseAdded(
        address indexed owner,
        string name,
        string image,
        string description,
        string location,
        uint price,
        uint supply
    );

    event HousePurchased(
        uint indexed index,
        address buyer,
        uint price
    );


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

    function writeHouse(
        string memory _name,
        string memory _image,
        string memory _description, 
        string memory _location, 
        uint _price,
        uint _supply
    ) public {
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
        housesLength++;
          emit HouseAdded(
            msg.sender,
            _name,
            _image,
            _description,
            _location,
            _price,
            _supply
        );
    }

    function readHouse(uint _index) public view returns (
        address payable,
        string memory, 
        string memory, 
        string memory, 
        string memory, 
        uint, 
        uint
          ) {

              
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

  function buyHouse(uint _index) public payable {
    require(_index < housesLength, "Invalid house index"); // Check if the house exists at the given index
    require(houses[_index].supply != houses[_index].sold, "Ticket sold out");
    require(
        IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            houses[_index].owner,
            houses[_index].price
        ),
        "Transfer failed."
    );
    houses[_index].sold++;

      emit HousePurchased(
            _index,
            msg.sender,
            houses[_index].price
        );
}

    
    function getHousesLength() public view returns (uint) {
        return (housesLength);
    }

    function readSupply(uint _index) public view returns(uint) {
        return houses[_index].supply;
    }
    
  function disableBuy(uint _index) public view returns (bool) {
    if (houses[_index].supply == houses[_index].sold) {
        return true; // Buying is disabled when the house is sold out.
    } else {
        return false; // Buying is enabled when the house is still available.
    }
}

}
