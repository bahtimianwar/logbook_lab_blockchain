import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get rpcUrl => dotenv.env['RPC_URL']!;
  static int get chainId => int.parse(dotenv.env['CHAIN_ID']!);
  static String get contractAddress => dotenv.env['CONTRACT_ADDRESS']!;
  static String get privateKey => dotenv.env['PRIVATE_KEY']!;
  static String get nimSalt => dotenv.env['NIM_SALT']!;
  static const String explorerUrl = 'https://sepolia.etherscan.io';
}
