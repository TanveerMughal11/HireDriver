// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:hire_driver/utils/app_colors.dart';
// import 'package:hire_driver/service/applyasrider.dart';

// class ApplyAsDriverFlowScreen extends StatefulWidget {
//   const ApplyAsDriverFlowScreen({super.key});

//   @override
//   State<ApplyAsDriverFlowScreen> createState() =>
//       _ApplyAsDriverFlowScreenState();
// }

// class _ApplyAsDriverFlowScreenState extends State<ApplyAsDriverFlowScreen> {
//   int currentStep = 0;
//   bool isLoading = false;
//   bool alreadySubmitted = false;

//   final ImagePicker _picker = ImagePicker();
// String? fullNameError;
// String? cnicError;
// String? dobError;
// String? addressError;
// String? vehicleError;
// String? plateError;
// String? documentError;
// String? serviceError;
// String? consentError;

//   final TextEditingController cnicController = TextEditingController();
//   final TextEditingController dobController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();

// final TextEditingController fullNameController = TextEditingController();

// final TextEditingController vehicleController = TextEditingController();

// final TextEditingController plateController = TextEditingController();

//   XFile? cnicFrontFile;
//   XFile? cnicBackFile;
//   XFile? licenseFrontFile;
//   XFile? licenseBackFile;

//   bool hireDriverService = true;
//   bool bookRideService = false;
//   bool consentAccepted = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadMyApplication();
//   }

//   Future<void> _loadMyApplication() async {
//     try {
//       final res = await DriverApplicationApiService.getMyApplication();

//       if (res['success'] == true && res['application'] != null) {
//         final application = res['application'];
//         final progress = application['progress'];

//         final bool isSubmitted =
//             application['status'] == 'pending_admin' ||
//             application['status'] == 'submitted' ||
//             application['status'] == 'approved' ||
//             application['status'] == 'rejected' ||
//             progress?['submittedAt'] != null;

//         if (isSubmitted) {
//           setState(() {
//             alreadySubmitted = true;
//             currentStep = 4;
//           });
//           return;
//         }

//         if (progress != null) {
//           if (progress['personalInfoCompleted'] == true) {
//             currentStep = 1;
//           }
//           if (progress['documentsCompleted'] == true) {
//             currentStep = 2;
//           }
//           if (progress['vehicleInfoCompleted'] == true) {
//             currentStep = 3;
//           }
//         }

//         final personalInfo = application['personalInfo'];
//         final vehicleInfo = application['vehicleInfo'];

//         if (personalInfo != null) {
//           fullNameController.text = personalInfo['fullName'] ?? '';
//           cnicController.text = personalInfo['cnicNumber'] ?? '';
//           addressController.text = personalInfo['homeAddress'] ?? '';

//           final dob = personalInfo['dateOfBirth'];
//           if (dob != null && dob.toString().isNotEmpty) {
//             dobController.text = dob.toString().split('T').first;
//           }
//         }

//         if (vehicleInfo != null) {
//           vehicleController.text = vehicleInfo['vehicleMakeModel'] ?? '';
//           plateController.text = vehicleInfo['plateNumber'] ?? '';

//           final services = vehicleInfo['services'] ?? [];
//           hireDriverService = services.contains('hire_driver');
//           bookRideService = services.contains('book_ride');
//         }

//         setState(() {});
//       }
//     } catch (e) {
//       debugPrint('Get my application error: $e');
//     }
//   }

//   @override
//   void dispose() {
//     fullNameController.dispose();
//     cnicController.dispose();
//     dobController.dispose();
//     addressController.dispose();
//     vehicleController.dispose();
//     plateController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickDocument(String type) async {
//     final XFile? picked = await _picker.pickImage(
//       source: ImageSource.camera,
//       imageQuality: 80,
//     );

//     if (picked == null) return;

//     setState(() {
//       if (type == 'cnicFront') cnicFrontFile = picked;
//       if (type == 'cnicBack') cnicBackFile = picked;
//       if (type == 'licenseFront') licenseFrontFile = picked;
//       if (type == 'licenseBack') licenseBackFile = picked;
//     });
//   }

//   Future<void> _pickDob() async {
//     final now = DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime(now.year - 22),
//       firstDate: DateTime(1950),
//       lastDate: now,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: AppColors.primary,
//               onPrimary: Colors.white,
//               onSurface: AppColors.textPrimary,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       dobController.text =
//           '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
//       setState(() {});
//     }
//   }

//   Future<void> _nextStep() async {
//     try {
// if (currentStep == 0) {
//   setState(() {
//     fullNameError = null;
//     cnicError = null;
//     dobError = null;
//     addressError = null;
//   });

//   bool hasError = false;

//   if (fullNameController.text.trim().isEmpty) {
//     fullNameError = 'Enter full name';
//     hasError = true;
//   } else if (fullNameController.text.trim().length < 3) {
//     fullNameError = 'Enter valid full name';
//     hasError = true;
//   }

//   if (cnicController.text.trim().isEmpty) {
//     cnicError = 'Enter CNIC number';
//     hasError = true;
//   } else if (cnicController.text.trim().length != 13) {
//     cnicError = 'CNIC must be 13 digits';
//     hasError = true;
//   }

//   if (dobController.text.trim().isEmpty) {
//     dobError = 'Select date of birth';
//     hasError = true;
//   }

//   if (addressController.text.trim().isEmpty) {
//     addressError = 'Enter home address';
//     hasError = true;
//   }

//   if (hasError) {
//     setState(() {});
//     return;
//   }

//   setState(() => isLoading = true);

//   final res = await DriverApplicationApiService.savePersonalInfo(
//     fullName: fullNameController.text.trim(),
//     cnicNumber: cnicController.text.trim(),
//     dateOfBirth: dobController.text.trim(),
//     homeAddress: addressController.text.trim(),
//   );

//   setState(() => isLoading = false);

//   if (res['success'] != true) {
//     _showSnack(res['message'] ?? 'Personal info failed');
//     return;
//   }
// }

//       if (currentStep == 1) {
//         if (cnicFrontFile == null ||
//             cnicBackFile == null ||
//             licenseFrontFile == null ||
//             licenseBackFile == null) {
//           _showSnack('Please upload all required documents');
//           return;
//         }

//         setState(() => isLoading = true);

//         final res = await DriverApplicationApiService.uploadDocuments(
//           cnicFront: cnicFrontFile!,
//           cnicBack: cnicBackFile!,
//           licenseFront: licenseFrontFile!,
//           licenseBack: licenseBackFile!,
//         );

//         setState(() => isLoading = false);

//         if (res['success'] != true) {
//           _showSnack(res['message'] ?? 'Documents upload failed');
//           return;
//         }
//       }

// if (currentStep == 2) {
//   setState(() {
//     vehicleError = null;
//     plateError = null;
//     serviceError = null;
//   });

//   bool hasError = false;

//   if (vehicleController.text.trim().isEmpty) {
//     vehicleError = 'Enter vehicle info';
//     hasError = true;
//   }

//   if (plateController.text.trim().isEmpty) {
//     plateError = 'Enter plate number';
//     hasError = true;
//   } else if (!RegExp(r'^[A-Z]{3}-\d{4}$')
//       .hasMatch(plateController.text.trim())) {
//     plateError = 'Use format LEA-1234';
//     hasError = true;
//   }

//   final services = <String>[];
//   if (hireDriverService) services.add('hire_driver');
//   if (bookRideService) services.add('book_ride');

//   if (services.isEmpty) {
//     serviceError = 'Select at least one service';
//     hasError = true;
//   }

//   if (hasError) {
//     setState(() {});
//     return;
//   }

//   setState(() => isLoading = true);

//   final res = await DriverApplicationApiService.saveVehicleInfo(
//     vehicleMakeModel: vehicleController.text.trim(),
//     plateNumber: plateController.text.trim(),
//     services: services,
//   );

//   setState(() => isLoading = false);

//   if (res['success'] != true) {
//     _showSnack(res['message'] ?? 'Vehicle info failed');
//     return;
//   }
// }
//       if (currentStep == 3) {
//        if (!consentAccepted) {
//   setState(() {
//     consentError = 'Please accept terms';
//   });
//   return;
// }

//         setState(() => isLoading = true);

//         final res = await DriverApplicationApiService.submitApplication();

//         setState(() => isLoading = false);

//         if (res['success'] != true) {
//           _showSnack(res['message'] ?? 'Submit failed');
//           return;
//         }

//         setState(() {
//           alreadySubmitted = true;
//           currentStep = 4;
//         });

//         return;
//       }

//       setState(() {
//         currentStep++;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//       _showSnack(e.toString());
//     }
//   }

//   void _showSnack(String text) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(text)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (currentStep == 4) {
//       return _ApplicationSubmittedScreen(
//         onBackHome: () => Navigator.pop(context),
//       );
//     }

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildTopBanner(),
//                     const SizedBox(height: 22),
//                     _buildStepper(),
//                     const SizedBox(height: 22),
//                     if (currentStep == 0) _buildPersonalInfoStep(),
//                     if (currentStep == 1) _buildDocumentsStep(),
//                     if (currentStep == 2) _buildVehicleStep(),
//                     if (currentStep == 3) _buildConsentStep(),
//                   ],
//                 ),
//               ),
//             ),
//             _buildBottomButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
//       child: Row(
//         children: [
//           InkWell(
//             onTap: () => Navigator.pop(context),
//             borderRadius: BorderRadius.circular(16),
//             child: Container(
//               height: 42,
//               width: 42,
//               decoration: BoxDecoration(
//                 color: AppColors.white.withOpacity(0.7),
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: AppColors.secondary),
//               ),
//               child: const Icon(
//                 Icons.arrow_back_ios_new_rounded,
//                 size: 18,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           const Text(
//             'Apply as Rider',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w800,
//               color: AppColors.textPrimary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTopBanner() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [AppColors.darkPrimary, AppColors.primary],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.18),
//             blurRadius: 18,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: 46,
//             width: 46,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.16),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.payments_rounded,
//               color: Colors.amber,
//               size: 26,
//             ),
//           ),
//           const SizedBox(width: 14),
//           const Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Earn PKR 40,000–80,000/month',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 15.5,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   'Work on your own schedule · No lease',
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 12.5,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStepper() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: _EqualStepItem(
//             index: 0,
//             title: 'PERSONAL\nINFO',
//             currentStep: currentStep,
//           ),
//         ),
//         Expanded(
//           child: _EqualStepItem(
//             index: 1,
//             title: 'DOCUMENTS',
//             currentStep: currentStep,
//           ),
//         ),
//         Expanded(
//           child: _EqualStepItem(
//             index: 2,
//             title: 'VEHICLE',
//             currentStep: currentStep,
//           ),
//         ),
//         Expanded(
//           child: _EqualStepItem(
//             index: 3,
//             title: 'CONSENT',
//             currentStep: currentStep,
//             isLast: true,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPersonalInfoStep() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _label('FULL NAME'),
//         const SizedBox(height: 8),
// _textField(
//   controller: fullNameController,
//   hint: 'e.g. Muhammad Ali',
//   errorText: fullNameError,
//   keyboardType: TextInputType.name,
//   inputFormatters: [
//     FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
//   ],
// ),
//         const SizedBox(height: 14),
//         _label('CNIC NUMBER'),
//         const SizedBox(height: 8),
// _textField(
//   controller: cnicController,
//   hint: 'e.g. 3520212345671',
//   errorText: cnicError,
//   keyboardType: TextInputType.number,
//   maxLength: 13,
//   inputFormatters: [
//     FilteringTextInputFormatter.digitsOnly,
//   ],
// ),
//         const SizedBox(height: 14),
//         _label('DATE OF BIRTH'),
//         const SizedBox(height: 8),
//     _dateField(
//   controller: dobController,
//   hint: 'e.g. 1998-05-21',
//   errorText: dobError,
//   onTap: _pickDob,
// ),
//         const SizedBox(height: 14),
//         _label('HOME ADDRESS'),
//         const SizedBox(height: 8),
// _textField(
//   controller: addressController,
//   hint: 'e.g. House 12, Street 5, Lahore',
//   errorText: addressError,
//   keyboardType: TextInputType.streetAddress,
//   inputFormatters: [
//     FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s,.-]')),
//   ],
// ),
//       ],
//     );
//   }

//   Widget _buildDocumentsStep() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Take clear photos using your camera. Gallery upload is not allowed.',
//           style: TextStyle(
//             color: AppColors.textSecondary.withOpacity(0.85),
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 6),
//         const Text(
//           'Make sure document text is clearly visible.',
//           style: TextStyle(
//             color: Colors.red,
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 16),
//         _uploadTile(
//           title: 'Take CNIC Front Photo',
//           uploaded: cnicFrontFile != null,
//           onTap: () => _pickDocument('cnicFront'),
//         ),
//         const SizedBox(height: 12),
//         _uploadTile(
//           title: 'Take CNIC Back Photo',
//           uploaded: cnicBackFile != null,
//           onTap: () => _pickDocument('cnicBack'),
//         ),
//         const SizedBox(height: 12),

// _uploadTile(
//   title: 'Take Profile Photo',
//   uploaded: false, // dummy (no backend yet)
//   onTap: () {
//     // dummy click (you can add picker later)
//     _showSnack('Profile photo feature coming soon');
//   },
// ),
//         const SizedBox(height: 12),
//         _uploadTile(
//           title: 'Take Driving License Front Photo',
//           uploaded: licenseFrontFile != null,
//           onTap: () => _pickDocument('licenseFront'),
//         ),
//         const SizedBox(height: 12),
//         _uploadTile(
//           title: 'Take Driving License Back Photo',
//           uploaded: licenseBackFile != null,
//           onTap: () => _pickDocument('licenseBack'),
//         ),
//       ],
//     );
//   }

// Widget _buildVehicleStep() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       _label('VEHICLE MAKE & MODEL'),
//       const SizedBox(height: 8),
//       _textField(
//         controller: vehicleController,
//         hint: 'e.g. Toyota Corolla 2020',
//         errorText: vehicleError,
//         inputFormatters: [
//           FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
//         ],
//       ),

//       const SizedBox(height: 14),

//       _label('PLATE NUMBER'),
//       const SizedBox(height: 8),
//       _textField(
//         controller: plateController,
//         hint: 'e.g. LEA-1234',
//         errorText: plateError,
//         textCapitalization: TextCapitalization.characters,
//         inputFormatters: [
//           FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9-]')),
//           TextInputFormatter.withFunction((oldValue, newValue) {
//             return newValue.copyWith(
//               text: newValue.text.toUpperCase(),
//               selection: newValue.selection,
//             );
//           }),
//         ],
//       ),

//       const SizedBox(height: 18),

//       const Text(
//         "Services You'll Provide",
//         style: TextStyle(
//           color: AppColors.textPrimary,
//           fontSize: 15,
//           fontWeight: FontWeight.w800,
//         ),
//       ),

//       const SizedBox(height: 12),

//       _serviceOption(
//         selected: hireDriverService,
//         title: "Hire a Rider (use passenger's car)",
//         onTap: () {
//           setState(() {
//             hireDriverService = !hireDriverService;
//             serviceError = null;
//           });
//         },
//       ),

//       const SizedBox(height: 12),

//       _serviceOption(
//         selected: bookRideService,
//         title: 'Book a Ride (use my own car)',
//         onTap: () {
//           setState(() {
//             bookRideService = !bookRideService;
//             serviceError = null;
//           });
//         },
//       ),

//       if (serviceError != null) ...[
//         const SizedBox(height: 8),
//         Text(
//           serviceError!,
//           style: const TextStyle(
//             color: Colors.red,
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     ],
//   );
// }

// Widget _buildConsentStep() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           color: AppColors.white.withOpacity(0.72),
//           borderRadius: BorderRadius.circular(22),
//           border: Border.all(color: AppColors.secondary.withOpacity(0.6)),
//         ),
//         child: Text(
//           "By applying as a Rider on HireDrive, you consent to a background check, CNIC verification, and agree to our Rider Terms of Service.",
//           style: TextStyle(
//             color: AppColors.textPrimary.withOpacity(0.88),
//             fontSize: 14.5,
//             fontWeight: FontWeight.w500,
//             height: 1.6,
//           ),
//         ),
//       ),

//       const SizedBox(height: 16),

//       InkWell(
//         borderRadius: BorderRadius.circular(14),
//         onTap: () {
//           setState(() {
//             consentAccepted = !consentAccepted;
//             consentError = null; // clear error on click
//           });
//         },
//         child: Row(
//           children: [
//             Container(
//               height: 24,
//               width: 24,
//               decoration: BoxDecoration(
//                 color: consentAccepted
//                     ? AppColors.primary
//                     : Colors.transparent,
//                 borderRadius: BorderRadius.circular(6),
//                 border: Border.all(
//                   color: consentAccepted
//                       ? AppColors.primary
//                       : AppColors.textSecondary.withOpacity(0.6),
//                 ),
//               ),
//               child: consentAccepted
//                   ? const Icon(Icons.check, size: 16, color: Colors.white)
//                   : null,
//             ),
//             const SizedBox(width: 12),
//             const Expanded(
//               child: Text(
//                 'I agree to the terms and consent',
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),

//       // ✅ ADD THIS (IMPORTANT)
//       if (consentError != null) ...[
//         const SizedBox(height: 8),
//         Text(
//           consentError!,
//           style: const TextStyle(
//             color: Colors.red,
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     ],
//   );
// }

//   Widget _buildBottomButton() {
//     final List<String> buttonTexts = [
//       'Next: Documents →',
//       'Next: Vehicle Info →',
//       'Next: Review & Sign →',
//       'Submit Application ✓',
//     ];

//     return SafeArea(
//       top: false,
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//         child: SizedBox(
//           width: double.infinity,
//           height: 54,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(18),
//               ),
//             ),
//             onPressed: isLoading ? null : _nextStep,
//             child: isLoading
//                 ? const SizedBox(
//                     height: 22,
//                     width: 22,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2.4,
//                       color: Colors.white,
//                     ),
//                   )
//                 : Text(
//                     buttonTexts[currentStep],
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _label(String text) {
//     return Text(
//       text,
//       style: const TextStyle(
//         color: AppColors.textPrimary,
//         fontSize: 14,
//         fontWeight: FontWeight.w800,
//         letterSpacing: 0.5,
//       ),
//     );
//   }

// Widget _textField({
//   required TextEditingController controller,
//   required String hint,
//   String? errorText,
//   TextInputType keyboardType = TextInputType.text,
//   List<TextInputFormatter>? inputFormatters,
//   int? maxLength,
//   TextCapitalization textCapitalization = TextCapitalization.none,
// }) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Container(
//         decoration: BoxDecoration(
//           color: AppColors.white.withOpacity(0.7),
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(
//             color: errorText != null
//                 ? Colors.red
//                 : AppColors.secondary.withOpacity(0.8),
//           ),
//         ),
//         child: TextField(
//           controller: controller,
//           keyboardType: keyboardType,
//           inputFormatters: inputFormatters,
//           maxLength: maxLength,
//           textCapitalization: textCapitalization,
//           decoration: InputDecoration(
//             counterText: '',
//             hintText: hint,
//             hintStyle: TextStyle(
//               color: AppColors.textSecondary.withOpacity(0.55),
//               fontWeight: FontWeight.w500,
//             ),
//             border: InputBorder.none,
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//           ),
//         ),
//       ),
//       if (errorText != null) ...[
//         const SizedBox(height: 6),
//         Text(
//           errorText,
//           style: const TextStyle(
//             color: Colors.red,
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     ],
//   );
// }

// Widget _dateField({
//   required TextEditingController controller,
//   required String hint,
//   required VoidCallback onTap,
//   String? errorText,
// }) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(18),
//         child: Container(
//           decoration: BoxDecoration(
//             color: AppColors.white.withOpacity(0.7),
//             borderRadius: BorderRadius.circular(18),
//             border: Border.all(
//               color: errorText != null
//                   ? Colors.red
//                   : AppColors.secondary.withOpacity(0.8),
//             ),
//           ),
//           child: IgnorePointer(
//             child: TextField(
//               controller: controller,
//               decoration: InputDecoration(
//                 hintText: hint,
//                 suffixIcon: const Icon(Icons.calendar_today_outlined),
//                 border: InputBorder.none,
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//               ),
//             ),
//           ),
//         ),
//       ),
//       if (errorText != null) ...[
//         const SizedBox(height: 6),
//         Text(
//           errorText,
//           style: const TextStyle(
//             color: Colors.red,
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     ],
//   );
// }
//   Widget _uploadTile({
//     required String title,
//     required bool uploaded,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
//         decoration: BoxDecoration(
//           color: AppColors.white.withOpacity(0.85),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: uploaded
//                 ? const Color(0xFF16A34A).withOpacity(0.6)
//                 : AppColors.secondary.withOpacity(0.7),
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               height: 48,
//               width: 48,
//               decoration: BoxDecoration(
//                 color: AppColors.light,
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Icon(
//                 uploaded ? Icons.check_circle : Icons.camera_alt_rounded,
//                 color: uploaded ? const Color(0xFF16A34A) : AppColors.primary,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   color: AppColors.textPrimary,
//                   fontSize: 15.5,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ),
//             Text(
//               uploaded ? 'Captured ✓' : 'Camera →',
//               style: TextStyle(
//                 color: uploaded
//                     ? const Color(0xFF16A34A)
//                     : AppColors.textSecondary.withOpacity(0.9),
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _serviceOption({
//     required bool selected,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(18),
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: AppColors.white.withOpacity(0.85),
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(
//             color:
//                 selected ? AppColors.primary : AppColors.secondary.withOpacity(0.65),
//             width: selected ? 1.6 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               height: 24,
//               width: 24,
//               decoration: BoxDecoration(
//                 color: selected ? AppColors.primary : Colors.transparent,
//                 borderRadius: BorderRadius.circular(6),
//                 border: Border.all(
//                   color: selected
//                       ? AppColors.primary
//                       : AppColors.textSecondary.withOpacity(0.6),
//                 ),
//               ),
//               child: selected
//                   ? const Icon(Icons.check, size: 16, color: Colors.white)
//                   : null,
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   color: AppColors.textPrimary,
//                   fontSize: 15.5,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ApplicationSubmittedScreen extends StatelessWidget {
//   final VoidCallback onBackHome;

//   const _ApplicationSubmittedScreen({
//     required this.onBackHome,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final steps = [
//       {'title': 'Application Received', 'done': true, 'icon': Icons.check_circle},
//       {'title': 'Document Review', 'done': true, 'icon': Icons.hourglass_bottom},
//       {
//         'title': 'Background Check',
//         'done': false,
//         'icon': Icons.verified_user_outlined
//       },
//       {'title': 'CNIC Verification', 'done': false, 'icon': Icons.badge_outlined},
//       {
//         'title': 'Approval & Activation',
//         'done': false,
//         'icon': Icons.celebration_outlined
//       },
//     ];

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
//           child: Column(
//             children: [
//               const SizedBox(height: 26),
//               Container(
//                 height: 86,
//                 width: 86,
//                 decoration: BoxDecoration(
//                   color: AppColors.light,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppColors.primary.withOpacity(0.12),
//                       blurRadius: 20,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: const Icon(
//                   Icons.celebration_rounded,
//                   color: AppColors.primary,
//                   size: 42,
//                 ),
//               ),
//               const SizedBox(height: 22),
//               const Text(
//                 'Application Submitted!',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: AppColors.textPrimary,
//                   fontSize: 20,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//               const SizedBox(height: 14),
//               Text(
//                 'Our team will review your application and verify your documents within 24–48 hours.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: AppColors.textSecondary.withOpacity(0.85),
//                   fontSize: 15,
//                   fontWeight: FontWeight.w500,
//                   height: 1.7,
//                 ),
//               ),
//               const SizedBox(height: 22),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(18),
//                 decoration: BoxDecoration(
//                   color: AppColors.light.withOpacity(0.75),
//                   borderRadius: BorderRadius.circular(24),
//                   border:
//                       Border.all(color: AppColors.secondary.withOpacity(0.6)),
//                 ),
//                 child: Column(
//                   children: List.generate(steps.length, (index) {
//                     final step = steps[index];
//                     final done = step['done'] as bool;

//                     return Container(
//                       padding: const EdgeInsets.symmetric(vertical: 11),
//                       decoration: BoxDecoration(
//                         border: index != steps.length - 1
//                             ? Border(
//                                 bottom: BorderSide(
//                                   color: AppColors.secondary.withOpacity(0.5),
//                                 ),
//                               )
//                             : null,
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             height: 22,
//                             width: 22,
//                             decoration: BoxDecoration(
//                               color: done
//                                   ? AppColors.primary
//                                   : AppColors.secondary.withOpacity(0.55),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Center(
//                               child: done
//                                   ? const Icon(
//                                       Icons.check,
//                                       size: 14,
//                                       color: Colors.white,
//                                     )
//                                   : Text(
//                                       '${index + 1}',
//                                       style: TextStyle(
//                                         color: AppColors.textSecondary
//                                             .withOpacity(0.8),
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.w800,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               step['title'] as String,
//                               style: TextStyle(
//                                 color: done
//                                     ? AppColors.primary
//                                     : AppColors.textSecondary.withOpacity(0.75),
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ),
//                           Icon(
//                             step['icon'] as IconData,
//                             size: 16,
//                             color: done
//                                 ? AppColors.primary
//                                 : AppColors.textSecondary.withOpacity(0.5),
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//               const Spacer(),
//               SizedBox(
//                 width: double.infinity,
//                 height: 54,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(18),
//                     ),
//                   ),
//                   onPressed: onBackHome,
//                   child: const Text(
//                     'Back to Home',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _EqualStepItem extends StatelessWidget {
//   final int index;
//   final int currentStep;
//   final String title;
//   final bool isLast;

//   const _EqualStepItem({
//     required this.index,
//     required this.currentStep,
//     required this.title,
//     this.isLast = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bool isCompleted = index < currentStep;
//     final bool isActive = index == currentStep;

//     final Color activeGreen = const Color(0xFF10B981);
//     final Color pendingPurple = const Color(0xFF6E68B6);
//     final Color inactiveLine = AppColors.secondary.withOpacity(0.8);

//     final Color circleColor = isCompleted
//         ? activeGreen
//         : isActive
//             ? pendingPurple
//             : AppColors.secondary.withOpacity(0.75);

//     final Color labelColor = isCompleted
//         ? activeGreen
//         : isActive
//             ? pendingPurple
//             : AppColors.textSecondary.withOpacity(0.75);

//     return Column(
//       children: [
//         SizedBox(
//           height: 34,
//           child: Row(
//             children: [
//               if (index != 0)
//                 Expanded(
//                   child: Container(
//                     height: 3,
//                     color: index < currentStep ? activeGreen : inactiveLine,
//                   ),
//                 )
//               else
//                 const Expanded(child: SizedBox()),
//               Container(
//                 height: 34,
//                 width: 34,
//                 decoration: BoxDecoration(
//                   color: circleColor,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: isCompleted
//                       ? const Icon(
//                           Icons.check,
//                           color: Colors.white,
//                           size: 18,
//                         )
//                       : Text(
//                           '${index + 1}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w800,
//                             fontSize: 14,
//                           ),
//                         ),
//                 ),
//               ),
//               if (!isLast)
//                 Expanded(
//                   child: Container(
//                     height: 3,
//                     color:
//                         index < currentStep - 1 ? activeGreen : inactiveLine,
//                   ),
//                 )
//               else
//                 const Expanded(child: SizedBox()),
//             ],
//           ),
//         ),
//         const SizedBox(height: 10),
//         Text(
//           title,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: labelColor,
//             fontSize: 11,
//             fontWeight: FontWeight.w800,
//             height: 1.25,
//           ),
//         ),
//       ],
//     );
//   }
// }