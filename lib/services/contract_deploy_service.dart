//TODO
//1 get bytecode, abi and address from db
//2 redeploy contract
import 'dart:async';

import 'package:web3dart/crypto.dart';
import 'package:web3dart/src/utils/length_tracking_byte_sink.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/web3dart.dart';

import 'contract_data_service.dart';


  const COLLECTION_NAME = 'smartcontract_sources';
  
  
class ContractDeployService extends ContractDataService{
  String scName;
   List<dynamic> args;
    List<String> typeList;
  ContractDeployService( String collectionName, String scName, List<dynamic> args, List<String> typeList): super(collectionName,scName){
    this.scName = scName;
    this.args = args;
    this.typeList = typeList;
  }

  
  Future<String> deployNewContract() async {
    //connection to db
   
      await super.searchContractData(this.scName);
      //print(scDataList);
      if (scDataList.length > 0) {
        return this._deployNewContractToNetwork();
        
      }
    
    return null;
  }

  

  Future<String> _deployNewContractToNetwork() async {
    final credentials = await getCredentials();
    final networkId = await client.getNetworkId();

    try {
      //print(bcode);
      final data = await this._getEncodedData(scDataList[0]);
      final transactionhash = await client.sendTransaction(
        credentials,
        Transaction(
          data: hexToBytes(data),
          to: null,
          value: null,
          gasPrice: EtherAmount.inWei(BigInt.one),
          maxGas: 8000000,
        ),
        chainId: networkId,
      );
      print('Contract deployed at $transactionhash');
      return transactionhash;
    } catch (er) {
      print("Errr "+ er.toString());
      return er.toString();
    }
  }

  

  Future<dynamic> _getEncodedData(String bytecode) async {
    //print(args);
    //print(typeList);
    List<dynamic> data = await dataTypeCast(args,typeList); // '(bytes,string,uint,address)'
    final type = parseAbiType(data[1]);
    final sink = LengthTrackingByteSink();
    type.encode(data[0], sink);
    return bytecode + bytesToHex(sink.asBytes());
  }
}
