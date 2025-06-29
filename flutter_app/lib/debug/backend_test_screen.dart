import 'package:flutter/material.dart';
import '../core/utils/backend_detector.dart';

/// Test screen to detect and validate backend connectivity
class BackendTestScreen extends StatefulWidget {
  const BackendTestScreen({super.key});

  @override
  State<BackendTestScreen> createState() => _BackendTestScreenState();
}

class _BackendTestScreenState extends State<BackendTestScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _detectionResults;
  String? _selectedBaseUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Detection'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Backend Detection Tool',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This tool will scan common backend configurations to find your running server.',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _detectBackend,
                      child:
                          _isLoading
                              ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Detecting...'),
                                ],
                              )
                              : const Text('Detect Backend'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_detectionResults != null) ...[
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detection Results',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(child: _buildResults()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedBaseUrl != null)
                ElevatedButton(
                  onPressed: () => _testChatEndpoints(_selectedBaseUrl!),
                  child: Text('Test Chat Endpoints: $_selectedBaseUrl'),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final results = _detectionResults!;
    final workingUrls = results['workingBaseUrls'] as List<dynamic>;
    final availableEndpoints =
        results['availableEndpoints'] as Map<String, dynamic>;
    final recommendedUrl = results['recommendedBaseUrl'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recommendedUrl != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✅ Recommended Configuration',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendedUrl,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedBaseUrl = recommendedUrl;
                    });
                  },
                  child: const Text('Select This URL'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        const Text(
          'Working Base URLs:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        if (workingUrls.isEmpty)
          const Text(
            '❌ No working backend found!',
            style: TextStyle(color: Colors.red),
          )
        else
          ...workingUrls.map((url) {
            final endpoints = availableEndpoints[url] as List<dynamic>? ?? [];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      url,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${endpoints.length} endpoints available'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final endpoint in endpoints)
                          Chip(
                            label: Text(
                              endpoint,
                              style: const TextStyle(fontSize: 12),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Future<void> _detectBackend() async {
    setState(() {
      _isLoading = true;
      _detectionResults = null;
      _selectedBaseUrl = null;
    });

    try {
      final results = await BackendDetector.detectBackend();
      setState(() {
        _detectionResults = results;
        _selectedBaseUrl = results['recommendedBaseUrl'] as String?;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error detecting backend: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testChatEndpoints(String baseUrl) async {
    await BackendDetector.testChatEndpoints(baseUrl);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat endpoints test completed. Check debug output.'),
        ),
      );
    }
  }
}
