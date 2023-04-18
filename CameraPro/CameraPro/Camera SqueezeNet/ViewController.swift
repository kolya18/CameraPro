//
//  ViewController.swift
//  CameraPro
//
//  Created by Николай Мартынов on 06.07.2021.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{

    @IBOutlet weak var labelOut: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        setupIdentifierConfidenceLabel()
        
    }
    
    
    
    
    
    
    
    fileprivate func setupIdentifierConfidenceLabel() {
        view.addSubview(labelOut)
        labelOut.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        labelOut.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        labelOut.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        labelOut.heightAnchor.constraint(equalToConstant: 50).isActive = true
        

    }
    
    
    
    
    
    
    
    

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("Camera was able to capture a frame:", Date())

        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
     
        guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            //perhaps check the err
            
//            print(finishedReq.results)
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
            //print(firstObservation.identifier, firstObservation.confidence)
            
            DispatchQueue.main.async {
//              self.labelOut.text = "\(firstObservation.identifier) \(firstObservation.confidence)"
                self.labelOut.text = "\(firstObservation.identifier)"
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

    
}

