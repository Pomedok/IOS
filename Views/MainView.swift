import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            CardsView()
                .tabItem {
                    Label("Tab.Cards", systemImage: "creditcard")
                }
            
            HistoryView()
                .tabItem {
                    Label("Tab.History", systemImage: "clock")
                }
            
            SettingsView()
                .tabItem {
                    Label("Tab.Settings", systemImage: "gear")
                }
        }
        .accentColor(Theme.primaryColor)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
