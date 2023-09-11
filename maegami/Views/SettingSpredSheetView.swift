import SwiftUI

struct SettingSpreadSheetView: View {
    @State private var url: String = ""
    @State private var sheet: String = ""
    @State private var showErrorUrl: Bool = false
    @State private var showErrorSheet: Bool = false
    @State private var showRangeView: Bool = false
    @StateObject private var spreadSheetController = SpreadSheetController()
    
    var body: some View {
        VStack {
            Image("test_image")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            Text("スプレッドシートURL")
            TextField("", text: $url)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
            // backgroundじゃないかも
                .background(
                    VStack(alignment: .leading) {
                        if showErrorUrl && url.isEmpty {
                            Text("必須項目です")
                                .font(.caption)
                                .foregroundColor(.red)
                        } else if showErrorUrl && !isValidHalfWidth(url) {
                            Text("半角で入力してください")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                )
            Text("スプレッドシートシート名")
            TextField("", text: $sheet)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
                .background(
                    VStack(alignment: .leading) {
                        if showErrorSheet && sheet.isEmpty {
                            Text("必須項目です")
                                .font(.caption)
                                .foregroundColor(.red)
                        } else if showErrorSheet && sheet.count > 50 {
                            Text("50文字以下で入力してください")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                )
            
            Button("次へ") {
                showErrorUrl = url.isEmpty || !isValidHalfWidth(url)
                showErrorSheet = sheet.isEmpty || sheet.count > 50
                
                if !showErrorUrl && !showErrorSheet {
                    Task {
                        do {
                            try await spreadSheetController.setSpredSheetValues(URL: url, Sheet: sheet)
                            if spreadSheetController.connectSuccess {
                                showRangeView = true
                            } else {
                            }
                        } catch {
                            print("エラーが発生しました: \(error)")
                        }
                    }
                }
            }
            .frame(width: 150, height: 44)
            .background(Color.blue)
            .foregroundColor(.white)
            
            .padding()
            .background(
                NavigationLink(
                    destination: SettingRangeView(),
                    isActive: $showRangeView,
                    label: { EmptyView() }
                )
            )
        }
    }
    
    struct SettingSpreadSheetView_Previews: PreviewProvider {
        static var previews: some View {
            SettingSpreadSheetView()
        }
    }
}

func isValidHalfWidth(_ text: String) -> Bool {
    let pattern = "^[!-~]+$"
    return text.range(of: pattern, options: .regularExpression) != nil
}
