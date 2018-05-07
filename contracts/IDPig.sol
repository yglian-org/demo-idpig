pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/ownership/Whitelist.sol";

contract IDPig is Whitelist {
    mapping(string=>mapping(bytes32=>string))  idkv;
    mapping(string=>bytes32[])  idlist;
    
    event SetLog(string indexed,bytes32 indexed,string);
    
    function IDPig() public {
        
    }
    function set(string _id,bytes32 _k,string _v ) onlyWhitelisted public {
        require(bytes(idkv[_id][_k]).length<=0);
        idkv[_id][_k] = _v;
        idlist[_id].push(_k);
        emit SetLog(_id,_k,_v);
    }
    function get(string _id,bytes32 _k)   public view returns(string){
        return idkv[_id][_k];
    }
    function getListKey(string _id) public view returns(bytes32[]){
        return idlist[_id];
    }
    
}