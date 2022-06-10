import SwiftUI

@main
struct todoApp: App {
    @StateObject var todoMgr: TodoMgr = TodoMgr()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                TodoList()
            }
              .environmentObject(todoMgr)
        }
    }
}
