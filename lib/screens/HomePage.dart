import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

void main() {
  runApp(ParkEase());
}

class ParkEase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkEase',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: ParkingListingPage(),
    );
  }
}

class ParkingListingPage extends StatelessWidget {
  final List<ParkingArea> parkingAreas = [
    ParkingArea(name: 'Parking Area 1', availableSlots: 20),
    ParkingArea(name: 'Parking Area 2', availableSlots: 15),
    ParkingArea(name: 'Parking Area 3', availableSlots: 10),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 19, 39),
        title: Text(
          'ParkingAreas',
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: parkingAreas.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(parkingAreas[index].name),
            subtitle:
                Text('Available Slots: ${parkingAreas[index].availableSlots}'),
            onTap: () {
              Navigator.push(
                context,
                // ignore: inference_failure_on_instance_creation
                MaterialPageRoute(
                  builder: (context) =>
                      ParkingDetailsPage(parking: parkingAreas[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ParkingDetailsPage extends StatelessWidget {
  final ParkingArea parking;

  ParkingDetailsPage({required this.parking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 0, 19, 39),
          title: Text(parking.name,
              style: const TextStyle(
                color: Colors.white70,
              ))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('AvailableSlots: ${parking.availableSlots}'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  // ignore: inference_failure_on_instance_creation
                  MaterialPageRoute(
                    builder: (context) => BookingPage(parking: parking),
                  ),
                );
              },
              child: Text('Book Your Slot'),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingPage extends StatefulWidget {
  final ParkingArea parking;

  BookingPage({required this.parking});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  Razorpay _razorpay = Razorpay();
  List<String> selectedSeats = [];
  int length = 0;

  @override
  void initState() {
    super.initState();
    // Initialize length after widget is fully initialized
    length = int.parse(widget.parking.availableSlots.toString());
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment successful, handle success logic here
    print("Payment Success: ${response.paymentId}");
    // Display success message or navigate to next screen
    _showSuccessDialog(context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Payment failed, handle failure logic here
    print("Payment Error: ${response.code.toString()} - ${response.message}");
    // Display error message or try payment again
    _showErrorDialog(context);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet payment (e.g., PayTM, Google Pay)
    print("External Wallet: ${response.walletName}");
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_Sl3dOkXD2bsnlP',
      'amount': 10000, // Amount in smallest currency unit (e.g., cents)
      'name': 'ParkEase',
      'description': 'Slot Booking',
      'prefill': {'contact': '9876543210', 'email': 'example@example.com'},
      'external': {
        'wallets': ['paytm'],
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 0, 19, 39),
          title: Text('Book Slots',
              style: TextStyle(
                color: Colors.white70,
              ))),
      body: Column(
        children: [
          Text('Selected Parking Area: ${widget.parking.name}'),
          Text('Select your slots:'),
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            children: List.generate(length, (index) {
              final seatNumber = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    final seat = 'Slot $seatNumber';
                    if (selectedSeats.contains(seat)) {
                      selectedSeats.remove(seat);
                    } else {
                      selectedSeats.add(seat);
                    }
                  });
                },
                child: Container(
                  margin: EdgeInsets.all(5),
                  color: selectedSeats.contains('Slot $seatNumber')
                      ? Colors.red
                      : Colors.green,
                  child: Center(child: Text('Slot $seatNumber')),
                ),
              );
            }),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement ticket booking logic here
              _openCheckout();
            },
            child: Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    // ignore: inference_failure_on_function_invocation
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Your booking is confirmed!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context) {
    // ignore: inference_failure_on_function_invocation
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Payment failed. Please try again.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class ParkingArea {
  final String name;
  final int availableSlots;

  ParkingArea({required this.name, required this.availableSlots});
}
