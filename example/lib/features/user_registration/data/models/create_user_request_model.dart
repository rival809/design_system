/// Request payload for POST /users/add.
class CreateUserRequestModel {
  const CreateUserRequestModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.birthDate,
    required this.department,
    required this.companyName,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String gender;
  final String birthDate;
  final String department;
  final String companyName;

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'gender': gender,
    'birthDate': birthDate,
    'company': {'department': department, 'name': companyName},
  };
}
