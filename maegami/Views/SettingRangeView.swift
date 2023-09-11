import SwiftUI
import AVFoundation

struct SettingRangeView: View {
    @State private var profileUrlRange: String = ""
    @State private var attendanceRange: String = ""
    @State private var showErrorProfileRange: Bool = false
    @State private var showErrorAttendanceRange: Bool = false
    @State private var showScannerView: Bool = false
    @StateObject private var spreadSheetController = SpreadSheetController()
    
    var body: some View {
        VStack {
            Image("test_image")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            Text("プロフィールURLを記載した列")
            TextField("", text: $profileUrlRange)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
                .background(
                    VStack(alignment: .leading) {
                        if showErrorProfileRange {
                            Text("必須項目です。")
                                .font(.caption)
                                .foregroundColor(.red)
                        } else if !isValidAlphanumeric(profileUrlRange) {
                            Text("半角英字で入力してください。")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                )
            
            Text("出欠を自動入力する列")
            TextField("", text: $attendanceRange)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
                .background(
                    VStack(alignment: .leading) {
                        if showErrorAttendanceRange {
                            Text("必須項目です。")
                                .font(.caption)
                                .foregroundColor(.red)
                        } else if !isValidAlphanumeric(attendanceRange) {
                            Text("半角英字で入力してください。")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                )
            
                Button("次へ") {
                    if profileUrlRange.isEmpty {
                        showErrorProfileRange = true
                    } else {
                        showErrorProfileRange = !isValidAlphanumeric(profileUrlRange)
                    }
                    
                    if attendanceRange.isEmpty {
                        showErrorAttendanceRange = true
                    } else {
                        showErrorAttendanceRange = !isValidAlphanumeric(attendanceRange)
                    }
                    
                    if !showErrorProfileRange && !showErrorAttendanceRange {
                        showScannerView = true
                    }
                }
                .frame(width: 150, height: 44)
                .background(Color.blue)
                .foregroundColor(.white)
            
                .padding()
                .background(
                    NavigationLink(
                        destination: ScannerView(),
                        isActive: $showScannerView,
                        label: { EmptyView() }
                    )
                )
        }
    }
    
    struct SettingRangeView_Previews: PreviewProvider {
        static var previews: some View {
            SettingRangeView()
        }
    }
    
}

func isValidAlphanumeric(_ text: String) -> Bool {
    let pattern = "^[a-zA-Z]+$"
    return text.range(of: pattern, options: .regularExpression) != nil
}
