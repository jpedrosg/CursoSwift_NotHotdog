//
//  ViewController.swift
//  Not Hotdog
//
//  Created by João Pedro Giarrante on 17/11/20.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var imgCamera: UIImageView!
    
    let imgPicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgPicker.delegate = self
        imgPicker.allowsEditing = false
    }
    
    @IBAction func clickGalery(_ sender: UIBarButtonItem) {
        imgPicker.sourceType = .photoLibrary
        present(imgPicker, animated: true)
    }
    
    @IBAction func clickCamera(_ sender: UIBarButtonItem) {
        imgPicker.sourceType = .camera
        present(imgPicker, animated: true)
    }
    
    func detect(image: CIImage) {

        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: MLModelConfiguration()).model) else {
            fatalError("ViewController: Could not create CoreML Model")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("ViewController: Model failet to process image")
            }
            
            if let firstResult = results.first, firstResult.identifier.contains("hotdog") {
                self.navigationItem.title = "Hotdog!"
            } else {
                self.navigationItem.title = "Not Hotdog!"
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[.originalImage] as? UIImage {
            imgCamera.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("ViewController: Could not convert to CI Image")
            }
            
            detect(image: ciImage)
        }
        imgPicker.dismiss(animated: true)
    }
}
