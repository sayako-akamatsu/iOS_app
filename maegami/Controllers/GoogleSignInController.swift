import GoogleSignIn

class GoogleSignInController: NSObject, GIDSignInDelegate {
    private let clientID = "172373643190-6vba3arlgb1cftgeei5fnkvn5p0e1res.apps.googleusercontent.com"
    private var accessToken = ""
    private var signInTimer: Timer?

    // 初期化
    override init() {
        super.init()
        
        GIDSignIn.sharedInstance().clientID = clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().presentingViewController = UIApplication.shared.windows.first?.rootViewController
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/spreadsheets"]
    }
    
    // ログイン成功時の処理
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print("Google認証エラー: \(error.localizedDescription)")
            // 認証エラー時の処理を追加
            return
        }

        if let authentication = user.authentication {
            print("Google認証成功")
            self.accessToken = authentication.accessToken

            // タイムアウト処理
            signInTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: false) { [weak self] _ in
                self?.signOut() // 60分後にログアウト
            }
        }
    }

    // 認証フローの開始
    func signIn() {
        if GIDSignIn.sharedInstance().currentUser == nil {
            GIDSignIn.sharedInstance()?.signIn()
        }
    }

    // 認証フローの終了
    func signOut() {
        GIDSignIn.sharedInstance()?.signOut()
        // タイマーを停止する
        signInTimer?.invalidate()
        signInTimer = nil
    }
    
    // accessTokenを取得するメソッド
    func getAccessToken() -> String {
        return accessToken
        
    }
}
