import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedLanguage = "Українська"
    @State private var showLanguagePicker = false
    
    var body: some View {
        ZStack {
            Theme.backgroundColor
                .ignoresSafeArea()
            
            List {
                Section {
                    HStack {
                        Text("Settings.FirstName")
                        Spacer()
                        Text(appState.person?.firstName ?? "")
                            .foregroundColor(Theme.secondaryTextColor)
                    }
                    HStack {
                        Text("Settings.LastName")
                        Spacer()
                        Text(appState.person?.lastName ?? "")
                            .foregroundColor(Theme.secondaryTextColor)
                    }
                }
                
                Section {
                    Button(action: {
                        HapticFeedback.play(.light)
                        showLanguagePicker = true
                    }) {
                        HStack {
                            Text("Settings.Language")
                            Spacer()
                            Text(selectedLanguage)
                                .foregroundColor(Theme.secondaryTextColor)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        HapticFeedback.play(.light)
                        logout()
                    }) {
                        Text("Settings.Logout")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings.Title")
        }
        .actionSheet(isPresented: $showLanguagePicker) {
            ActionSheet(
                title: Text("Settings.ChooseLanguage"),
                buttons: [
                    .default(Text("English")) { selectedLanguage = "English" },
                    .default(Text("Українська")) { selectedLanguage = "Українська" },
                    .default(Text("Русский")) { selectedLanguage = "Русский" },
                    .cancel()
                ]
            )
        }
    }
    
    private func logout() {
        UserDefaultsManager.clearPhoneNumber()
        TokenManager.clearToken()
        appState.reset()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
                .environmentObject(AppState.shared)
        }
    }
}
