//
//  SignUpViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/7.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    let userIcon = UIImage(systemName: "person.crop.circle")
    let emailIcon = UIImage(systemName: "envelope.circle")
    let passwordIcon = UIImage(systemName: "lock.circle")

    @IBOutlet var usernameTextField: UITextField! {
        didSet {
            usernameTextField.tintColor = UIColor.lightGray
            usernameTextField.setIcon(userIcon!)
        }
    }
    @IBOutlet var NUSEmailTextField: UITextField! {
        didSet {
            NUSEmailTextField.tintColor = UIColor.lightGray
            NUSEmailTextField.setIcon(emailIcon!)
        }
    }
    @IBOutlet var passwordTextField: UITextField! {
        didSet {
            passwordTextField.tintColor = UIColor.lightGray
            passwordTextField.setIcon(passwordIcon!)
        }
    }
    @IBOutlet var confirmPasswordTextField: UITextField! {
        didSet {
            confirmPasswordTextField.tintColor = UIColor.lightGray
            confirmPasswordTextField.setIcon(passwordIcon!)
        }
    }
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    func setUpElements() {
        errorLabel.alpha = 0.0
    }
    
    func validateFields() -> String? {
        
        // try guard let or if let syntax later
        if usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please enter your username."
        }
        
        if NUSEmailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please enter your NUS email."
        }
        
        let cleanNUSEmail = NUSEmailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        if !Utilities.isNUSEmailValid(cleanNUSEmail) {
            return "Please enter your NUS email ending in @u.nus.edu or @nus.edu.sg. For default NUS email, please follow the format of e1234567@u.nus.edu."
        }
        
        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please enter your password."
        }
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please confirm your password."
        }
        let confirmedPassword = confirmPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if confirmedPassword != password {
            return "Confirmed password does not match."
        }
        
        return nil
    }
    
    func showError(_ errorMessage: String) {
        errorLabel.numberOfLines = 0
        errorLabel.text = errorMessage
        errorLabel.alpha = 1.0
    }
    
    func transitionToHomepage() {
            let customTabBarController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.customTabBarController) as? CustomTabBarController
            view.window?.rootViewController = customTabBarController
            view.window?.makeKeyAndVisible()
        }

    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        // validate the fields
        let error = validateFields()
        
        if error != nil {
            // show error message
            showError(error!)
        } else {
            // create cleaned version of data
            let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let NUSEmail = NUSEmailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // create user
            Auth.auth().createUser(withEmail: NUSEmail, password: password) { authResult, error in
                // check for error
                if error != nil {
                    // There is a error
                    // error.localizedDescription
                    self.showError("Error creating user: \(String(describing: error?.localizedDescription))")
                } else {
                    // User is created successfully
                    let db = Firestore.firestore()
                    let newUser = User(uuid: authResult!.user.uid, username: username, email: NUSEmail, password: password, myActivityIds: [], joinedActivityIds: [])
                    let newUserDictionary = User.UserToDictionary(user: newUser)
                    print("(print from sign up vc) user dictionary \(newUserDictionary)")
                    db.collection("users").document("user-\(authResult!.user.uid)").setData(newUserDictionary) {(error) in
                        if error != nil {
                            // user account is created but cannot be saved
                            self.showError("Username cannot be saved in database side")
        
                            // other option: try save again later, ask for username again
                        } else {
                            print("(print from sign up vc) add user successfully \(newUser)")
                            // transition to home
                            self.transitionToHomepage()
                        }
                    }
//                    // transition to home
//                    self.transitionToHomepage()
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
