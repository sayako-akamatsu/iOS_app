import SwiftUI

struct TipsScrollView: View {
    @State private var currentPage = 0
    let pageCount = 5
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(0..<pageCount, id: \.self) { index in
                    VStack {
                        getPageContent(index: index)
                    }
                    .frame(width: UIScreen.main.bounds.width)
                }
            }
        }
        .frame(height: 200) // スクロールビューの高さを設定
        .offset(x: UIScreen.main.bounds.width * CGFloat(currentPage) * -1, y: 0)
        .animation(.easeInOut) // アニメーションtを追加
        .onAppear {
            UIScrollView.appearance().isPagingEnabled = true
        }
    }
    
    // ページごとのコンテンツを取得する関数
    private func getPageContent(index: Int) -> some View {
        switch index {
        case 0:
            return AnyView(
                VStack {
                    Image("test_image")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                    Image("test_image")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                    Text("お手持ちのGoogleアカウントにログインします。")
                }
            )
        case 1:
            return AnyView(
                VStack {
                    Image("test_image")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                    
                        Image("test_image")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                    Text("出欠管理を行うスプレッドシートのURLと")
                    Text("シート名を入力します。")
                    Text("リンクを知っている全員を編集者としてください。")
                }
            )
        case 2:
            return AnyView(
                VStack {
                    Image("test_image")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                    
                    Text("プロフィールのURLを記載した列と出欠を記載した列を入力します。")
                }
            )
        case 3:
            return AnyView(
                VStack {
                    Image("test_image")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                    Text("本アプリでQRコードを読み取ります。")
                }
            )
        case 4:
            return AnyView(
                VStack {
                    Image("test_image")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                    Text("スプレッドシートに出欠が記録されます。")
                                       
                    NavigationLink(destination: GoogleSignIn()) {
                        Text("アプリを始める")
                            .frame(width: 150, height: 44)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            )
        // 他のページも同様に定義
        default:
            return AnyView(
                Text("Default Content")
            )
        }
    }
}

struct TipsScrollView_Previews: PreviewProvider {
    static var previews: some View {
        TipsScrollView()
    }
}
