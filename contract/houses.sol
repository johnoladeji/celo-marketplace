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

    /**
     * @dev Emitted when a new house is created in the marketplace.
     * @param owner The address of the house owner.
     * @param name The name of the house.
     * @param image The image URL of the house.
     * @param description The description of the house.
     * @param location The location of the house.
     * @param price The price of the house in cUSD.
     * @param supply The initial supply of the house available for purchase.
     */
    event HouseCreated(
        address indexed owner,
        string name,
        string image,
        string description,
        string location,
        uint price,
        uint supply
    );

    /**
     * @dev Emitted when a house is purchased from the marketplace.
     * @param buyer The address of the buyer who purchased the house.
     * @param seller The address of the seller who owned the house.
     * @param houseIndex The index of the house in the marketplace.
     * @param price The price of the house in cUSD.
     */
    event HousePurchased(
        address indexed buyer,
        address indexed seller,
        uint indexed houseIndex,
        uint price
    );

    /**
     * @dev Emitted when a house is sold out, meaning all units of the house are purchased.
     * @param houseIndex The index of the house that is sold out in the marketplace.
     */
    event HouseSoldOut(uint indexed houseIndex);

    /**
    * @dev Creates a new house in the marketplace.
    * @param _name The name of the house.
    * @param _image The image URL of the house.
    * @param _description The description of the house.
    * @param _location The location of the house.
    * @param _price The price of the house in cUSD.
    * @param _supply The initial supply of the house available for purchase.
    * Requirements:
    * - `_name` cannot be an empty string.
    * - `_image` cannot be an empty string.
    * - `_description` cannot be an empty string.
    * - `_location` cannot be an empty string.
    * - `_price` must be greater than zero.
    * - `_supply` must be greater than zero.
    * Emits a {HouseCreated} event when the house is successfully created.
    */
    function writeHouse(
        string memory _name,
        string memory _image,
        string memory _description, 
        string memory _location, 
        uint _price,
        uint _supply
    ) public {
        require(bytes(_name).length > 0, "House name cannot be empty");
        require(bytes(_image).length > 0, "House image URL cannot be empty");
        require(bytes(_description).length > 0, "House description cannot be empty");
        require(bytes(_location).length > 0, "House location cannot be empty");
        require(_price > 0, "House price must be greater than zero");
        require(_supply > 0, "House supply must be greater than zero");
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
        emit HouseCreated(
            msg.sender,
            _name,
            _image,
            _description,
            _location,
            _price,
            _supply
        );
    }

    /**
 `  * @dev Retrieves information about a specific house from the marketplace.
 `  * @param _index The index of the house to read.
 `  * @return owner The address of the house owner.
 `  * @return name The name of the house.
 `  * @return image The image URL of the house.
 `  * @return description The description of the house.
 `  * @return location The location of the house.
 `  * @return price The price of the house in cUSD.
 `  * @return sold The number of units of the house already sold.
 `  * Requirements:
 `  * - `_index` must be within the valid range of houses.
 `  */
    function readHouse(uint _index) public view returns (
        address payable,
        string memory, 
        string memory, 
        string memory, 
        string memory, 
        uint, 
        uint
          ) {
              require(_index < housesLength, "Invalid house index");  
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
     * @dev Buys a house from the marketplace using cUSD token.
     * @param _index The index of the house to be purchased.
     * Requirements:
     * - The `_index` must be within the valid range of houses.
     * - The house must not be sold out.
     * - The buyer must have sufficient cUSD tokens to purchase the house.
     * Emits a {HousePurchased} event if the purchase is successful and a {HouseSoldOut} event
     * if the house becomes sold out after the purchase.
     */
    function buyHouse(uint _index) public payable  {
        require(_index < housesLength, "Invalid house index");
        bool isSoldOut = isHouseSoldOut(_index);
        require(!isSoldOut, "House is sold out");
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
            msg.sender,
            houses[_index].owner,
            _index,
            houses[_index].price
        );
        if (isHouseSoldOut(_index)) {
            emit HouseSoldOut(_index);
        }
    }

    /**
    * @dev Checks if a specific house is sold out.
    * @param _index The index of the house to check.
    * @return true if the house is sold out (all units are purchased), false otherwise.
    * Requirements:
    * - `_index` must be within the valid range of houses.
    */
    function isHouseSoldOut(uint _index) internal view returns (bool) {
        return houses[_index].supply == houses[_index].sold;
    }
    
    /**
    * @dev Retrieves the total number of houses in the marketplace.
    * @return The total number of houses in the marketplace.
    */
    function getHousesLength() public view returns (uint) {
        return (housesLength);
    }

    /**
    * @dev Retrieves the supply (number of available units) of a specific house.
    * @param _index The index of the house to check.
    * @return The supply (number of available units) of the house.
    * Requirements:
    * - `_index` must be within the valid range of houses.
    */
    function readSupply(uint _index) public view returns(uint) {
        return houses[_index].supply;
    }
    
    /**
    * @dev Checks whether it is possible to buy a specific house at a given index.
    * @param _index The index of the house to check.
    * @return true if the house is available for purchase, false if it is sold out.
    * Requirements:
    * - `_index` must be within the valid range of houses.
    */
    function disableBuy(uint _index) public view returns(bool) {
        require(_index < housesLength, "Invalid house index");
        if(houses[_index].supply == houses[_index].sold  ) {
            return false;
            
        } else {
            return true;
        }

    }
}
