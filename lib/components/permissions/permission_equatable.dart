import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  final String lastname;

  Person({required this.name, required this.lastname});

  @override
  List<Object?> get props => [name, lastname];

}
