import 'package:flutter/material.dart';
import '../controllers/converter_controller.dart';
import '../models/currency_model.dart';
import '../models/timezone_model.dart';
import '../utils/constants.dart';

class ConvertScreen extends StatefulWidget {
  @override
  _ConvertScreenState createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen> {
  final TextEditingController _amountController =
      TextEditingController(text: '10');
  final TextEditingController _dateTimeController = TextEditingController();

  String _fromCurrency = 'USD - US Dollar';
  String _toCurrency = 'IDR - Indonesian Rupiah';
  String _fromTimezone = 'Jakarta (WIB)';
  String _toTimezone = 'New York (EST)';

  String? _currencyResult;
  String? _timezoneResult;
  bool _isLoadingCurrency = false;
  bool _isLoadingTimezone = false;

  final List<String> _currencies = [
    'USD - US Dollar',
    'IDR - Indonesian Rupiah',
    'EUR - Euro',
    'GBP - British Pound',
    'JPY - Japanese Yen',
    'SGD - Singapore Dollar',
    'MYR - Malaysian Ringgit',
  ];

  final List<String> _timezones = [
    'Jakarta (WIB)',
    'New York (EST)',
    'London (GMT)',
    'Tokyo (JST)',
    'Sydney (AEDT)',
    'Dubai (GST)',
    'Singapore (SGT)',
  ];

  @override
  void initState() {
    super.initState();
    _setCurrentDateTime();
  }

  void _setCurrentDateTime() {
    final now = DateTime.now();
    _dateTimeController.text =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _convertCurrency() async {
    if (_amountController.text.isEmpty) {
      _showSnackBar('Please enter an amount', Colors.red);
      return;
    }

    setState(() {
      _isLoadingCurrency = true;
      _currencyResult = null;
    });

    try {
      final amount = double.parse(_amountController.text);
      final result = await ConverterController.convertCurrency(
        amount: amount,
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
      );

      setState(() {
        _currencyResult = result;
      });
    } catch (e) {
      _showSnackBar('Error converting currency: $e', Colors.red);
    } finally {
      setState(() {
        _isLoadingCurrency = false;
      });
    }
  }

  Future<void> _convertTimezone() async {
    if (_dateTimeController.text.isEmpty) {
      _showSnackBar('Please select date and time', Colors.red);
      return;
    }

    setState(() {
      _isLoadingTimezone = true;
      _timezoneResult = null;
    });

    try {
      final result = await ConverterController.convertTimezone(
        dateTime: _dateTimeController.text,
        fromTimezone: _fromTimezone,
        toTimezone: _toTimezone,
      );

      setState(() {
        _timezoneResult = result;
      });
    } catch (e) {
      _showSnackBar('Error converting timezone: $e', Colors.red);
    } finally {
      setState(() {
        _isLoadingTimezone = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  Widget _buildCurrencyConverter() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Currency Converter',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Average cocktail ingredient prices',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),

          // Amount Input
          Text(
            'Amount',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter amount',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.orange),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          SizedBox(height: 16),

          // From Currency
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _fromCurrency,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: _currencies.map((String currency) {
                        return DropdownMenuItem<String>(
                          value: currency,
                          child: Text(
                            currency,
                            style: TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _fromCurrency = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _toCurrency,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: _currencies.map((String currency) {
                        return DropdownMenuItem<String>(
                          value: currency,
                          child: Text(
                            currency,
                            style: TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _toCurrency = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Convert Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoadingCurrency ? null : _convertCurrency,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoadingCurrency
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Convert',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          // Currency Result
          if (_currencyResult != null) ...[
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Text(
                _currencyResult!,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimezoneConverter() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Zone Converter',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Check happy hour times around the world',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),

          // Date & Time Input
          Text(
            'Date & Time',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _dateTimeController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Select date and time',
              suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.orange),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2030),
              );

              if (pickedDate != null) {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (pickedTime != null) {
                  final formattedDateTime =
                      '${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year} ${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                  _dateTimeController.text = formattedDateTime;
                }
              }
            },
          ),
          SizedBox(height: 16),

          // From and To Timezone
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _fromTimezone,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: _timezones.map((String timezone) {
                        return DropdownMenuItem<String>(
                          value: timezone,
                          child: Text(
                            timezone,
                            style: TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _fromTimezone = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _toTimezone,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: _timezones.map((String timezone) {
                        return DropdownMenuItem<String>(
                          value: timezone,
                          child: Text(
                            timezone,
                            style: TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _toTimezone = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Convert Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoadingTimezone ? null : _convertTimezone,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoadingTimezone
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Convert',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          // Timezone Result
          if (_timezoneResult != null) ...[
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Text(
                _timezoneResult!,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text(
              'Converter',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            _buildCurrencyConverter(),
            _buildTimezoneConverter(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }
}
