//import SwiftUI
//
//struct ContentView: View {
//    @State private var url: String = ""
//    @State private var sheet: String = ""
//    @State private var urlRange: String = ""
//    @State private var attendanceRange: String = ""
//    
//    @State private var showErrorNull: Bool = false
//    @State private var showErrorExist: Bool = false
//    @State private var showErrorHarfSize: Bool = false
//    
//    @State private var connectError: Bool = false
//    @State private var googleError: Bool = false
//    @State private var connectFail: Bool = false
//    @State private var showMatchAlert: Bool = false
//    @StateObject private var spreadSheetController = SpreadSheetController()
//
//    var body: some View {
//        VStack {
//            Text("設定ボタンを押すとGoogleアカウントへのサインイン処理が行われた後、カメラが起動します。")
//                .multilineTextAlignment(.leading)
//            TextField("スプレッドシートのURLを入力してください", text: $url)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//            TextField("スプレッドシートのシート名を入力してください", text: $sheet)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//            TextField("URLを記載した列名を入力してください", text: $urlRange)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//            Text("例)A列の場合：A")
//                .multilineTextAlignment(.leading)
//                .frame(maxWidth: .infinity, alignment: .leading)
//            TextField("出欠を記載した列名を入力してください", text: $attendanceRange)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//            Text("例)B列の場合：B")
//                .multilineTextAlignment(.leading)
//                .frame(maxWidth: .infinity, alignment: .leading)
//            
//            Button("設定") {
//                // QRコードリーダーを開く処理
//                do {
//                    // 初期化
//                    showErrorNull = false
//                    showErrorExist = false
//                    showErrorHarfSize = false
//                    connectError = false
//                    googleError = false
//                    connectFail = false
//                    showMatchAlert = false
////                    try spreadSheetController.setValues(URL:url,Sheet:sheet,URLRange:urlRange,AttendanceRange:attendanceRange)
//                } catch {
//                    print("エラーが発生しました: \(error)")
//                }
//                
//                // バリデーション
////                if spreadSheetController.validationError {
//                    // 初期化
//                    showErrorNull = false
//                    showErrorExist = false
//                    showErrorHarfSize = false
////                    if spreadSheetController.validationNullError {
//                        showErrorNull = true
//                    }
////                    if spreadSheetController.validationExistError {
//                        showErrorExist = true
//                    }
//                    if spreadSheetController.validationHalfSizeError {
//                        showErrorHarfSize = true
//                    }
//                } else {
//                    // 初期化
//                    showErrorNull = false
//                    showErrorExist = false
//                    showErrorHarfSize = false
//                    Task {
//                        await apiConnection()
//                    }
//                }
//            }
//            Text("Googleアカウントへのサインイン時に「このアプリはGoogleで確認されていません」といった警告が出ますが、アカウント情報は本アプリ以外では使用しません。サインインを継続する場合は左下の「詳細」をタップした後、「参加者チェッカー（安全ではないページ）に移動」をタップしてください。")
//                .multilineTextAlignment(.leading)
//                .frame(maxWidth: .infinity, alignment: .leading)
//            .padding()
//            
//            if showErrorHarfSize || showErrorNull || showErrorExist || googleError || connectError {
//                VStack {
//                    if showErrorHarfSize {
//                        Text("列名は半角英字で入力してください")
//                            .foregroundColor(.red)
//                    }
//                    if showErrorNull {
//                        Text("入力必須です")
//                            .foregroundColor(.red)
//                    }
//                    if showErrorExist {
//                        Text("URLが間違っています")
//                            .foregroundColor(.red)
//                    }
//                    if googleError {
//                        Text("Google認証に失敗しました")
//                            .foregroundColor(.red)
//                    }
//                    if connectError {
//                        Text("接続に失敗しました。入力値を見直してください")
//                            .foregroundColor(.red)
//                    }
//                }
//            }
//        }
//        .alert(isPresented: $showMatchAlert) {
//            Alert(
//                title: Text(""),
//                message: Text("参加確認ができました"),
//                dismissButton: .default(Text("OK"))
//            )
//        }
//    }
//
//    func apiConnection () async {
//        do {
//            try await spreadSheetController.signIn()
//            do {
//                try await spreadSheetController.connectGoogleSheet(fromURL: url)
//                if spreadSheetController.apiSuccess {
//                    print("API連携成功")
//                    await openQRCodeReader()
//                } else {
//                    print("API連携失敗")
//                    connectFail = true
//                    print(connectFail)
//                }
//            } catch {
//                connectError = true
//                print("API連携エラー: \(error)")
//            }
//        } catch {
//            print("Google認証エラー: \(error)")
//        }
//    }
//
//    func openQRCodeReader() async {
//        print("QR処理開始")
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let window = windowScene.windows.first {
//            let scannerViewController = ScannerViewController { result in
//                Task {
//                    // QRコードを読み取った後の処理
//                    await spreadSheetController.fetchProfileURL(forURL: result)
//                    if spreadSheetController.matchSuccessAlert {
//                        showMatchAlert = true
//                    }
//                    print("showMatchAlert",showMatchAlert)
//                }
//            }
//            window.rootViewController?.present(scannerViewController, animated: true, completion: nil)
//        }
//    }
//
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
