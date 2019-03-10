pragma solidity >=0.4.22 <0.6.0;

//  This contract acts as an intermediary between the sender of fund(with TRX) and the receiver of fund(with only phone number)
//This is a remittance smart contract for Nigerians diaspora to send fund to their friends and family using TRX;
//The beneficiary of the fund can either claim his fund in Naira(Local currency) or TRX.
//   Claiming the fund in Naira requires Instancheque to get the transfer TRX and then convert it to Niara, then send it to the bank account of the
//beneficiary.
//   Claiming the fund in TRX requires the beneficiary to submit his TRON wallet address and the fund to be transfered
//to the wallet from the smartcontract
contract instanTransfer {
  

    //This stores informaion about a successful transaction to the blockchain
    struct Transaction{
        uint256 time;
        uint amount;
        address sender;
        bool status;
    }

   //This is used for authentication before fund can be claimed by the receiver
    struct Valcode{
      string transactionid;
      uint code;
    }
    
    //used to store details of fund transfer to the smartcontract
    struct UserTransfer{
    address sender;
    uint256 time;
    uint256 amount;
    }

    address contractowner;//address of the contract owner
    Valcode [] instantcodes;//this array stores intant code for verification
    Transaction[] unclaimtransactions;//used to store unclaimed transaction
    mapping(uint256=>Transaction) public transactions;//this map stores complete transactions base on time=>transaction
    UserTransfer [] transferlist;//list of amount transfered

    constructor() public {
        contractowner=msg.sender;
    }

    //Thsi function gets the balance of the sender of fund
   function getBalance() public view returns (uint balance){
      return msg.sender.balance;
   }
 
    //This is used by the reciever of the fund to claim his/her fund, This function allows user to claimed fund once
    //also it does authentication and authorization before fund can be claimed
     function claimFund(address sender,uint256 amount,address payable receiver, uint instantcode,uint256 time) public{
         require(contractowner==msg.sender);//this authorize user before fund can be claimed
         require(verifyInstantCode(instantcode));//verify if user submit the code
         require(confirmUnclaimedTransaction(time,amount));//verify if user has already reclaim fund
         receiver.balance;
         receiver.transfer(amount);//send reclaimed fund to teh provided address
         transactions[time]=Transaction({
        time:time,
        amount:amount,
        sender:sender,
        status:true
    });

     }

     //this is used by the contract to received fund(Where the sender call to send fund)
     function transferfund(uint256 time) public payable{
      transferlist.push(UserTransfer({
          sender:msg.sender,
          time:time,
          amount:msg.value
       }));
     }

    //store unclaimed fund and also at as part of verification
     function storeUnclaimedTransaction(address sender,uint amount,uint256 time) public{
        unclaimtransactions.push(Transaction({
        time:time,
        amount:amount,
        sender:sender,
        status:false
    }));
     }

//this is used to store already process transaction using trx to trx: note (infomation like phoneumber, is mask)
     function storeTransaction(address sender,uint amount,uint256 time) public{
         transactions[time]=Transaction({
        time:time,
        amount:amount,
        sender:sender,
        status:true
    });
     }
   
   //this is used to comfirm unprocess transaction
     function confirmUnclaimedTransaction(uint256 time,uint amount)internal returns (bool allow){
         uint pos=0;
         for(uint i=0;i<unclaimtransactions.length;i++){
             if(unclaimtransactions[i].time==time&&unclaimtransactions[i].amount==amount){
                 allow= true;
                 pos=i;
             }
         }
         delete unclaimtransactions[pos];
         return allow;
     }

     //This is used to store instant code that expires 5mins after user authentication
     function storeInstantCode(uint code,string  memory transactionid) public {
         instantcodes.push(Valcode({transactionid:transactionid,code:code}));
     }

     //this is used to verify valcode in other to caim fund and delete code after verification
     function verifyInstantCode(uint code)private returns (bool){
         bool allow=false;
         uint pos=0;
         for(uint i=0;i<instantcodes.length;i++){
             if(instantcodes[i].code==code){
                 allow=true;
                 pos=i;
             }
         }
         delete instantcodes[pos];
         return allow;
     }

  
     //this is use by the onwer to transfer right of ownership to another address
     function changeOwner(address owner) public {
       require(contractowner==msg.sender);
       contractowner=owner;
     }
  //Thsi function gets the balance in the smart contract
   function getContractBalance() public view returns (uint balance){
      return address(this).balance;
   }
}