//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "./Ownable.sol";
import "./Item.sol";

contract ItemManager is Ownable {

    enum SupplyChainSteps{Created, Paid, Delivered}

    struct S_Item {
        Item _item;
        string _identifier;
        uint _itemPrice;
        ItemManager.SupplyChainSteps _step;
    }

    mapping (uint => S_Item) public items;
    uint ItemIndex;

    event SupplyChainStep(uint _itemIndex, uint _step, address _itemAddress);

    function createItem(string memory _identifier, uint _itemPrice) public onlyOwner {
        Item item = new Item(this, _itemPrice, ItemIndex);
        items[ItemIndex]._item = item;
        items[ItemIndex]._identifier = _identifier;
        items[ItemIndex]._itemPrice = _itemPrice;
        items[ItemIndex]._step = SupplyChainSteps.Created;
        emit SupplyChainStep(ItemIndex, uint(items[ItemIndex]._step), address(items[ItemIndex]._item));
        ItemIndex++;
    }

    function triggerPayment(uint _itemIndex) public payable {

        require(items[_itemIndex]._itemPrice == msg.value, "Only full payments accepted" );
        require(items[ItemIndex]._step == SupplyChainSteps.Created, "Item is further in the chain");
        items[_itemIndex]._step = SupplyChainSteps.Paid;
        
        emit SupplyChainStep(_itemIndex, uint(items[ItemIndex]._step), address(items[_itemIndex]._item));

    }

    function triggerDelivery(uint _itemIndex) public {
        require(items[_itemIndex]._step == SupplyChainSteps.Paid, "Item is further in the chain");
        items[_itemIndex]._step = SupplyChainSteps.Delivered;

        emit SupplyChainStep(_itemIndex, uint(items[ItemIndex]._step), address(items[_itemIndex]._item));
    }

}