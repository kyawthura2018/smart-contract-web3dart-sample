class AppConfig {
  AppConfig() {
    params['dev'] = AppConfigParams(
        "http://127.0.0.1:8545",
        "ws://127.0.0.1:8546",
        "0x738E007AEBd614b49831B5d8e30c98271e9820Ec");

    params['ropsten'] = AppConfigParams(
        "https://ropsten.infura.io/v3/628074215a2449eb960b4fe9e95feb09",
        "wss://ropsten.infura.io/ws/v3/628074215a2449eb960b4fe9e95feb09",
        "0x5060b60cb8Bd1C94B7ADEF4134555CDa7B45c461");
  }

  Map<String, AppConfigParams> params = Map<String, AppConfigParams>();
}

class AppConfigParams {
  AppConfigParams(this.web3HttpUrl, this.web3WsUrl, this.contractAddress);
  final String web3WsUrl;
  final String web3HttpUrl;
  final String contractAddress;
}
