// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract RealEstate {
  address public owner = msg.sender;

  struct Property {
    uint128 price;
    bool forSale;

    uint128 rentPayment;
    bool forRent;
    bool rented;
    address renter;
    uint rentDueDate;

    address payable owner;
    string propertyAddress;
    
    string propertyType;
    string imageURL;
  }

  uint[] public propertyIds;
  uint public nextPropertyId = 0;

  mapping(uint => Property) public properties;
  
  //function to add a property
  function addProperty(string memory _propertyAddress, string memory _propertyType, string memory _imageURL, uint128 _price, uint128 _rentPayment) public onlyOwner {
    Property memory newProperty = Property({
      price: _price,
      forSale: true,
      rentPayment: _rentPayment,
      forRent: true,
      rented: false,
      renter: address(0x0),
      rentDueDate: 0,
      owner: payable(msg.sender),
      propertyAddress: _propertyAddress,
      propertyType: _propertyType,
      imageURL: _imageURL
    });
    
    properties[nextPropertyId] = newProperty;

    propertyIds.push(nextPropertyId);

    emit PropertyAdded(nextPropertyId, msg.sender, _propertyType, _imageURL);

    nextPropertyId++;
  }

  //function to add a property 
  function addPropertyMore(string memory _propertyAddress, string memory _propertyType, string memory _imageURL, uint128 _price, uint128 rentPayment, bool forSale, bool forRent) public onlyOwner {
    Property memory newProperty = Property({
      price: _price,
      forSale: forSale,
      rentPayment: rentPayment,
      forRent: forRent,
      rented: false,
      renter: address(0x0),
      rentDueDate: 0,
      owner: payable(msg.sender),
      propertyAddress: _propertyAddress,
      propertyType: _propertyType,
      imageURL: _imageURL
    });
    
    properties[nextPropertyId] = newProperty;

    propertyIds.push(nextPropertyId);

    emit PropertyAdded(nextPropertyId, msg.sender, _propertyType, _imageURL);

    nextPropertyId++;
  }

  //funtion to buy a property
  function buyProperty(uint _propertyId) external payable {
    Property storage property = properties[_propertyId];

    require(property.forSale, "Property is not for sale");
    require(msg.value >= property.price, "Not enough funds sent");

    property.owner.transfer(msg.value);
    property.owner = payable(msg.sender);
    property.forSale = false;
  }

  //function to update price, forSale, rentPayment, forRent
  function updateProperty(uint _propertyId, uint128 _price, uint128 _rentPayment, bool _forSale, bool _forRent) external {
    Property storage property = properties[_propertyId];

    require(msg.sender == property.owner, "Only the owner can update this property");

    property.price = _price;
    property.rentPayment = _rentPayment;
    property.forSale = _forSale;
    property.forRent = _forRent;
  }



  //constructor to initialize the contract
  constructor() {
    addProperty("123 Main St", "House", "https://thumbor.forbes.com/thumbor/fit-in/900x510/https://www.forbes.com/home-improvement/wp-content/uploads/2022/07/download-23.jpg", 23e18, 2e18);
    addProperty("456 Main St", "Apartment", "https://galio.lt/wp-content/uploads/2021/04/Ctz_005.jpg", 16e18, 1e18);
    addProperty("789 Main St", "House", "https://media.carusohomes.com/46/2022/9/30/Davidson_-_CH2_002_-_Cropped_LLoE8Tt.1920x1440.png", 27e18, 3e18);
    addProperty("101 Main St", "Apartment", "https://thumbs.cityrealty.com/assets/smart/400x/webp/9/97/977e95b5d60a85c89cc1b5de9af0834f5dde8543/chelsea-stratus-101-west-24th-street.jpg", 18e18, 2e18);
    addProperty("112 Main St", "House", "https://waynehomes.com/wp-content/uploads/2015/06/Cedar-Hill-Homestead-1.jpg", 29e18, 3e18);
  }






//modifiers
  modifier onlyOwner() {
    require(msg.sender == owner, "Only the owner can call this function");
    _;
  }


//events
  event PropertyAdded(uint propertyId, address owner, string propertyType, string imageURL);

  
}
