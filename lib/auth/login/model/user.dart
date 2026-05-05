class Loggedin {
  bool? success;
  String? message;
  String? token;
  User? user;

  Loggedin({this.success, this.message, this.token, this.user});

  Loggedin.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    token = json['token'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['message'] = message;
    data['token'] = token;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? gender;
  String? role;
  RoleApplication? roleApplication;
  String? profileImage;
  bool? isVerified;
  bool? isBlocked;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.gender,
    this.role,
    this.roleApplication,
    this.profileImage,
    this.isVerified,
    this.isBlocked,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['_id']; // backend sometimes sends _id
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    gender = json['gender'];
    role = json['role'];
    roleApplication = json['roleApplication'] != null
        ? RoleApplication.fromJson(json['roleApplication'])
        : null;
    profileImage = json['profileImage'];
    isVerified = json['isVerified'];
    isBlocked = json['isBlocked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['gender'] = gender;
    data['role'] = role;
    if (roleApplication != null) {
      data['roleApplication'] = roleApplication!.toJson();
    }
    data['profileImage'] = profileImage;
    data['isVerified'] = isVerified;
    data['isBlocked'] = isBlocked;
    return data;
  }
}

class RoleApplication {
  String? requestedRole;
  String? status;
  String? appliedAt;
  String? decidedAt;
  String? decidedBy;
  String? note;

  RoleApplication({
    this.requestedRole,
    this.status,
    this.appliedAt,
    this.decidedAt,
    this.decidedBy,
    this.note,
  });

  RoleApplication.fromJson(Map<String, dynamic> json) {
    requestedRole = json['requestedRole'];
    status = json['status'];
    appliedAt = json['appliedAt'];
    decidedAt = json['decidedAt'];
    decidedBy = json['decidedBy'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['requestedRole'] = requestedRole;
    data['status'] = status;
    data['appliedAt'] = appliedAt;
    data['decidedAt'] = decidedAt;
    data['decidedBy'] = decidedBy;
    data['note'] = note;
    return data;
  }
}