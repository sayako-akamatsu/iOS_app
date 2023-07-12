import Foundation
import UIKit
import GoogleSignIn

@MainActor
class SpreadSheetController: NSObject, ObservableObject, GIDSignInDelegate {
    // 定数
    private let apiKey = "AIzaSyD60AqaJKi74U52jQgiA1MNevYA19ltC4s"
    private let baseURL = "https://sheets.googleapis.com/v4/spreadsheets"
    
    // 変数
    private var sheetName = ""
    private var cellRange = ""
    private var enterCellRange = ""
    private var spreadsheetId = ""
    private var accessToken = ""
    // バリデーションエラー
    @Published private(set) var validationError = false
    @Published private(set) var validationNullError = false
    @Published private(set) var validationExistError = false
    @Published private(set) var validationHalfSizeError = false
    
    @Published private(set) var googleSuccess = false
    @Published private(set) var matchSuccessAlert = false
    @Published private(set) var apiSuccess = false
    @Published private(set) var spreadSheetResponse = SpreadSheetResponse(range: "", majorDimension: "", values: [[""]])
    
    // バリデーションチェック
    func setValues(URL url:String,Sheet sheet:String ,URLRange urlRange:String ,AttendanceRange attendanceRange:String) throws {
        // 初期化
        validationError = false
        validationNullError = false
        validationExistError = false
        validationHalfSizeError = false
        if url == "" || sheet == "" || urlRange == "" || attendanceRange == "" {
            validationError = true
            validationNullError = true
            return
        }
        guard let spreadsheetId = extractSpreadsheetId(from: url) else {
            // エラーフラグを立てて処理を終了させる
            validationError = true
            validationExistError = true
            return
        }
        // urlRangeが半角英字でない場合にエラーフラグを立てる
            let urlRangeRegex = try! NSRegularExpression(pattern: "^[A-Za-z]+$")
            let urlRangeRange = NSRange(location: 0, length: urlRange.utf16.count)
            if urlRangeRegex.firstMatch(in: urlRange, options: [], range: urlRangeRange) == nil {
                // エラーフラグを立てて処理を終了させる
                validationError = true
                validationHalfSizeError = true
                return
            }
        // attendanceRangeが半角英字でない場合にエラーフラグを立てる
        let attendanceRangeRegex = try! NSRegularExpression(pattern: "^[A-Za-z]+$")
        let attendanceRangeRange = NSRange(location: 0, length: attendanceRange.utf16.count)
        if attendanceRangeRegex.firstMatch(in: attendanceRange, options: [], range: attendanceRangeRange) == nil {
            // エラーフラグを立てて処理を終了させる
            validationError = true
            validationHalfSizeError = true
            return
        }
        self.spreadsheetId = spreadsheetId
        self.sheetName = sheet
        self.cellRange = "\(urlRange):\(urlRange)"
        self.enterCellRange = attendanceRange
        
    }
    
    override init() {
        super.init()
        // GoogleSignInの設定
        GIDSignIn.sharedInstance().clientID = "172373643190-6vba3arlgb1cftgeei5fnkvn5p0e1res.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().presentingViewController = UIApplication.shared.windows.first?.rootViewController
        GIDSignIn.sharedInstance()?.scopes = ["https://www.googleapis.com/auth/spreadsheets"]
    }
    
    // 認証フローの開始
    func signIn() async {
        //        if !GIDSignIn.sharedInstance().hasPreviousSignIn() && googleConnect {
        GIDSignIn.sharedInstance()?.signIn()
//    }
    }
    
    // 認証フローの終了
    func signOut() {
        GIDSignIn.sharedInstance()?.signOut()
    }
    
    // GoogleSignInDelegateのメソッド
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?){
        if let error = error {
            print("Google認証エラー: \(error.localizedDescription)")
            self.googleSuccess = false
            return
        }
        
        // アクセストークンの取得とQRコードの表示
        if let authentication = user.authentication {
            print("Google認証成功")
            self.accessToken = authentication.accessToken
            self.googleSuccess = true
            return
        }
    }
    
    // GoogleSheet疎通確認
    @MainActor
    func connectGoogleSheet(fromURL url: String) async throws {
        guard let spreadsheetId = extractSpreadsheetId(from: url) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        self.spreadsheetId = spreadsheetId
        let reqURL = "\(self.baseURL)/\(spreadsheetId)/values/\(sheetName)!\(cellRange)?key=\(apiKey)"
        
        guard let requestURL = URL(string: reqURL) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        
        let (data, _) = try await URLSession.shared.data(from: requestURL)
        let decoder = JSONDecoder()
        let spreadSheetResponse = try decoder.decode(SpreadSheetResponse.self, from: data)
        self.spreadSheetResponse = spreadSheetResponse
        self.apiSuccess = true
        print("apiSuccess:",apiSuccess)
    }
    
    // QR読み取りURLの確認
    func fetchProfileURL(forURL url: String) async {
        guard let requestURL = URL(string: url) else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: requestURL)
            
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                
                if statusCode == 200 {
                    if let statusUrl = httpResponse.url?.absoluteString {
                        await fetchGoogleSheetData(profileURL: statusUrl)
                    }
                } else {
                    print("HTTP Status Code: \(statusCode)")
                    // 200以外のステータスコードの場合の処理を記述する
                }
            }
        } catch {
            print("Error: (error)")
        }
    }
    // GoogleSheetData取得一致確認
    func fetchGoogleSheetData(profileURL: String) async {
        for (rowIndex, row) in self.spreadSheetResponse.values.enumerated() {
            for (cellIndex, cell) in row.enumerated() {
                if cell == profileURL {
                    let adjacentCellRange = "\(enterCellRange)\(rowIndex + 1)"
                    do {
                        try await updateCellValue(sheetId: spreadsheetId, cellRange: adjacentCellRange, newValue: "○")
                        self.matchSuccessAlert = true // 一致した場合にtrueに設定
                    } catch {
                        print("Error updating cell value: \(error)")
                    }
                    return
                }
            }
        }
    }
    func updateCellValue(sheetId: String, cellRange: String, newValue: String) async throws {
        let reqURL = "\(self.baseURL)/\(sheetId)/values/\(cellRange)?valueInputOption=USER_ENTERED"
        
        guard let url = URL(string: reqURL) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }

        var request = URLRequest(url: url)
        // リクエストヘッダーを設定する
        request.httpMethod = "PUT"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // リクエストボディを設定する
        let requestBody = "{\"values\":[[\"○\"]]}".data(using: .utf8)
        request.httpBody = requestBody
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                let responseString = String(data: data, encoding: .utf8)
                print("Response: \(responseString)")
                self.matchSuccessAlert = true
                return
            }
        }
        task.resume()
    }
}

private func extractSpreadsheetId(from url: String) -> String? {
    let urlComponents = url.components(separatedBy: "/")
    
    if urlComponents.count > 5 {
        return urlComponents[5]
    }
    
    return nil
}

struct SpreadSheetResponse: Codable {
    let range: String
    let majorDimension: String
    let values: [[String]]
}
