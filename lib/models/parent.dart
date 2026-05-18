import 'child.dart';

class Parent extends Child {
  
   String? firstName;
     String? lastName;
     String? email;


  List<Child> children = [];
  Child? currentChild;

  Parent({
    required super.id, 
    required super.name, 
    required super.login, 
    required super.password, 
    required super.passwordraw, 
    required super.level, 
    required super.codeparent,
    required this.children, 
    
    });
  
  void setParentAsChild(Child child) {
    currentChild = child;
  }

  static Parent copy(Parent parent) {
    List<Child> tmp = [];
    for (var element in parent.children) {
      tmp.add(Child.copy(element));
    }
    return Parent(id: parent.id, name: parent.name, login: parent.login, 
                  password: parent.password,passwordraw: parent.passwordraw, children: tmp, 
                  level:parent.level, codeparent:parent.codeparent);
  }
}