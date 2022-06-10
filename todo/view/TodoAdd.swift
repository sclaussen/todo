import SwiftUI

struct TodoAdd: View {
    
    @State var text: String = ""
    
    var body: some View {
        ScrollView {
            VStack {
                TextField("Add a new todo", text: $text)
                Button(action: {
                    // action goes here
                }, label: {
                    Text("Save")
                })
            }
        }
        .navigationTitle("Todo Add")
    }
}

struct TodoAdd_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TodoAdd()
        }
    }
}
