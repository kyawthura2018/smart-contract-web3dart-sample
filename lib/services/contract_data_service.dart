import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web3dart/web3dart.dart';

import '../general.dart';
import 'db_connection_service.dart';

final String privateKey =
    "c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3";

class ContractDataService extends DBConnectionService {
  String _scName;
  String _collectionName;
  List<String> scDataList;
  Web3Client client = getWeb3Client();

  ContractDataService(String collectionName, String scName)
      : super(collectionName) {
    this._scName = scName;
    this._collectionName = collectionName;
  }

  Future searchContractData(String scName) async {
    await super.getConnection();
    if (collection != null) {
      print("DB connected to $_collectionName");
      //search smart contract datas
      print(scName);
      try {
        var _scData = await collection.findOne(where.eq('name', scName));

        if (_scData != null) {
          _scData['bytecode'] = "0x" + _scData['bytecode'];
          scDataList = [_scData['bytecode'], _scData['abi']];
          // return bytecode;
        } else {
          print('No Data');
        }
      } catch (err) {
        print(err);
      }
    }
  }

  Future<Credentials> getCredentials() =>
      client.credentialsFromPrivateKey(privateKey);

  Future<List<dynamic>> dataTypeCast(
    List<dynamic> args,
    List<String> typeList,
  ) async {
    // final List<String> typeList = ["bytes","string","string"];
    // final List<dynamic> args = ["0x6e656f", "12345", "hello1"];
    var str = "(";
    for (var i = 0; i < typeList.length; i++) {
      String _typeStr = typeList[i].replaceAll(new RegExp(r"\s+\b|\b\s"), "");
      print(_typeStr);
      if (_typeStr == "bytes") {
        //modify args
        args[i] = utf8.encode(args[i]);
      } else if (_typeStr == "bytes[]") {
        List temp = [];
        for (var j = 0; j < args[i].length; j++) {
          //["a",["ox","ox1"],123]
          temp.add(utf8.encode(args[i][j]));
        }
        args[i] = temp;
      } else if (_typeStr == "address") {
        args[i] = EthereumAddress.fromHex(args[i]);
      } else if (_typeStr.contains("address[")) {
        List temp = [];
        for (var j = 0; j < args[i].length; j++) {
          //["a",["ox","ox1"],123]
          temp.add(EthereumAddress.fromHex(args[i][j]));
        }
        args[i] = temp;
      } else if (_typeStr.length >= 3 && _typeStr.substring(0, 3) == "int") {
        // args[i] = BigInt.from(args[i]);
        args[i] = BigInt.from(args[i]);
      } else if (_typeStr.length >= 3 &&
          _typeStr.substring(0, 3) == "int" &&
          _typeStr.contains("[")) {
        List temp = [];
        for (var j = 0; j < args[i].length; j++) {
          //["a",["ox","ox1"],123]
          temp.add(BigInt.from(args[i][j]));
        }
        args[i] = temp;
      } else if (_typeStr.length >= 4 &&
          _typeStr.substring(0, 4) == "uint" &&
          _typeStr.contains("[")) {
        List temp = [];
        for (var j = 0; j < args[i].length; j++) {
          //["a",["ox","ox1"],123]
          temp.add(BigInt.from(args[i][j]));
        }
        args[i] = temp;
      } else if (_typeStr.length >= 4 && _typeStr.substring(0, 4) == "uint") {
        args[i] = BigInt.from(args[i]);
      }
      i == typeList.length - 1 ? str += _typeStr : str += _typeStr + ',';
    }
    str = str + ")"; // '(string,uint256,address [])'
    //print(args);
    //print(str);
    return [args, str];
  }
}
