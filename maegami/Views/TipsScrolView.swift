import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 0) {
                // 1つ目のコンテンツ画面
                Color.red
                    .frame(width: UIScreen.main.bounds.width)
                
                // 2つ目のコンテンツ画面
                Color.blue
                    .frame(width: UIScreen.main.bounds.width)
                
                // 3つ目のコンテンツ画面
                Color.green
                    .frame(width: UIScreen.main.bounds.width)
                
                // 4つ目のコンテンツ画面
                Color.orange
                    .frame(width: UIScreen.main.bounds.width)
                
                // 5つ目のコンテンツ画面
                Color.purple
                    .frame(width: UIScreen.main.bounds.width)
            }
        }
        .frame(height: 200) // スクロールビューの高さを設定
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
