import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

import 'contract_data_service.dart';

class ContractInstanceService extends ContractDataService {
  String _txhash;
  String _scName;
  ContractInstanceService(
    String collectionName,
    String scName,
    String txhash,
  ) : super(collectionName, scName) {
    this._txhash = txhash;
    this._scName = scName;
  }

  Future<DeployedContract> getSCInstance() async {
    final credentials = await getCredentials();
    print(credentials);
    await super.searchContractData(this._scName);
    print("scDataList");
    //print(scDataList);
    if (scDataList.length > 0) {
      String address = await this._generateContractAddress(_txhash);
      EthereumAddress contractAddr = EthereumAddress.fromHex(address);

      return DeployedContract(
          ContractAbi.fromJson(scDataList[1],
              _scName.substring(0, _scName.length - 4)), //abi , Noti ,
          contractAddr);
    } else {
      return DeployedContract(null, null);
    }
  }

  Future<DeployedContract> getDeployedContract(String address) async {
    final credentials = await getCredentials();
    print(credentials);
    await super.searchContractData(this._scName);
    print("scDataList");
    //print(scDataList);
    if (scDataList.length > 0) {
      EthereumAddress contractAddr = EthereumAddress.fromHex(address);

      return DeployedContract(
          ContractAbi.fromJson(scDataList[1],
              _scName.substring(0, _scName.length - 4)), //abi , contract name ,
          contractAddr);
    } else {
      return DeployedContract(null, null);
    }
  }

  Future<String> _generateContractAddress(String hash) async {
    try {
      final result = await client.getTransactionReceipt(hash);
      print('Contract Address is ${result.contractAddress.toString()}');
      return result.contractAddress.toString();
    } catch (e) {
      print(e.toString());
      return "Contract hasn't been confirmed!!";
    }
  }

  Future<dynamic> callFun(
      DeployedContract contract, String functionName) async {
    return await client.call(
      contract: contract,
      function: contract.function(functionName),
      params: [],
    );
  }

  Future<String> sendTxns(DeployedContract contract, String functionName,
      List<dynamic> args, List<String> typeList) async {
    final credentials = await getCredentials();
    List<dynamic> data =
        await dataTypeCast(args, typeList); // '(bytes,string,uint,address)'
    final networkId = await client.getNetworkId();
    return client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: contract.function(functionName),
        parameters: data[0],
      ),
      chainId: networkId,
    );
  }
}
