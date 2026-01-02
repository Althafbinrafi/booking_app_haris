import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/api_client.dart';

class TokenTrackingScreen extends StatefulWidget {
  final String bookingId;

  const TokenTrackingScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<TokenTrackingScreen> createState() => _TokenTrackingScreenState();
}

class _TokenTrackingScreenState extends State<TokenTrackingScreen> {
  Map<String, dynamic>? _trackingData;
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadTrackingData();
    // Auto-refresh every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadTrackingData();
    });
  }

  Future<void> _loadTrackingData() async {
    try {
      final data = await ApiClient.getBookingStatus(widget.bookingId);
      if (mounted) {
        setState(() {
          _trackingData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightBg,
        appBar: AppBar(title: const Text('Track Queue')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_trackingData == null) {
      return Scaffold(
        backgroundColor: AppTheme.lightBg,
        appBar: AppBar(title: const Text('Track Queue')),
        body: const Center(child: Text('Failed to load tracking data')),
      );
    }

    final booking = _trackingData!['booking'];
    final currentToken = _trackingData!['currentToken'] ?? 0;
    final yourToken = _trackingData!['yourToken'] ?? 0;
    final patientsBeforeYou = _trackingData!['patientsBeforeYou'] ?? 0;
    final estimatedWaitTime = _trackingData!['estimatedWaitTime'] ?? 0;
    final status = booking['status'];
    final professionalName = booking['professional']?['user']?['name'] ?? 'Professional';
    final professionalTitle = booking['professional']?['title'] ?? '';
    final professionalCity = booking['professional']?['city'] ?? '';
    final professionalAddress = booking['professional']?['address'] ?? '';

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Live Queue Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrackingData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTrackingData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Current Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: _getStatusGradient(status),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      _getStatusIcon(status),
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getStatusTitle(status),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getStatusDescription(status),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Your Token Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryBlue, width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Token Number',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$yourToken',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Queue Information
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Current Token',
                      '$currentToken',
                      Icons.play_arrow,
                      AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      'Ahead of You',
                      '$patientsBeforeYou',
                      Icons.people,
                      AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              _buildWaitTimeCard(estimatedWaitTime),
              const SizedBox(height: 24),

              // Professional Details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Professional Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Name', professionalName),
                    _buildDetailRow('Specialization', professionalTitle),
                    if (professionalAddress.isNotEmpty)
                      _buildDetailRow('Address', professionalAddress),
                    if (professionalCity.isNotEmpty)
                      _buildDetailRow('City', professionalCity),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Appointment Details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Appointment Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Patient', booking['name'] ?? 'N/A'),
                    if (booking['age'] != null)
                      _buildDetailRow('Age', '${booking['age']} years'),
                    if (booking['phone'] != null)
                      _buildDetailRow('Contact', booking['phone']),
                    _buildDetailRow('Date', DateFormat('MMM dd, yyyy').format(
                      DateTime.parse(booking['appointmentDate']),
                    )),
                    _buildDetailRow('Status', _getStatusText(status)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Cancel Button (if not completed/cancelled)
              if (status != 'COMPLETED' && status != 'CANCELLED' && status != 'NO_SHOW')
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => _cancelBooking(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text(
                      'Cancel Appointment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitTimeCard(int minutes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.access_time,
              color: AppTheme.primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated Wait Time',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  minutes > 0 ? '$minutes minutes' : 'Your turn soon!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment?'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiClient.cancelBooking(widget.bookingId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Appointment cancelled successfully'),
              backgroundColor: AppTheme.primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          _loadTrackingData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  LinearGradient _getStatusGradient(String status) {
    switch (status) {
      case 'IN_PROGRESS':
        return AppTheme.greenGradient;
      case 'COMPLETED':
        return const LinearGradient(colors: [Colors.green, Colors.teal]);
      case 'CANCELLED':
      case 'NO_SHOW':
        return const LinearGradient(colors: [Colors.red, Colors.orange]);
      default:
        return AppTheme.blueGradient;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'IN_PROGRESS':
        return Icons.hourglass_bottom;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      case 'NO_SHOW':
        return Icons.error;
      default:
        return Icons.schedule;
    }
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'PENDING':
        return 'In Queue';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'IN_PROGRESS':
        return 'Your Turn!';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      case 'NO_SHOW':
        return 'Missed';
      default:
        return status;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'PENDING':
      case 'CONFIRMED':
        return 'Please wait for your turn';
      case 'IN_PROGRESS':
        return 'Please proceed to the consultation room';
      case 'COMPLETED':
        return 'Your appointment has been completed';
      case 'CANCELLED':
        return 'This appointment was cancelled';
      case 'NO_SHOW':
        return 'You missed this appointment';
      default:
        return '';
    }
  }

  String _getStatusText(String status) {
    return status.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
