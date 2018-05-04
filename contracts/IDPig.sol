pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract IDPig is Ownable {
    mapping(string=>mapping(bytes32=>string))  idkv;
    mapping(string=>bytes32[])  idlist;
    
    event mylog(string,string,string);
    
    function IDPig() public {
        
    }
    function set(string _id,bytes32 _k,string _v ) onlyOwner public {
        require(bytes(idkv[_id][_k]).length<=0);
        idkv[_id][_k] = _v;
        idlist[_id].push(_k);
    }
    function get(string _id,bytes32 _k)   public view returns(string){
        return idkv[_id][_k];
    }
    function getListKey(string _id) public view returns(bytes32[]){
        return idlist[_id];
    }
}