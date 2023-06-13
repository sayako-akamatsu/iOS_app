import SwiftUI
import AVFoundation
import CoreData

struct ContentView: View {
    @State private var url: String = ""
    @State private var showError: Bool = false
    
    var body: some View {
        VStack {
            Text("スプレッドシートのURLを入力してください")
            TextField("Enter URL", text: $url)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("QRコードを読み取る") {
                // QRコードリーダーを開く処理
                openQRCodeReader()
            }
            .padding()
            
            if showError {
                Text("URLを入力してください").foregroundColor(.red)
            }
        }
    }
    
    func openQRCodeReader() {
        
        if url.isEmpty{
            showError = true
        } else {
            showError = false
            
            // QRコードを読み取り画面遷移、値を取得する
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let scannerViewController = ScannerViewController { result in
                    // QRコードを読み取った後の処理
                    print(result)
                }
                
                window.rootViewController?.present(scannerViewController, animated: true, completion: nil)
            }
        }
    }
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
