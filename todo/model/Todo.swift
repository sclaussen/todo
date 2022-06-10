import Foundation

class TodoMgr: ObservableObject {

    @Published var todos: [Todo] = []

    init() {
        todos.append(Todo(name: "item 1", completed: false, priority: "P1"))
        todos.append(Todo(name: "item 2", completed: false, priority: "P1"))
        todos.append(Todo(name: "item 3", completed: false, priority: "P1"))
    }

    func update(todo: Todo) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index] = todo.update(todo: todo)
        }
    }

    func move(from: IndexSet, to: Int) {
        todos.move(fromOffsets: from, toOffset: to)
    }

    func delete(indexSet: IndexSet) {
        todos.remove(atOffsets: indexSet)
    }
}

struct Todo: Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var completed: Bool
    var priority: String
    
    init(id: String = UUID().uuidString, name: String, completed: Bool, priority: String) {
        self.id = id
        self.name = name
        self.completed = completed
        self.priority = priority
    }

    func update(todo: Todo) -> Todo {
        return Todo(id: todo.id, name: todo.name, completed: todo.completed, priority: todo.priority)
    }
}
