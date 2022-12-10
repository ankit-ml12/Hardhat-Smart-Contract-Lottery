// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

error Lottery_NotEnoughETHEntered();
error  Lotter_TransferFailed();
contract Lotter is VRFConsumerBaseV2{
    uint immutable i_entranceFee;
    address payable[] private s_players;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS=3;
    uint32 private constant NUM_WORDS= 1;

   //Lottery Variables
   address private s_recentWinner;
    
    //events
    event  LotteryEnter(address indexed player);
    event  RequestedLotteryWinner(uint256 indexed requestId); 
   event   WinnerPicked(address indexed Winner);
    constructor(
    address vrfCoordinatorV2, 
    uint entranceFee, 
    bytes32 gasLane, 
    uint64 subscriptionId,
    uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2){
        i_entranceFee = entranceFee;
        i_vrfCoordinator=VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId; 
        i_callbackGasLimit= callbackGasLimit; 
    }

    function  enterLotter()public payable {
        if(msg.value<i_entranceFee){
            revert Lottery_NotEnoughETHEntered();
        }
        s_players.push(payable(msg.sender));
        emit LotteryEnter(msg.sender);
    }

    function requestRandomWinner() external {
     uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        emit RequestedLotteryWinner(requestId);
    }
    function fulfillRandomWords(uint, uint [] memory randomWords) internal override{
        uint indexOfWinner = randomWords[0]%s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        (bool success, )= recentWinner.call{value: address(this).balance}("");
        if(!success){
            revert Lotter_TransferFailed();
        }
        emit WinnerPicked(recentWinner);

    }

    function getEntranceFee()public view returns (uint){
        return i_entranceFee;
    }
    function getPlayer(uint index)public view returns (address){
        return s_players[index];
    }

    function getRecentWinner() public view returns(address){
        return s_recentWinner;
    }

}