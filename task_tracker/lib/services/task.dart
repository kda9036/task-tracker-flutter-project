class Task {
  String name;
  DateTime? dueDate; // optional
  bool isDone;

  Task({required this.name, this.isDone = false, this.dueDate});

  void toggleDone() {
    isDone = !isDone;
  }

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        name: json["name"],
        isDone: json["isDone"],
        dueDate:
            json["dueDate"] != null ? DateTime.parse(json["dueDate"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "isDone": isDone,
        "dueDate": dueDate?.toIso8601String(),
      };
}
