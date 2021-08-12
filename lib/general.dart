import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart';

import 'app_config.dart';

final AppConfigParams params = AppConfig().params["dev"];

Web3Client getWeb3Client() {
  //web3Client
  return Web3Client(params.web3HttpUrl, Client(), socketConnector: () {
    return IOWebSocketChannel.connect(params.web3WsUrl).cast<String>();
  });
}