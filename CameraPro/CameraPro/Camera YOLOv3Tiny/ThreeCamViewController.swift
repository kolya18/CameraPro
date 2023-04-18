//
//  ThreeCamViewController.swift
//  CameraPro
//
//  Created by Николай Мартынов on 08.07.2021.
//

import UIKit
import CoreML
import Vision

class ThreeCamViewController: UIViewController {
    

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var boundingBoxView: BoundingBoxView!

    //указать свойства зрения
    var visionModel: VNCoreMLModel?
    var request: VNCoreMLRequest?
    var isInferencing = false
    let objectDetectionModel = YOLOv3Tiny()
  //  let objectDetectionModel = YOLOv3()
    
    
    //свойства захвата видео
    var videoCapture: VideoCapture!
    let semaphore = DispatchSemaphore(value: 1)
    var lastExecution = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupModelAndRequest()
        setupVideoPreview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoCapture.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoCapture.stop()
    }

    func setupModelAndRequest() {
        if let model = try? VNCoreMLModel(for: objectDetectionModel.model) {
            visionModel = model

            //setup request only once and run it multiple times
            request = VNCoreMLRequest(model: visionModel!, completionHandler: { (request, error) in
                if let predictions = request.results as? [VNRecognizedObjectObservation] {
                    DispatchQueue.main.async {
                        self.boundingBoxView.predictedObjects = predictions
                        self.isInferencing = false
                    }
                } else {
                    self.isInferencing = false
                }

                self.semaphore.signal()
            })

            request?.imageCropAndScaleOption = .scaleFill
        } else {
            fatalError("Failed to create vision model and request")
        }
    }

    func runRequest(pixelBuffer: CVPixelBuffer) {
        guard let request = self.request else { fatalError("No request") }
        self.semaphore.wait()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)

        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform request")
        }
    }

    func setupVideoPreview() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 30

        videoCapture.setUp(sessionPreset: .inputPriority) { success in

            if success {
                // добавить предварительный просмотр на слой
                if let previewLayer = self.videoCapture.previewLayer {
                    self.previewView.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }

                // запускать предварительный просмотр видео после завершения настройки
                self.videoCapture.start()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }

    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = previewView.bounds
    }
}

extension ThreeCamViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        if !self.isInferencing, let pixelBuffer = pixelBuffer {
            self.isInferencing = true
            self.runRequest(pixelBuffer: pixelBuffer)
        }
    }
}

