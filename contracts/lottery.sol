// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

Lottery_NotEnoughETHEntered();
contract Lotter{
    uint immutable i_entranceFee;
    address payable[] private s_players;

    event  LotteryEnter(address indexed player);

    constructor (uint entranceFee){
        i_entranceFee = entranceFee;
    }

    function  enterLotter()public payable {
        if(msg.value<i_entranceFee){
            revert Lottery_NotEnoughETHEntered()
        }
        s_players.push(payable(msg.sender));
        emit LotteryEnter(msg.sender);
    }

    function getEntranceFee()public view returns (uint){
        return i_entranceFee;
    }
    function getPlayer(uint index)public view returns (uint){
        return s_players[index];
    }

}