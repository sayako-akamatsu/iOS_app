import SwiftUI

struct TipsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image("test_image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 20)
                
                Text("インストールありがとうございます")
                    .font(.headline)
                    .padding(.bottom, 10)
                
                Text("本アプリの簡単な使い方をご説明します。")
                    .padding(.bottom, 10)
                
                Text("説明後すぐにアプリをお使いいただけます。")
                    .padding(.bottom, 20)
                
                HStack {
                    NavigationLink(destination: GoogleSignIn()) {
                        Text("説明をスキップ")
                            .frame(width: 150, height: 44)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: TipsScrollView()) {
                        Text("次へ")
                            .frame(width: 150, height: 44)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // For better display on smaller devices
    }
}

struct TipsView_Previews: PreviewProvider {
    static var previews: some View {
        TipsView()
    }
}
