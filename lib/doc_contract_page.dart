import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart_example/general.dart';
import 'package:web3dart_example/services/contract_deploy_service.dart';

import 'app_config.dart';
import 'services/contract_instance_service.dart';

class DocumentApp extends StatefulWidget {
  DocumentApp({Key key}) : super(key: key);

  @override
  _DocumentAppState createState() => _DocumentAppState();
}

class _DocumentAppState extends State<DocumentApp> {
  final _formKey = GlobalKey<FormState>();
  final _documentController = TextEditingController();
  var documentAddress = "0xaf781c53c6a09fa81f89a286c9f1297352c89404";
  var individualAddress = "0x2d63bdb2effc4c8f5baec9b4fe87e18e9818d384";

  var transId;
  var authContract;

  AppConfigParams params = AppConfig().params["dev"];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _documentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Web3 Dart Sample"),
      ),
      body: Builder(
        builder: (context) => Form(
          key: _formKey,
          child: Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                        hintText: 'Say Hello........',
                        icon: Icon(Icons.text_fields)),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text!!';
                      }
                      return null;
                    },
                    controller: _documentController,
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: RaisedButton(
                        onPressed: _deployContract,
                        child: Text('Deploy Contract'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: RaisedButton(
                        onPressed: _voteDocument,
                        child: Text('Vote Document'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: RaisedButton(
                        onPressed: _signDocContract,
                        child: Text('Sign Document'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: RaisedButton(
                        onPressed: _getDocContractStatus,
                        child: Text('Get Stats'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deployContract() async {
    List<dynamic> authorityArgs = [
      "0x0000000000000000000000000000000000000000",
      [
        "0x2a1a9769a9557e234b7dE55FB2e93d5E23bd45A4",
        "0x1b3f8784262aD1C67De994c892FED3f695c35814",
        "0xc1A7cd8d1b4B4e335ca85D122C4f6b14480EB7aF",
        "0x06f96651e9e26c1832fc1b27e43c957ab3d2fee6",
        "0x11A807c597FaFF6cd8D1bD54f829a612d5c9f18E",
        "0x2502a6c30A90735524dba2eF117e05119487fe64"
      ]
    ];
    Web3Client client = getWeb3Client();
    ContractDeployService authContractDeployService = new ContractDeployService(
        "smartcontract_sources",
        "Authority.sol",
        authorityArgs,
        ["bytes", "address[]"]);
    print('Calling deploy new contract');
    final transactionHash = await authContractDeployService.deployNewContract();
    print("Authority Txn Hash: " + transactionHash);
    String authContractAddress = "";
    TransactionReceipt receipt;
    TransactionReceipt individualReceipt;
    TransactionReceipt documentReceipt;
    try {
      while (receipt == null) {
        receipt = await client.getTransactionReceipt(transactionHash);
      }
      authContractAddress = receipt.contractAddress.toString();
      print("Authorith Contract Address: $authContractAddress");
      List<dynamic> individualArgs = [
        "0x2a1a9769a9557e234b7dE55FB2e93d5E23bd45A4",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        authContractAddress,
      ];
      ContractDeployService individualContractDeployService =
          new ContractDeployService("smartcontract_sources", "Individual.sol",
              individualArgs, ["address", "bytes", "address", "address"]);
      final individualTransactionHash =
          await individualContractDeployService.deployNewContract();
      setState(() {
        transId = individualTransactionHash;
        authContract = authContractAddress;
      });
      print("Individual Txn Hash: " + individualTransactionHash);

      while (individualReceipt == null) {
        individualReceipt =
            await client.getTransactionReceipt(individualTransactionHash);
      }

      final individualContractAddress =
          individualReceipt.contractAddress.toString();
      print("Individual contract addr: " + individualContractAddress);

      List<dynamic> docArgs = [
        "6A833EBEE0A9530AA179102B3900CF71B1EDD1FE",
        "6A833EBEE0A9530AA179102B3900CF71B1EDD1FE",
        [],
        1,
        1,
        0
      ];

      List<String> addressArray = [];

      for (int i = 0; i < 50; i++) {
        addressArray.add(individualContractAddress);
      }

      docArgs[2] = addressArray;

      ContractDeployService documentContractDeployService =
          new ContractDeployService("smartcontract_sources", "Doc.sol", docArgs,
              ["bytes", "bytes", "address[50]", "uint", "uint", "uint"]);
      final documentTransactionHash =
          await documentContractDeployService.deployNewContract();

      while (documentReceipt == null) {
        documentReceipt =
            await client.getTransactionReceipt(documentTransactionHash);
      }

      setState(() {
        individualAddress = individualContractAddress;
        documentAddress = documentReceipt.contractAddress.toString();
      });

      print("Document Address : $documentAddress");

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                  "Individual Address: $individualContractAddress, Document Address: $documentAddress"),
              actions: <Widget>[
                RaisedButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _voteDocument() async {
    List<dynamic> args = [documentAddress, 1, authContract];
    List<String> argsTypeList = ["address", "int", "address"];
    var contractDeploy = new ContractInstanceService(
        "smartcontract_sources", "Individual.sol", transId);
    var contract = await contractDeploy.getDeployedContract(individualAddress);
    await contractDeploy
        .sendTxns(contract, "vote", args, argsTypeList)
        .then((value) => showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text("Txn Hash: $value"),
                actions: <Widget>[
                  RaisedButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            }));
  }

  Future<void> _signDocContract() async {
    List<dynamic> args = [1];
    List<String> argsTypeList = ["int"];
    var contractDeploy = new ContractInstanceService(
        "smartcontract_sources",
        "Doc.sol",
        "0xd629c652d2a719ef199574f924802e639ed29781657144f1b6774edc1424d7d4");
    var contract = await contractDeploy.getDeployedContract(documentAddress);
    await contractDeploy
        .sendTxns(contract, "sign", args, argsTypeList)
        .then((value) => showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text("Txn Hash: $value"),
                actions: <Widget>[
                  RaisedButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            }));
  }

  Future<void> _getDocContractStatus() async {
    var contractDeploy = new ContractInstanceService(
        "smartcontract_sources",
        "Doc.sol",
        "0xd629c652d2a719ef199574f924802e639ed29781657144f1b6774edc1424d7d4");
    var contract = await contractDeploy.getDeployedContract(documentAddress);
    await contractDeploy
        .callFun(contract, "getSignatureStats")
        .then((value) => showDialog(
            context: context,
            builder: (context) {
              var data = value;
              return AlertDialog(
                content: Column(
                  children: [
                    Text("Signer address : ${data[0][1]}"),
                    Text("Signer vote : ${data[1][1]}"),
                    Text("Total voted : ${data[2]}"),
                    Text("Total votes : ${data[4]}"),
                    Text("Signer state : ${data[6]}"),
                  ],
                ),
                actions: <Widget>[
                  RaisedButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            }));
  }
}
