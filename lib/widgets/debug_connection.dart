import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class DebugConnection extends StatefulWidget {
  const DebugConnection({super.key});

  @override
  State<DebugConnection> createState() => _DebugConnectionState();
}

class _DebugConnectionState extends State<DebugConnection> {
  String _connectionStatus = 'Belum ditest';
  bool _isTesting = false;

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
    });

    final isConnected = await ApiService.instance.testConnection();
    
    setState(() {
      _connectionStatus = isConnected 
          ? '✅ Connected to server' 
          : '❌ Cannot connect to server';
      _isTesting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Text('Debug Connection'),
          Text('URL: ${ApiConstants.baseUrl}'),
          const SizedBox(height: 8),
          Text(_connectionStatus),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _isTesting ? null : _testConnection,
            child: _isTesting 
                ? const CircularProgressIndicator()
                : const Text('Test Connection'),
          ),
        ],
      ),
    );
  }
}