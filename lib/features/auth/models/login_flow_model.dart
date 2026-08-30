// enum LoginFlow {
//   otp,
//   password,
//   register,
// }

// class LoginFlowModel {
//   final LoginFlow next;

//   final String? message;

//   const LoginFlowModel({
//     required this.next,
//     this.message,
//   });

//   factory LoginFlowModel.fromJson(Map<String, dynamic> json) {
//     final value = json['next']?.toString().toLowerCase();

//     switch (value) {
//       case 'password':
//         return LoginFlowModel(
//           next: LoginFlow.password,
//           message: json['message']?.toString(),
//         );

//       case 'register':
//         return LoginFlowModel(
//           next: LoginFlow.register,
//           message: json['message']?.toString(),
//         );

//       default:
//         return LoginFlowModel(
//           next: LoginFlow.otp,
//           message: json['message']?.toString(),
//         );
//     }
//   }
// }
