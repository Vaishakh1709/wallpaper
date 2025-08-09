//
//  LoginViewController.swift
//  WallpaperDownloader
//
//  Created by Vaishakh V on 21/07/25.
//

import Foundation
import UIKit



class LoginViewController: UIViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    @IBAction func loginButtonAction(_ sender: Any) {
        
        if username.text == "admin" && password.text == "admin" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            
            let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)

            
        }
    }
    
}
