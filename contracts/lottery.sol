// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

error Lottery_NotEnoughETHEntered();
contract Lotter is VRFConsumerBaseV2{
    uint immutable i_entranceFee;
    address payable[] private s_players;

    event  LotteryEnter(address indexed player);

    constructor (address vrfCoordinatorV2, uint entranceFee) VRFConsumerBaseV2(vrfCoordinatorV2){
        i_entranceFee = entranceFee;
    }

    function  enterLotter()public payable {
        if(msg.value<i_entranceFee){
            revert Lottery_NotEnoughETHEntered();
        }
        s_players.push(payable(msg.sender));
        emit LotteryEnter(msg.sender);
    }

    function requestRandomWinner() external {

    }
    function fulfillRandomWords(uint requestId, uint [] memory randomWords) internal override{}

    function getEntranceFee()public view returns (uint){
        return i_entranceFee;
    }
    function getPlayer(uint index)public view returns (address){
        return s_players[index];
    }

}