import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';


class NetworkInfo {
  final Connectivity connectivity;
  
  NetworkInfo(this.connectivity);
  
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
  
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      connectivity.onConnectivityChanged;
}