// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {

  address public owner;
  uint256 public skuCount;
  enum State{ForSale, Sold, Shipped, Received}
  struct Item {
    string name;
    uint sku;
    uint price;
    State state;
    address payable seller;
    address payable buyer;
  }

  mapping (uint => Item) public items;
  
  /* 
   * Events
   */

  event LogForSale(uint sku);
  
  event LogSold(uint sku);

  event LogShipped(uint sku);

  event LogReceived(uint sku);


  /* 
   * Modifiers
   */

   modifier isOwner() {
    require (msg.sender ==owner);
    _;
   }

  modifier verifyCaller (address _address) { 
     require (msg.sender == _address); 
    _;
  }

  modifier paidEnough(uint _price) { 
     require(msg.value >= _price); 
    _;
  }

  modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
     uint _price = items[_sku].price;
     uint amountToRefund = msg.value - _price;
     items[_sku].buyer.transfer(amountToRefund);
  }

  // For each of the following modifiers, use what you learned about modifiers
  // to give them functionality. For example, the forSale modifier should
  // require that the item with the given sku has the state ForSale. Note that
  // the uninitialized Item.State is 0, which is also the index of the ForSale
  // value, so checking that Item.State == ForSale is not sufficient to check
  // that an Item is for sale. Hint: What item properties will be non-zero when
  // an Item has been added?

  modifier forSale(uint _sku)  {
    if (items[_sku].state == State.ForSale ){
      _;
    }
  }
  
 
  modifier shipped(uint _sku) {
    if (items[_sku].state == State.Shipped ){
      _;
    }
  }

  modifier received(uint _sku) {
    if (items[_sku].state == State.Received ){
      _;
    }
  }

  constructor() public {
    owner = msg.sender;
    skuCount= 0;
    }

  function addItem(string memory _name, uint _price) public returns (bool) {

     items[skuCount] = Item({
       name: _name, 
       sku: skuCount, 
       price: _price, 
       state: State.ForSale, 
       seller: msg.sender, 
       buyer: address(0)
    });
    
    skuCount = skuCount + 1;
    emit LogForSale(skuCount);
    return true;
  }

  // Implement this buyItem function. 
  // 1. it should be payable in order to receive refunds
  // 2. this should transfer money to the seller, 
  // 3. set the buyer as the person who called this transaction, 
  // 4. set the state to Sold. 
  // 5. this function should use 3 modifiers to check 
  //    - if the item is for sale, 
  //    - if the buyer paid enough, 
  //    - check the value after the function is called to make 
  //      sure the buyer is refunded any excess ether sent. 
  // 6. call the event associated with this function!
  function buyItem(uint _sku) payable public  {
    
    items[_sku].state = State.Sold;
    items[_sku].buyer = msg.sender;
    items[_sku].seller.transfer(items[_sku].price);
    emit LogSold(_sku);
  }

  // 1. Add modifiers to check:
  //    - the item is sold already 
  //    - the person calling this function is the seller. 
  // 2. Change the state of the item to shipped. 
  // 3. call the event associated with this function!
  function shipItem(uint _sku) public {
    if( items[_sku].seller!= msg.sender){
      revert("someone that is not the seller tries to call shipItem()");
    }
   items[_sku].state = State.Shipped;
    emit LogShipped(_sku);
    
  }

  // 1. Add modifiers to check 
  //    - the item is shipped already 
  //    - the person calling this function is the buyer. 
  // 2. Change the state of the item to received. 
  // 3. Call the event associated with this function!
  function receiveItem(uint _sku) public shipped(_sku) verifyCaller( items[_sku].buyer) {
     items[_sku].state = State.Received;
    emit LogReceived(skuCount);

  }

  // Uncomment the following code block. it is needed to run tests
  function fetchItem(uint _sku) public view 
     returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) 
  { 
    name = items[_sku].name; 
    sku = items[_sku].sku; 
    price = items[_sku].price; 
    state = uint(items[_sku].state); 
    seller = items[_sku].seller; 
    buyer = items[_sku].buyer; 
    return (name, sku, price, state, seller, buyer); 
   } 
}
