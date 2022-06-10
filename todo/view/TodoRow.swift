import SwiftUI

struct TodoRow: View {

    let todo: Todo

    var body: some View {
        HStack {
            Image(systemName: todo.completed ? "checkmark.circle" : "circle")
              .foregroundColor(todo.completed ? .green : .red)
            Text(todo.name).foregroundColor(.black)
            Text(todo.priority).foregroundColor(.black)
            Spacer()
        }
    }
}

struct TodoListRow_Previews: PreviewProvider {
    static var todo1 = Todo(name: "item 1", completed: false, priority: "1")
    static var todo2 = Todo(name: "item 2", completed: true, priority: "1")

    static var previews: some View {
        Group {
            TodoRow(todo: todo1)
            TodoRow(todo: todo2)
        }.previewLayout(.sizeThatFits)
    }
}
