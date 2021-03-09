//
//  ViewController.swift
//  instagramClone
//
//  Created by Richard Basdeo on 3/9/21.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        
        let username = userNameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            
            
            if error != nil {
                print ("There was a issue signing in: \(String(describing: error))")
            }
            
            else {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            
            
            
        }
        
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        let user = PFUser()
        user.username = userNameField.text
        user.password = passwordField.text
        
        user.signUpInBackground { (success, error) in
            
            if error != nil {
                print ("There was a issue signing up: \(String(describing: error))")
            }
            
            else {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
    }
}

