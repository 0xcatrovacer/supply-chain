//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract ItemManager is Ownable {

    enum SupplyChainState{Created, Paid, Delivered}

    struct S_Item {
        Item _item;
        string _identifier;
        uint _itemPrice;
        ItemManager.SupplyChainState _state;
    }

    mapping (uint => S_Item) public items;
    uint ItemIndex;

    event SupplyChainStep(uint _itemIndex, uint _step, address _itemAddress);

    function createItem(string memory _identifier, uint _itemPrice) public onlyOwner {
        Item item = new Item(this, _itemPrice, ItemIndex);
        items[ItemIndex]._item = item;
        items[ItemIndex]._identifier = _identifier;
        items[ItemIndex]._itemPrice = _itemPrice;
        items[ItemIndex]._state = SupplyChainState.Created;
        emit SupplyChainStep(ItemIndex, uint(items[ItemIndex]._state), address(items[ItemIndex]._item));
        ItemIndex++;
    }

    function triggerPayment(uint _itemIndex) public payable {

        require(items[_itemIndex]._itemPrice == msg.value, "Only full payments accepted" );
        require(items[ItemIndex]._state == SupplyChainState.Created, "Item is further in the chain");
        items[_itemIndex]._state = SupplyChainState.Paid;
        
        emit SupplyChainStep(ItemIndex, uint(items[ItemIndex]._state), address(items[_itemIndex]._item));

    }

    function triggerDelivery(uint _itemIndex) public {
        require(items[_itemIndex]._state == SupplyChainState.Paid, "Item is further in the chain");
        items[_itemIndex]._state = SupplyChainState.Delivered;

        emit SupplyChainStep(ItemIndex, uint(items[ItemIndex]._state), address(items[_itemIndex]._item));
    }

}