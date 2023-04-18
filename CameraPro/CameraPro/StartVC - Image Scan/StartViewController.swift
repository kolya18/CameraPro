//
//  StartViewController.swift
//  CameraPro
//
//  Created by Николай Мартынов on 07.07.2021.
//

import UIKit
import Vision
import AVFoundation

class StartViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelView: UILabel!
    
    @IBAction func buttonRealTime(_ sender: Any) {
        let newVC = storyboard?.instantiateViewController(withIdentifier: "viewControllerRealCam")
        navigationController?.pushViewController(newVC!, animated: true)
    }
        
    @IBAction func buttonCamThree(_ sender: Any) {
        let newVCcamThree = storyboard?.instantiateViewController(withIdentifier: "viewControllerThreeCam")
        navigationController?.pushViewController(newVCcamThree!, animated: true)
    }
    
        
    var model: Resnet50!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        model = Resnet50()
    }
    
    
    @IBAction func buttonSelectPhoto(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.photoLibrary) ? .photoLibrary : .camera
    
        present(picker, animated: true)
    }
    
    
    @IBAction func buttonTakePhoto(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
    
        present(picker, animated: true)
    }
    
    
    
}

extension StartViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        let (newImage, pixelBuffer) = ImageHelper.processImageData(capturedImage: image)
        imageView.image = newImage
        var imagePredictionText = "no idea... lol"
        guard let prediction = try? model.prediction(image: pixelBuffer!) else {
            labelView.text = imagePredictionText
            dismiss(animated: true, completion: nil)
            return
        }
        imagePredictionText = "\(prediction.classLabel)"
        labelView.text = imagePredictionText
        dismiss(animated: true, completion: nil)
    }
    
}
