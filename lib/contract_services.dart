import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:web3dart/crypto.dart';
import 'app_config.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web3dart/src/utils/length_tracking_byte_sink.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ContractService {
  //ContractService(this.client, this.contract);

  static AppConfigParams params = AppConfig().params["dev"];

  final String privateKey =
      "c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3";

  static final contractAddr =
      EthereumAddress.fromHex("0x692a70d2e424a56d2c6c27aa97d1a86395877b3a");
  final receiver =
      EthereumAddress.fromHex("0x627306090abab3a6e1400e9345bc60c78a8bef57");

  static String abi = """[
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_greeting",
				"type": "string"
			}
		],
		"name": "setGreeting",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_greeting",
				"type": "string"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [],
		"name": "getGreeting",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]
""";

  final bytecode =
      "0x608060405234801561001057600080fd5b5060405161039238038061039283398101604052805101805161003a906000906020840190610041565b50506100dc565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061008257805160ff19168380011785556100af565b828001600101855582156100af579182015b828111156100af578251825591602001919060010190610094565b506100bb9291506100bf565b5090565b6100d991905b808211156100bb57600081556001016100c5565b90565b6102a7806100eb6000396000f30060806040526004361061004b5763ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663a41368628114610050578063fe50cc72146100ab575b600080fd5b34801561005c57600080fd5b506040805160206004803580820135601f81018490048402850184019095528484526100a99436949293602493928401919081908401838280828437509497506101359650505050505050565b005b3480156100b757600080fd5b506100c061014c565b6040805160208082528351818301528351919283929083019185019080838360005b838110156100fa5781810151838201526020016100e2565b50505050905090810190601f1680156101275780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b80516101489060009060208401906101e3565b5050565b60008054604080516020601f60026000196101006001881615020190951694909404938401819004810282018101909252828152606093909290918301828280156101d85780601f106101ad576101008083540402835291602001916101d8565b820191906000526020600020905b8154815290600101906020018083116101bb57829003601f168201915b505050505090505b90565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061022457805160ff1916838001178555610251565b82800160010185558215610251579182015b82811115610251578251825591602001919060010190610236565b5061025d929150610261565b5090565b6101e091905b8082111561025d57600081556001016102675600a165627a7a72305820561e037507f13e5727cee6049bdbc6f022ae0f05784aec2cdc65d9d1cee08b3d0029";

  Web3Client client =
      Web3Client(params.web3HttpUrl, Client(), socketConnector: () {
    return IOWebSocketChannel.connect(params.web3WsUrl).cast<String>();
  });
  DeployedContract contract =
      DeployedContract(ContractAbi.fromJson(abi, "Hello"), contractAddr);

  ContractFunction _getGreetingFunction() => contract.function('getGreeting');
  ContractFunction _setGreetingFunction() => contract.function('setGreeting');

  Future<String> getByteCode() async {
    var servers = ["127.0.0.1:27017", "127.0.0.1:27018", "127.0.0.1:27019"];
    var noError = true;
    var db;
    var i = 0;

    while (noError) {
      try {
        var temp = servers[i];
        print(temp);
        db = Db('mongodb://$temp/im_ems?replicaSet=devrs');
        await db.open();
        var result = await db.isMaster();
        if (result["ismaster"] as bool) noError = false;
      } catch (error) {
        i++;
        // print(error);
      }
    }
    try {
      await db.open();
      print('connected to database');
      var col = db.collection('smartcontract_sources');
      print(col.collectionName);
      var result = await col.find(where.eq('name', 'Doc.sol'));

      if (result != null) {
        var smartcontract = await result.toList();
        //print(smartcontract[0]['bytecode']);
        return "0x" + smartcontract[0]['bytecode'];
      } else {
        print('No abi file');
      }
      return "";
      // await db.close();
    } catch (err) {
      print(err);
    }
  }

  Future<Credentials> getCredentials(String privateKey) =>
      client.credentialsFromPrivateKey(privateKey);

  Future<String> getByteString(String bytecode) async {
//for constructor (uint256, uint256)
    final sink = LengthTrackingByteSink();
    final type1 = parseAbiType('(string)');
    type1.encode(["Hello Byte Code Constructor"], sink);
    return bytecode + bytesToHex(sink.asBytes());
  }

  Future<String> getDocBytesCodeString(String bytecode) async {
    try {
      final list = utf8.encode("0x6A833EBEE0A9530AA179102B3900CF71B1EDD1FE");
      //final fileHash = Uint8List.fromList(list);
      final sink = LengthTrackingByteSink();
      final type1 = parseAbiType("(bytes, bytes, address[], uint, uint, uint)");
      type1.encode([
        list,
        list,
        ['0x627306090abab3a6e1400e9345bc60c78a8bef57'],
        BigInt.one,
        BigInt.one,
        BigInt.zero
      ], sink);
      return bytecode + bytesToHex(sink.asBytes());
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String> getSampleBytesCodeString(String bytecode) async {
    try {
      final list = utf8.encode("akthura");
      final sink = LengthTrackingByteSink();
      final type1 = parseAbiType('(bytes)');
      type1.encode([list], sink);
      return bytecode + bytesToHex(sink.asBytes());
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String> deployNewContract(
      String privateKey, EthereumAddress fromAddress,
      {Function onError}) async {
    final credentials = await this.getCredentials(privateKey);
    final from = await credentials.extractAddress();
    final networkId = await client.getNetworkId();

    try {
      getEthBalance(from);
      final bcode = await getByteCode();
      //print(bcode);
      final data = await getDocBytesCodeString(bcode);
      final transactionId = await client.sendTransaction(
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
      print('Contract deployed at $transactionId');
      return transactionId;
    } catch (ex) {
      if (onError != null) {
        onError(ex);
      }
      print(ex.toString());
      return ex.toString();
    }
  }

  Future<EtherAmount> getEthBalance(EthereumAddress from) async {
    var eth = await client.getBalance(from);
    print("Eth balance is ${eth.getValueInUnit(EtherUnit.ether)}");
    return eth;
  }

  Future<TransactionReceipt> getTransactionReceipt(String hash) async {
    final result = await client.getTransactionReceipt(hash);
    print('Receipt is ${result.contractAddress.toString()}');
    print('Receipt is ${result.cumulativeGasUsed} Gas');
    print('Receipt is ${result.blockNumber.blockNum.toString()}');
    return result;
  }

  Future<String> send(
      String privateKey, EthereumAddress fromAddress, String message,
      {Function onError}) async {
    final credentials = await this.getCredentials(privateKey);
    final from = await credentials.extractAddress();
    final networkId = await client.getNetworkId();

    try {
      final transactionId = await client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: _setGreetingFunction(),
          parameters: [message],
          from: fromAddress,
        ),
        chainId: networkId,
      );
      print('Transaction occur at $transactionId');
      return transactionId;
    } catch (ex) {
      if (onError != null) {
        onError(ex);
      }
      return null;
    }
  }

  Future<dynamic> getGreeting() async {
    var response = await client.call(
      contract: contract,
      function: _getGreetingFunction(),
      params: [],
    );
    print(response.first);
    return response.first;
  }

  Future<void> dispose() async {
    await client.dispose();
  }
}
