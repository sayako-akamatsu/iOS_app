import SwiftUI

struct GoogleSignIn: View {
    @StateObject private var spreadSheetController = SpreadSheetController()
    @State private var isSettingSpreadSheetViewActive = false // 画面遷移の状態を管理するフラグ
    
    var body: some View {
        VStack {
            Image("test_image")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            Image("test_image")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            
            // 隠しのNavigationLink
            NavigationLink(
                destination: SettingSpreadSheetView(),
                isActive: $isSettingSpreadSheetViewActive,
                label: {
                    EmptyView() // 何も表示しない
                })
                .hidden() // 隠す
            
            Button("Google認証") {
                spreadSheetController.signIn()
                isSettingSpreadSheetViewActive = true // 画面遷移のフラグをtrueにすることでNavigationLinkがアクティベートされる
            }
            .frame(width: 150, height: 44)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            GoogleSignIn()
        }
    }
}
