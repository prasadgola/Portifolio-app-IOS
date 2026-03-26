import SwiftUI

@main
struct AgentShelfApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeScreen()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)

            VoiceChatScreen()
                .tabItem {
                    Image(systemName: "mic.fill")
                    Text("VoiceChat")
                }
                .tag(1)

            TextChatScreen()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("TextChat")
                }
                .tag(2)

            ReadTextScreen()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("ReadText")
                }
                .tag(3)
        }
        .tint(Color.amber)
    }
}

extension Color {
    static let amber = Color(red: 1.0, green: 0.757, blue: 0.027)
}
