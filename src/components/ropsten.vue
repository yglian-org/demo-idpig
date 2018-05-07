<template>
  <div class="hello">
  	<h1 style="color: green">IDPig
    <input type=text name="pigid" style="width:40px;" placeholder="请输入Pig ID" v-model="pigid" />
    </h1>
  	<h3>读取数据</h3>
      <div v-for="item in chain_data" :key="item.id">
        <p style="font-size: 12px; color: red;"># {{item.data}}</p>
      </div>
    <h3>上传数据</h3>
    <p v-if="showMnemonic">
      <label for="mnemonic">助记词</label>
      <input type=text name="mnemonic" style="width:400px;" placeholder="请输入助记词" v-model="mnemonic" />
    </p>
    <p>
      <label for="data">数 &nbsp; 据</label>
      <input type=text name="key" style="width:100px;" placeholder="请输入索引key" v-model="key" />
      <input type=text name="data" style="width:400px;" placeholder="请输入key对应的数据" v-model="data" />
    </p>
    <input type=submit @click="send()" value="提交" />
    <h6>{{result}}</h6>
  </div>
</template>

<script>
const Web3 = require('web3');
const IDPig_ABI = require('../utils/idpig_abi.json')
const bip39 = require("bip39");
const hdkey = require("ethereumjs-wallet/hdkey");
const EthereumTx = require('ethereumjs-tx')
const Buffer = require('buffer').Buffer
const node_url = "https://ropsten.infura.io/4evTRHkGM8mbhLg1IisV"

import axios from 'axios'

export default {
  name: 'Index',
  data () {
    return {
      pigid: '1',
      web3: {},
      key: '',
      data: '',
      chain_data: [],
      contract: {},
      result: '',
      showMnemonic: false,
      mnemonic: '',
      nonce: '',
    }
  },
  watch: {
    pigid() {
      var that = this
      that.chain_data = []
      this.contract.methods.getListKey(''+this.pigid).call({from: '0x3a2c14865bf17766f08aa02efcf042ab739bde7e'}, function(error, result){
          // console.log(error, result)
          //that.chain_data = result
          var request_data = []
          var headers = {
            'Content-Type': 'application/json; charset=UTF-8'
          }
          //result = ['0x'+Buffer.from("1").toString('hex'), '0x'+Buffer.from("2").toString('hex')]
          if (result && result.length > 0) {
            for(let i in result) {
              var data = that.contract.methods.get(''+that.pigid, that.web3.eth.abi.encodeParameter('bytes32', result[i])).encodeABI()
              request_data.push({
                "jsonrpc": "2.0",
                "id": Math.floor(Math.random()*10000),
                "method": "eth_call",
                "params":[
                  {
                    "data": data,
                    "to": "0x6e0b4a32d8060e037dcb8dfd9f5a25a72110db8a"
                  },
                  "pending"
                ]
              })
            }
          }

          axios.post(node_url, JSON.stringify(request_data), headers).then(function(data) {
              for(let i in data.data) {
                data.data[i].data = that.web3.eth.abi.decodeParameter('string', data.data[i].result)
                that.chain_data.push(data.data[i])
              }
          });
      });
    }
  },
  created () {
  	// Is there an injected web3 instance?
    if (typeof web3 !== 'undefined') {
     var _web3 = new Web3(web3.currentProvider);
    //  var coinbase = _web3.eth.getCoinbase().then(address => {
    //    _web3.eth.getBalance(address, 'pending').then(balance => {
    //      console.log(balance)
    //    })
    //  })
    } else {
      console.log('No web3? You should consider trying MetaMask!')
      var _web3 = new Web3(new Web3.providers.HttpProvider(node_url));
      // _web3.eth.getBlockNumber((err, result) => {
      //   console.log('区块高度:' + result)
      // })
      this.showMnemonic = true
    }
    this.web3 = _web3

    this.contract = new _web3.eth.Contract(IDPig_ABI, '0x6e0b4a32d8060e037dcb8dfd9f5a25a72110db8a', {
        from: '0x3a2c14865bf17766f08aa02efcf042ab739bde7e', // default from address
        gasPrice: '20000000000', // default gas price in wei, 20 gwei in this case
        gas: 1000000
    });

    var that = this
    this.contract.methods.getListKey(''+this.pigid).call({from: '0x3a2c14865bf17766f08aa02efcf042ab739bde7e'}, function(error, result){
        // console.log(error, result)
        //that.chain_data = result
        var request_data = []
        request_data.push({
          "jsonrpc": "2.0",
          "id": Math.floor(Math.random()*10000),
          "method": "eth_getTransactionCount",
          "params":['0x3a2c14865bf17766f08aa02efcf042ab739bde7e', 'pending']
        })
        var headers = {
          'Content-Type': 'application/json; charset=UTF-8'
        }
        //result = ['0x'+Buffer.from("1").toString('hex'), '0x'+Buffer.from("2").toString('hex')]
        if (result && result.length > 0) {
          for(let i in result) {
            var data = that.contract.methods.get(''+that.pigid, _web3.eth.abi.encodeParameter('bytes32', result[i])).encodeABI()
            request_data.push({
              "jsonrpc": "2.0",
              "id": Math.floor(Math.random()*10000),
              "method": "eth_call",
              "params":[
                {
                  "data": data,
                  "to": "0x6e0b4a32d8060e037dcb8dfd9f5a25a72110db8a"
                },
                "pending"
              ]
            })
          }
        }

        axios.post(node_url, JSON.stringify(request_data), headers).then(function(data) {
            for(let i in data.data) {
              if (i == 0) {
                that.nonce = data.data[0].result
                continue
              }
              data.data[i].data = _web3.eth.abi.decodeParameter('string', data.data[i].result)
              that.chain_data.push(data.data[i])
            }
        });
    });

    // var key = Buffer.from("ssssss").toString('hex')
    // console.log(key, _web3.eth.abi.encodeParameter('bytes32', '0x'+key))
    // console.log(this.contract.methods.set('abc', 'dddddd1111').encodeABI())
  },
  methods: {
  	send: function () {
      var that = this
      if (this.showMnemonic) {
        if (!this.mnemonic) {
          alert("必须填写助记词")
          return;
        }
        if (!this.data) {
          alert("必须填写上链数据")
          return;
        }
        var hdwallet = hdkey.fromMasterSeed(bip39.mnemonicToSeed(this.mnemonic));
        var wallet_hdpath = "m/44'/60'/0'/0/";
        var wallet = hdwallet.derivePath(wallet_hdpath + "0").getWallet();

        var contract_data = this.contract.methods.set(that.pigid, this.web3.eth.abi.encodeParameter('bytes32', '0x'+Buffer.from(that.key).toString('hex')), that.data).encodeABI()
        
        const txParams = {
          nonce: that.nonce,
          gasPrice: '0x4A817C800', 
          gasLimit: '0x493E0',
          to: '0x6e0b4a32d8060e037dcb8dfd9f5a25a72110db8a', 
          value: '0x00', 
          data: contract_data,
          // EIP 155 chainId - mainnet: 1, ropsten: 3
          chainId: 3
        }

        const tx = new EthereumTx(txParams)
        var privateKey = Buffer.from(wallet.getPrivateKey(), 'hex')
        console.log(privateKey, txParams)
        tx.sign(privateKey)
        const serializedTx = tx.serialize()

        that.result = 'loading...'

        that.web3.eth.sendSignedTransaction('0x' + serializedTx.toString('hex')).on('receipt', res => {
          that.result = JSON.stringify(res)
        });
      } else {
        that.result = 'loading...';
        that.contract.methods.set(that.pigid, this.web3.eth.abi.encodeParameter('bytes32', '0x'+Buffer.from(that.key).toString('hex')), that.data).send({from: '0x3a2c14865bf17766f08aa02efcf042ab739bde7e'}, function(error, result){
          console.log(error, result)
          if (!error) {
            that.result = result
          }
        })
      }
      return false;
    }
  }
}
</script>