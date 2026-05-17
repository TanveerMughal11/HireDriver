# HireDrive Flutter - Quick Service Reference for UI Integration

Use this guide to quickly find which service to use for each screen.

---

## 🔐 Authentication Screens

### Login Screen
**File**: `lib/auth/login/screen/login.dart`  
**Services to Use**:
```dart
import 'package:hire_driver/auth/login/services/login.dart';
import 'package:hire_driver/service/user_service.dart';

// Login
final result = await LoginApiService.login(
  email: email,
  password: password,
);

if (result['success']) {
  await UserService.saveTokenLocally(result['data']['token']);
  await UserService.saveUserIdLocally(result['data']['user']['_id']);
  // Navigate to home
}
```

### Signup Screen
**File**: `lib/auth/Signup/signup.dart`  
**Services to Use**:
```dart
import 'package:hire_driver/service/signup.dart';
import 'package:hire_driver/service/otp.dart';
import 'package:hire_driver/service/user_service.dart';

// Register
final result = await ApiService.signup(
  fullName: name,
  email: email,
  phone: phone,
  password: password,
  gender: gender,
);

// Verify OTP
final otpResult = await OtpApiService.verifyOtp(
  email: email,
  otp: otp,
);

if (otpResult['success']) {
  await UserService.saveTokenLocally(otpResult['data']['token']);
  // Navigate to next screen
}
```

### Forgot Password
**Services to Use**:
```dart
import 'package:hire_driver/auth/login/services/login.dart';

// Request OTP
await LoginApiService.requestForgotPasswordOtp(email: email);

// Verify OTP
final verify = await LoginApiService.verifyForgotPasswordOtp(
  email: email,
  otp: otp,
);

// Reset Password
if (verify['success']) {
  final reset = await LoginApiService.resetForgotPassword(
    email: email,
    resetToken: verify['data']['resetToken'],
    newPassword: newPassword,
    confirmPassword: confirmPassword,
  );
}
```

---

## 👤 Profile Screens

### Profile View
**File**: `lib/view/profile/screens/profile.dart`  
**Services to Use**:
```dart
import 'package:hire_driver/service/auth_service.dart';
import 'package:hire_driver/service/user_service.dart';
import 'package:hire_driver/view/profile/services/profile.dart';

// Get profile
final profile = await AuthService.getMe();

// Get application status
final driverApp = await ProfileService.getMyApplication();
final riderApp = await ProfileService.getMyRiderApplication();
```

### Edit Profile
**Services to Use**:
```dart
import 'package:hire_driver/service/auth_service.dart';

final result = await AuthService.updateProfile(
  fullName: fullName,
  email: email,
  phone: phone,
  gender: gender,
);
```

### Change Password
**Services to Use**:
```dart
import 'package:hire_driver/service/auth_service.dart';

final result = await AuthService.changePassword(
  currentPassword: currentPassword,
  newPassword: newPassword,
  confirmPassword: confirmPassword,
);
```

### Logout
**Services to Use**:
```dart
import 'package:hire_driver/service/auth_service.dart';
import 'package:hire_driver/service/user_service.dart';

// Clear all data
await AuthService.logout();
// Or manually
await UserService.clearAllLocalData();
```

---

## 📋 Application Screens

### Driver Application Form
**File**: `lib/view/applyasdriver2nd.dart` (or create new)  
**Services to Use**:
```dart
import 'package:hire_driver/service/applyasrider.dart';

// Check status
final status = await DriverApplicationApiService.getMyApplication();

// Save personal info
await DriverApplicationApiService.savePersonalInfo(
  fullName: fullName,
  cnicNumber: cnicNumber,
  dateOfBirth: dob,
  homeAddress: address,
);

// Upload documents
await DriverApplicationApiService.uploadDocuments(
  cnicFront: cnicFront,
  cnicBack: cnicBack,
  licenseFront: licenseFront,
  licenseBack: licenseBack,
);

// Save vehicle info
await DriverApplicationApiService.saveVehicleInfo(
  vehicleMakeModel: vehicleModel,
  plateNumber: plateNumber,
  services: ['Ride', 'Delivery'],
);

// Submit
await DriverApplicationApiService.submitApplication();
```

### Driver Verification
**File**: `lib/view/applyasdriver2nd.dart`  
**Services to Use**:
```dart
import 'package:hire_driver/view/applyasdriver2nd.dart';

// Get status
final status = await DriverVerificationApiService.getMyDriverVerification();

// Submit verification
await DriverVerificationApiService.submitDriverVerification(
  profilePicture: profileFile,
  documents: docFiles,
);
```

### Rider Application
**File**: Create new screen or use existing  
**Services to Use**:
```dart
import 'package:hire_driver/service/rider_application_service.dart';

// Check status
final status = await RiderApplicationApiService.getMyApplication();

// Save personal info
await RiderApplicationApiService.savePersonalInfo(
  fullName: fullName,
  cnicNumber: cnic,
  dateOfBirth: dob,
  homeAddress: address,
);

// Upload documents
await RiderApplicationApiService.uploadDocuments(
  cnicFront: cnicFront,
  cnicBack: cnicBack,
);

// Submit
await RiderApplicationApiService.submitApplication();
```

---

## 🚗 Ride Screens

### Book a Ride
**File**: `lib/view/book a ride/screens/bookaride.dart`  
**Services to Use**:
```dart
import 'package:hire_driver/service/ride_booking_service.dart';

// Preview
final preview = await RideBookingService.previewRide(
  pickupAddress: pickup,
  pickupLat: 37.7749,
  pickupLng: -122.4194,
  dropoffAddress: dropoff,
  dropoffLat: 37.7849,
  dropoffLng: -122.4094,
  tripType: 'one-way',
  distanceKm: 5.0,
  durationMinutes: 15.0,
);

// Create
final ride = await RideBookingService.createRideRequest(
  pickupAddress: pickup,
  pickupLat: 37.7749,
  pickupLng: -122.4194,
  dropoffAddress: dropoff,
  dropoffLat: 37.7849,
  dropoffLng: -122.4094,
  tripType: 'one-way',
  distanceKm: 5.0,
  durationMinutes: 15.0,
  priceQuote: preview['data']['estimatedPrice'],
  notes: notes,
);

// Broadcast
final broadcast = await RideBookingService.broadcastRideRequest(rideId);
```

### Available Rides (Driver)
**File**: `lib/view/book a ride/screens/drivertraveling.dart` (or new)  
**Services to Use**:
```dart
import 'package:hire_driver/service/driver_ride_service.dart';

// Get available rides
final available = await DriverRideService.getAvailableRideRequests();

// View specific ride
final rideDetails = await DriverRideService.getAvailableRideRequest(rideId);

// Accept
final accept = await DriverRideService.acceptRideRequest(
  rideId: rideId,
  bidPrice: 250.0,
);
```

### Active Ride Management (Driver)
**Services to Use**:
```dart
import 'package:hire_driver/service/driver_ride_service.dart';

// Get active ride
final active = await DriverRideService.getActiveRide();

// Arrived at pickup
await DriverRideService.arrivedAtPickup(rideId);

// Start ride
await DriverRideService.startRide(rideId);

// End ride
await DriverRideService.endRide(
  rideId: rideId,
  finalPrice: 250.0,
  distanceCovered: 5.0,
);

// View trip summary
final summary = await DriverRideService.getDriverTripSummary(rideId);
```

### Driver Offers (Rider)
**File**: `lib/view/book a ride/screens/offerrider.dart`  
**Services to Use**:
```dart
import 'package:hire_driver/service/ride_booking_service.dart';

// Get offers
final offers = await RideBookingService.getRideOffers(rideId);

// Accept offer
await RideBookingService.acceptRideOffer(
  rideId: rideId,
  offerId: offerId,
);

// Decline offer
await RideBookingService.declineRideOffer(
  rideId: rideId,
  offerId: offerId,
);

// Counter offer
await RideBookingService.counterOffer(
  rideId: rideId,
  offerId: offerId,
  counterPrice: 200.0,
);
```

### Rider History
**File**: `lib/view/history.dart`  
**Services to Use**:
```dart
import 'package:hire_driver/service/ride_booking_service.dart';

// Get my rides
final myRides = await RideBookingService.listMyRideRequests();
```

---

## 🏎️ Hire Driver Screens

### Hire Driver
**File**: `lib/view/hiredriver/screens/hiredriver.dart`  
**Services to Use**:
```dart
import 'package:hire_driver/service/hire_driver_service.dart';

// Get options
final options = await HireDriverService.getOptions();

// Preview
final preview = await HireDriverService.previewHireDriver(
  serviceType: 'Standard',
  pickupAddress: pickup,
  pickupLat: 37.7749,
  pickupLng: -122.4194,
  dropoffAddress: dropoff,
  dropoffLat: 37.7849,
  dropoffLng: -122.4094,
  scheduledDate: '2024-01-15',
  scheduledTime: '14:00',
  vehicleModel: 'Honda Civic',
  vehicleColor: 'Black',
  plateNumber: 'ABC-123',
  estimatedDistanceKm: 5.0,
  estimatedDurationMinutes: 15.0,
);

// Create request
final request = await HireDriverService.createHireDriverRequest(
  serviceType: 'Standard',
  pickupAddress: pickup,
  pickupLat: 37.7749,
  pickupLng: -122.4194,
  dropoffAddress: dropoff,
  dropoffLat: 37.7849,
  dropoffLng: -122.4094,
  scheduledDate: '2024-01-15',
  scheduledTime: '14:00',
  vehicleModel: 'Honda Civic',
  vehicleColor: 'Black',
  plateNumber: 'ABC-123',
  estimatedDistanceKm: 5.0,
  estimatedDurationMinutes: 15.0,
  estimatedPrice: preview['data']['estimatedPrice'],
);
```

### Available Drivers
**File**: `lib/view/hiredriver/screens/avaibledrivers.dart`  
**Services to Use**:
```dart
import 'package:hire_driver/service/hire_driver_service.dart';

// Find drivers
await HireDriverService.findAvailableDrivers(hireRequestId);

// Get driver list
final drivers = await HireDriverService.getAvailableDrivers(hireRequestId);

// Select driver
await HireDriverService.selectDriver(
  hireRequestId: hireRequestId,
  offerId: offerId,
);

// Confirm booking
final booking = await HireDriverService.confirmBooking(hireRequestId);
```

---

## 🏠 Rental Screens

### Car Listing
**File**: `lib/view/car rental/screens/carlisting.dart`  
**Services to Use**:
```dart
import 'package:hire_driver/service/rental_service.dart';

// Browse cars
final listings = await RentalService.browseListings(
  location: 'San Francisco',
  vehicleType: 'SUV',
  minPrice: 50,
  maxPrice: 200,
);

// View details
final details = await RentalService.getListingDetails(listingId);
```

### Book Rental
**File**: `lib/view/car rental/screens/bookrental.dart`  
**Services to Use**:
```dart
import 'package:hire_driver/service/rental_service.dart';

// Preview
final preview = await RentalService.previewBooking(
  listingId: listingId,
  startDate: '2024-01-15',
  endDate: '2024-01-20',
  numberOfDays: 5,
);

// Book
final booking = await RentalService.bookRental(
  listingId: listingId,
  startDate: '2024-01-15',
  endDate: '2024-01-20',
  numberOfDays: 5,
  totalPrice: preview['data']['totalPrice'],
  pickupLocation: 'Airport',
  dropoffLocation: 'Downtown',
);
```

### Rental History
**File**: `lib/view/car rental/screens/carrentingdetail.dart`  
**Services to Use**:
```dart
import 'package:hire_driver/service/rental_service.dart';

// Get bookings
final bookings = await RentalService.getMyBookings();

// Get booking details
final details = await RentalService.getBookingDetails(bookingId);

// Get active rentals
final active = await RentalService.getActiveRentals();

// Return car
await RentalService.returnCar(
  bookingId: bookingId,
  rating: 5.0,
  review: 'Great car!',
);
```

### Create Car Listing (Owner)
**File**: `lib/view/forms/screen/carlistingform.dart`  
**Services to Use**:
```dart
import 'package:hire_driver/service/rental_service.dart';

// Create listing
final listing = await RentalService.createListing(
  carMakeModel: 'Honda Civic 2020',
  carType: 'Sedan',
  color: 'Black',
  plateNumber: 'ABC-123',
  pricePerDay: 50.0,
  description: 'Well-maintained sedan',
  amenities: ['AC', 'Power Steering', 'Airbags'],
);

// Upload photos
await RentalService.uploadListingPhotos(
  listingId: listing['data']['_id'],
  photos: [photo1, photo2, photo3],
);

// Submit for approval
await RentalService.submitListingForApproval(listingId);
```

### Owner Dashboard
**File**: `lib/view/host/` screens  
**Services to Use**:
```dart
import 'package:hire_driver/service/rental_service.dart';

// Dashboard
final dashboard = await RentalService.getOwnerDashboard();

// Earnings
final earnings = await RentalService.getOwnerEarnings();

// Rental requests
final requests = await RentalService.getOwnerRentalRequests();

// Request details
final details = await RentalService.getOwnerRentalRequestDetails(bookingId);

// Accept request
await RentalService.acceptRentalRequest(bookingId);

// Decline request
await RentalService.declineRentalRequest(bookingId);
```

---

## 👥 Request Screens

### Driver Requests
**File**: `lib/view/driver/home.dart` or new screen  
**Services to Use**:
```dart
import 'package:hire_driver/service/driver_request_service.dart';

// Dashboard
final dashboard = await DriverRequestService.getDashboard();

// Incoming requests
final requests = await DriverRequestService.getIncomingRequests();

// Update availability
await DriverRequestService.updateAvailability(true); // Go online

// View request
final details = await DriverRequestService.getRequestDetails(requestId);

// Accept/Decline
await DriverRequestService.acceptRequest(requestId);
await DriverRequestService.declineRequest(requestId);

// Navigation
final nav = await DriverRequestService.getNavigationPayload(requestId);
```

### Rider Requests
**File**: `lib/view/rider/home.dart` or new screen  
**Services to Use**:
```dart
import 'package:hire_driver/service/rider_request_service.dart';

// Dashboard
final dashboard = await RiderRequestService.getDashboard();

// Incoming requests
final requests = await RiderRequestService.getIncomingRequests();

// Update availability
await RiderRequestService.updateAvailability(true); // Go online

// View request
final details = await RiderRequestService.getRequestDetails(requestId);

// Accept/Decline
await RiderRequestService.acceptRequest(requestId);
await RiderRequestService.declineRequest(requestId);

// Navigation
final nav = await RiderRequestService.getNavigationPayload(requestId);
```

---

## 📊 Dashboard Screens

### Home Screen
**File**: `lib/view/home.dart`  
**Services to Use**:
```dart
import 'package:hire_driver/service/auth_service.dart';
import 'package:hire_driver/service/user_service.dart';
import 'package:hire_driver/view/profile/services/profile.dart';

// Get user profile
final profile = await AuthService.getMe();

// Get application status
final appStatus = await ProfileService.getMyApplication();

// Get role from localStorage
final role = await UserService.getUserRoleLocally();

// Use role to show appropriate content
if (role == 'driver') {
  // Show driver content
} else if (role == 'rider') {
  // Show rider content
}
```

---

## 🔄 Common Patterns

### Loading State Management
```dart
bool isLoading = false;
String? errorMessage;

// Call service
setState(() => isLoading = true);
final result = await SomeService.someMethod();
setState(() => isLoading = false);

if (result['success']) {
  // Handle success
} else {
  setState(() => errorMessage = result['message']);
}
```

### Token Handling
```dart
import 'package:hire_driver/service/user_service.dart';

// Check if logged in
final token = await UserService.getTokenLocally();
if (token == null) {
  // Navigate to login
}
```

### Error Handling
```dart
try {
  final result = await SomeService.someMethod();
  if (result['success']) {
    // Success
  } else {
    // API error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'])),
    );
  }
} catch (e) {
  // Network or exception error
  print('Exception: $e');
}
```

---

## 📝 Summary Table

| Screen | Service to Use |
|--------|---|
| Login | LoginApiService |
| Signup | ApiService, OtpApiService |
| Profile | AuthService, UserService |
| Driver App | DriverApplicationApiService |
| Driver Verify | DriverVerificationApiService |
| Rider App | RiderApplicationApiService |
| Book Ride | RideBookingService |
| Driver Rides | DriverRideService |
| Hire Driver | HireDriverService |
| Driver Requests | DriverRequestService |
| Rider Requests | RiderRequestService |
| Browse Rentals | RentalService |
| Book Rental | RentalService |
| Create Listing | RentalService |
| Owner Dashboard | RentalService |
| History | RideBookingService, RentalService |
| Home | AuthService, UserService |

---

**Ready to integrate? Start with the Authentication screens and work your way through each feature!**
