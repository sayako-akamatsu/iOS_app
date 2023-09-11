import SwiftUI
import AVFoundation

struct ScannerView: View {
    @State private var scannedCode: String? = nil
    
    var body: some View {
        ZStack {
            ScannerViewUI(scannedCode: $scannedCode)
                .edgesIgnoringSafeArea(.all)
            
            if let code = scannedCode {
                Text("Scanned Code: \(code)")
                    .background(Color.white)
                    .padding()
                    .cornerRadius(10)
                    .onTapGesture {
                        scannedCode = nil
                    }
            }
        }
        .onAppear {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        scannedCode = "カメラのアクセスが許可されました"
                    } else {
                        scannedCode = "カメラのアクセスが拒否されました"
                    }
                }
            }
        }
    }
}

class ScannerViewUI: UIView, AVCaptureMetadataOutputObjectsDelegate {
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
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView()
    }
}
