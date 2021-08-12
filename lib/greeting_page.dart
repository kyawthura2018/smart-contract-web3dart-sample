import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

import 'app_config.dart';
import 'contract_services.dart';

class GreetingApp extends StatefulWidget {
  GreetingApp({Key key}) : super(key: key);

  @override
  _GreetingAppState createState() => _GreetingAppState();
}

class _GreetingAppState extends State<GreetingApp> {
  final String privateKey =
      "c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3";

  final receiver =
      EthereumAddress.fromHex("0x627306090abab3a6e1400e9345bc60c78a8bef57");

  final _formKey = GlobalKey<FormState>();
  final _greetingController = TextEditingController();

  var transId;

  AppConfigParams params = AppConfig().params["dev"];
  ContractService _contractService;

  @override
  void initState() {
    _contractService = ContractService();
    super.initState();
  }

  @override
  void dispose() {
    _greetingController.dispose();
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
                    controller: _greetingController,
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: RaisedButton(
                        onPressed: _setContract,
                        child: Text('Submit'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: RaisedButton(
                        onPressed: _sayHello,
                        child: Text('Hit it'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: RaisedButton(
                        onPressed: _deployContract,
                        child: Text('Deploy it'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: RaisedButton(
                        onPressed: _getContractAddress,
                        child: Text('Get Address'),
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

  void _setContract() async {
    if (_formKey.currentState.validate()) {
      _contractService
          .send(privateKey, receiver, _greetingController.text)
          .then((id) => {
                (id != null)
                    ? {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text(_greetingController.text),
                                actions: <Widget>[
                                  RaisedButton(
                                    child: Text("OK"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            })
                      }
                    : showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text("Mining Failed"),
                          );
                        })
              });
    }
  }

  void _deployContract() {
    _contractService.deployNewContract(privateKey, receiver).then((value) => {
          value != null
              ? showDialog(
                  context: context,
                  builder: (context) {
                    transId = value;
                    return AlertDialog(
                      content: Text(value),
                    );
                  })
              : showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(value),
                    );
                  })
        });
  }

  void _getContractAddress() {
    _contractService
        .getTransactionReceipt(transId)
        .then((value) => value != null
            ? showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text(
                        "Status : ${value.status.toString()}, Address : ${value.contractAddress.toString()}"),
                  );
                })
            : showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text(value.contractAddress.toString()),
                  );
                }));
  }

  void _sayHello() {
    _contractService.getGreeting().then((value) => {
          value != null
              ? showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(value.toString()),
                    );
                  })
              : showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(value),
                    );
                  })
        });
  }
}
