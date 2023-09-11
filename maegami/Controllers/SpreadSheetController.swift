import Foundation
import UIKit
import GoogleSignIn

@MainActor
class SpreadSheetController: NSObject, ObservableObject {
//    private let googleSignInController: GoogleSignInController // 依存性注入
//
//        init(googleSignInController: GoogleSignInController) {
//            self.googleSignInController = googleSignInController
//            super.init()
//        }
    // 定数
    private let apiKey = "AIzaSyD60AqaJKi74U52jQgiA1MNevYA19ltC4s"
    private let baseURL = "https://sheets.googleapis.com/v4/spreadsheets"
    private let googleSignInController = GoogleSignInController()
    
    // 変数
    private var sheetName = ""
    private var cellRange = ""
    private var enterCellRange = ""
    private var spreadsheetId = ""
    private var accessToken = ""
    private var signInTimer: Timer?
    // バリデーションエラー
    //@Published private(set) var validationError = false
    //@Published private(set) var validationNullError = false
    //@Published private(set) var validationExistError = false
    //@Published private(set) var validationHalfSizeError = false
    
    @Published private(set) var googleSuccess = false
    @Published private(set) var matchSuccessAlert = false
    @Published private(set) var connectSuccess = false
    @Published private(set) var spreadSheetResponse = SpreadSheetResponse(range: "", majorDimension: "", values: [[""]])
    

    func setSpredSheetValues(URL url:String,Sheet sheet:String) async throws {
        
        try await connectGoogleSheet(fromURL: url)
        if connectSuccess {
            print("API連携成功")
        } else {
            print("API連携失敗")
        }
        self.sheetName = sheet
        
    }
    func setRangeValues(URLRange profileUrlRange:String ,AttendanceRange attendanceRange:String) throws {
        
        self.cellRange = "\(profileUrlRange):\(profileUrlRange)"
        self.enterCellRange = attendanceRange
        
    }
    // 認証フローの開始
    func signIn() {
        googleSignInController.signIn()
        accessToken = googleSignInController.getAccessToken()
    }

    // 認証フローの終了
    func signOut() {
        googleSignInController.signOut()
    }
    
    @MainActor
    func connectGoogleSheet(fromURL url: String) async throws {
        print("url:",url)
        guard let spreadsheetId = extractSpreadsheetId(from: url) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        self.spreadsheetId = spreadsheetId
        print("spreadsheetId:",spreadsheetId)
        let reqURL = "\(self.baseURL)/\(spreadsheetId)/values/\(sheetName)?key=\(apiKey)"
        print("reqURL:",reqURL)
        guard let requestURL = URL(string: reqURL) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        print("reqURL:",requestURL)
        do {
            let (data, _) = try await URLSession.shared.data(from: requestURL)
            let decoder = JSONDecoder()
            let spreadSheetResponse = try decoder.decode(SpreadSheetResponse.self, from: data)
            print("spreadSheetResponse",spreadSheetResponse)
            self.spreadSheetResponse = spreadSheetResponse
            self.connectSuccess = true
            print("connectSuccess:",connectSuccess)
        } catch {
            print("APIエラー: \(error)")
            throw error
        }
    }

//
//    @MainActor
//    func connectGoogleSheet(fromURL url: String) async throws {
//        guard let spreadsheetId = extractSpreadsheetId(from: url) else {
//            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
//        }
//        self.spreadsheetId = spreadsheetId
//        let reqURL = "\(self.baseURL)/\(spreadsheetId)/values/\(sheetName)?key=\(apiKey)"
//        print(reqURL)
//        guard let requestURL = URL(string: reqURL) else {
//            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
//        }
//        let (data, _) = try await URLSession.shared.data(from: requestURL)
//        let decoder = JSONDecoder()
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print(jsonString)
//        }
//        let spreadSheetResponse = try decoder.decode(SpreadSheetResponse.self, from: data)
//        print("spreadSheetResponse",spreadSheetResponse)
//        self.spreadSheetResponse = spreadSheetResponse
//        self.connectSuccess = true
//        print("connectSuccess:",connectSuccess)
//    }
    
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
