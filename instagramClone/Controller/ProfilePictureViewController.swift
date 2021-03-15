//
//  ProfilePictureViewController.swift
//  instagramClone
//
//  Created by Richard Basdeo on 3/15/21.
//

import UIKit
import Parse
import AlamofireImage

class ProfilePictureViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate{

    @IBOutlet weak var userImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let user = PFUser.current() {
            
            if let imageFile = user["profilePicture"] as? PFFileObject {
                
                if let urlString = imageFile.url {
                    
                    if let theURL = URL(string: urlString){
                    
                    userImage.af.setImage(withURL: theURL)
                    
                }
                
            }
            
        }
    }
}
    
    @IBAction func userTapImage(_ sender: UITapGestureRecognizer) {
        
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.editedImage] as! UIImage
        
        //need to resize image becuase it is large wont upload
        let size = CGSize(width: 300, height: 300)
        
        //create new smaller image
        let scaledImage = image.af.imageScaled(to: size)
        userImage.image = scaledImage
        
        //dismiss picker
        dismiss(animated: true, completion: nil)
    }

    
    
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        
        let user = PFUser.current()
        
        let imageData = userImage.image!.pngData()
        let file = PFFileObject(name: "image.png", data: imageData!)
        
        
        user!["profilePicture"] = file
        
        user!.saveInBackground { (success, error) in
            
            if success {
                print ("Profile Image Saved!")
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                }
            }
            else {
                print ("There was an error saving profile image.")
            }
        }
    }
}
