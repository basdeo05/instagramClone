//
//  CameraViewController.swift
//  instagramClone
//
//  Created by Richard Basdeo on 3/9/21.
//

import UIKit
import AlamofireImage

class CameraViewController: UIViewController, UINavigationControllerDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func submitButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func userTappedImageGesture(_ sender: UITapGestureRecognizer) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        //used cause simulator does not have a camera
        //so just open the phot library
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        }
        else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
}

extension CameraViewController: UIImagePickerControllerDelegate {
    
    //Called when finish picking a image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.editedImage] as! UIImage
        
        //need to resize image becuase it is large wont upload
        let size = CGSize(width: 300, height: 300)
        
        //create new smaller image
        let scaledImage = image.af.imageScaled(to: size)
        imageView.image = scaledImage
        
        //dismiss picker
        dismiss(animated: true, completion: nil)
    }
    
}
