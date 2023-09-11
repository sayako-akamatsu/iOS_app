import SwiftUI
import AVFoundation

struct ScannerView: View {
    @State private var scannedCode: String? = nil
    @State private var isSettingViewActive = false
    
    var body: some View {
        ZStack {
            ScannerViewUI(scannedCode: $scannedCode)
            
            if let code = scannedCode {
                Text("Scanned Code: \(code)")
                    .background(Color.white)
                    .frame(width: 200, height: 200) 
                    .padding()
                    .cornerRadius(10)
                    .onTapGesture {
                        scannedCode = nil
                    }
            }
            
            VStack {
                Spacer()
                Button("設定画面にもどる") {
                    scannedCode = nil
                    isSettingViewActive = true
                }
                .padding()
                .sheet(isPresented: $isSettingViewActive) {
                    NavigationView {
                        SettingRangeView()
                    }
                }
            }
        }
        .onAppear {
            checkCameraAuthorization()
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func checkCameraAuthorization() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            // カメラの許可状態をチェックする処理
        }
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView()
    }
}

struct ScannerViewUI: UIViewRepresentable {
    @Binding var scannedCode: String?
    
    func makeUIView(context: Context) -> ScannerViewUIWrapper {
        return ScannerViewUIWrapper(scannedCode: $scannedCode)
    }
    
    func updateUIView(_ uiView: ScannerViewUIWrapper, context: Context) {
        // 更新処理
    }
}

class ScannerViewUIWrapper: UIView, AVCaptureMetadataOutputObjectsDelegate {
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    @Binding var scannedCode: String?
    
    init(scannedCode: Binding<String?>) {
        _scannedCode = scannedCode
        super.init(frame: .zero)
        setupCaptureSession()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = metadataObject.stringValue else {
            return
        }
        scannedCode = code
        print("Scanned Code: \(code)")
    }
}
