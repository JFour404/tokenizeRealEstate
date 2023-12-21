import Web3 from 'web3';
import configuration from '../build/contracts/RealEstate.json';
import 'bootstrap/dist/css/bootstrap.css';

const createElementFromString = (string) => {
  const el = document.createElement('div');
  el.innerHTML = string;
  return el.firstChild;
};

const CONTRACT_ADDRESS =
  configuration.networks['5777'].address;
const CONTRACT_ABI = configuration.abi;

const web3 = new Web3(
  Web3.givenProvider || 'http://127.0.0.1:7545'
);

const contract = new web3.eth.Contract(
  CONTRACT_ABI,
  CONTRACT_ADDRESS
);

let nextPropertyId = 0;

async function fetchNextPropertyId() {
  nextPropertyId = await contract.methods.nextPropertyId().call();
}
const EMPTY_ADDRESS = '0x0000000000000000000000000000000000000000';

let account;

const accountEl = document.getElementById('account');
const propertiesEl = document.getElementById('propertyList');
const ownershipEl = document.getElementById('ownershipList');

const buyProperty = async (property) => {
  await contract.methods.buyProperty(property.id).send({
    from: account,
    value: property.price,
  });
  await refreshProperty();
};

const refreshProperty = async () => {
  propertiesEl.innerHTML = '';
  ownershipEl.innerHTML = '';
  for (let i = 0; i < nextPropertyId; i++) {
    const property = await contract.methods
      .properties(i)
      .call();
    console.log(property);
    property.id = i;
    
    if (property.owner !== account) {
      const propertyEl = createElementFromString(
        `<div class="property-card" style="width: 18rem;">` +
          '<img src="' + property.imageURL + '" class="card-img-top" alt="...">' +
          '<div class="card-body">' +
            '<h5 class="card-title">' + property.propertyType + '</h5>' +
            '<p class="card-text">' + property.propertyAddress + '</p>' +
            (property.forSale ? '<div style="display: flex; justify-content: space-between; align-items: center;"><p class="card-text">' + (property.price / 1e18) + ' Eth</p>' + 
            '<button class="btn btn-primary">Buy</button></div>' : '') +
            (property.forRent ? '<div style="display: flex; justify-content: space-between; align-items: center;"><p class="card-text">' + (property.rentPayment / 1e18) + ' Eth</p>' + 
            '<button class="btn btn-primary">Rent</button></div>' : '') +
            '<p class="owner-text">' + property.owner + '</p>' +
          '</div>' +
        '</div>'
      );

      const buttonEl = propertyEl.querySelector('button');
      buttonEl.onclick = buyProperty.bind(null, property);
      propertiesEl.appendChild(propertyEl);
    } else {
      const propertyEl = createElementFromString(
        `<div class="property-card-owner" style="width: 18rem;">` +
          '<img src="' + property.imageURL + '" class="card-img-top" alt="...">' +
          '<div class="card-body">' +
            '<h5 class="card-title">' + property.propertyType + '</h5>' +
            '<p class="card-text">' + property.propertyAddress + '</p>' +
            '<form id=propertyForm>' +
              '<label for="price">Price:</label>' +
              '<input type="text" id="p-price" name="price" value="' + (property.price / 1e18) + '"><br>' +
              '<label for="forSale">For Sale:</label>' +
              '<input type="checkbox" id="p-forSale" name="forSale" ' + (property.forSale ? 'checked' : '') + '><br>' +
              '<label for="rentPayment">Rent Payment:</label>' +
              '<input type="text" id="p-rentPayment" name="rentPayment" value="' + (property.rentPayment / 1e18) + '"><br>' +
              '<label for="forRent">For Rent:</label>' +
              '<input type="checkbox" id="p-forRent" name="forRent" ' + (property.forRent ? 'checked' : '') + '><br>' +
              '<input type="submit" value="Submit">' +
            '</div>' +
        '</div>'
      );

      ownershipEl.appendChild(propertyEl);
    }
  }
};    

const main = async () => {
  const accounts = await web3.eth.requestAccounts();
  account = accounts[0];
  accountEl.innerText = account;
  await fetchNextPropertyId();
  await refreshProperty();
};

const refreshButton = document.getElementById('refreshButton');

refreshButton.addEventListener('click', async () => {
  await fetchNextPropertyId();
  await refreshProperty();
});

main();




// Get form elements
const form = document.getElementById('propertyForm');
const priceInput = document.getElementById('price');
const forSaleInput = document.getElementById('forSale');
const rentPaymentInput = document.getElementById('rentPayment');
const forRentInput = document.getElementById('forRent');
const propertyAddressInput = document.getElementById('propertyAddress');
const propertyTypeInput = document.getElementById('propertyType');
const imageURLInput = document.getElementById('imageURL');

form.addEventListener('submit', async (event) => {
  event.preventDefault();

  // Get form values
  const f_price = priceInput.value;
  const f_forSale = forSaleInput.checked;
  const f_rentPayment = rentPaymentInput.value;
  const f_forRent = forRentInput.checked;
  const f_propertyAddress = propertyAddressInput.value;
  const f_propertyType = propertyTypeInput.value;
  const f_imageURL = imageURLInput.value;

  // Get accounts
  const accounts = await web3.eth.getAccounts();

  // Send data to the blockchain
  await contract.methods.addPropertyMore(
    f_propertyAddress,
    f_propertyType,
    f_imageURL,
    web3.utils.toWei(f_price, 'ether'), 
    web3.utils.toWei(f_rentPayment, 'ether'), 
    f_forSale,
    f_forRent
  ).send({ from: accounts[0] });
});

