import SwiftUI

struct TodoEdit: View {

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var todoMgr: TodoMgr

    @State var todo: Todo

    var body: some View {
        TextField("Name", text: $todo.name)
        TextField("Priority", text: $todo.priority)
        Button("Save", action: {
            todoMgr.update(todo: todo)
                           self.presentationMode.wrappedValue.dismiss()
                       })
    }
}

//struct TodoEdit_Previews: PreviewProvider {
//    static var previews: some View {
//        TodoEdit(Todo(name: "Something", completed: false, priority: "P2"))
//    }
//}
