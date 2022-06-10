import SwiftUI

struct TodoList: View {

    @EnvironmentObject var todoMgr: TodoMgr

    var body: some View {
        List {
            ForEach(todoMgr.todos) { todo in
                NavigationLink(destination: TodoEdit(todo: todo),
                               label: { TodoRow(todo: todo) })
            }
              .onDelete(perform: todoMgr.delete)
              .onMove(perform: todoMgr.move)
        }
          .navigationTitle("Todo List")
          .listStyle(PlainListStyle())
          .toolbar {
              ToolbarItem(placement: .navigation) {
                  EditButton()
              }
              ToolbarItem(placement: .primaryAction) {
                  NavigationLink("Add", destination: Text("Destination"))
              }
          }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TodoList()
        }.environmentObject(TodoMgr())
    }
}
