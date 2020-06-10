//
//  ViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/5/30.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit
import Firebase

extension UITextField {
    func setIcon(_ image: UIImage) {
        let iconView = UIImageView(frame: CGRect(x: 10, y: 5, width: 20, height: 20))
        iconView.image = image
        
        let iconContainerView = UIView(frame: CGRect(x: 20, y: 0, width: 30, height: 30))
        iconContainerView.addSubview(iconView)
        
        leftView = iconContainerView
        leftViewMode = .always
    }
}

class ViewController: UIViewController {
    
    // outlets
    let userIcon = UIImage(systemName: "person.crop.circle")
    let passwordIcon = UIImage(systemName: "lock.circle")
    @IBOutlet var NUSNETIDTextField: UITextField! {
        didSet {
            NUSNETIDTextField.tintColor = UIColor.lightGray
            NUSNETIDTextField.setIcon(userIcon!)
        }
    }
    @IBOutlet var passwordTextField: UITextField! {
        didSet {
            passwordTextField.tintColor = UIColor.lightGray
            passwordTextField.setIcon(passwordIcon!)
        }
    }
    
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var changePasswordButton: UIButton!
    @IBOutlet var forgetPasswordButton: UIButton!
    @IBOutlet var signInPageLabel: UILabel!
    @IBOutlet var NUSJioLabel: UILabel!
    @IBOutlet var dontHaveAnAccountLabel: UILabel!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var orLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setUpElements() {
        // styling
        NUSNETIDTextField.layer.cornerRadius = 6.0
        passwordTextField.layer.cornerRadius = 6.0
        
        //buttons
        signInButton.setTitleColor(Styles.themeOrange, for: .normal)
        changePasswordButton.setTitleColor(Styles.themeOrange, for: .normal)
        forgetPasswordButton.setTitleColor(Styles.themeOrange, for: .normal)
        signUpButton.setTitleColor(Styles.themeOrange, for: .normal)
        
        // background
        view.backgroundColor = Styles.themeBlue
        
        // labels
        signInPageLabel.textColor = UIColor.lightGray
        NUSJioLabel.textColor = Styles.themeOrange
        errorLabel.textColor = UIColor.red
        errorLabel.alpha = 0.0
        dontHaveAnAccountLabel.textColor = UIColor.lightGray
        orLabel.textColor = UIColor.lightGray
    }
    
//    func validateNUSNETID() -> String? {
//        // check all fields are filled in
//        if NUSNETIDTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
//            return "Enter your user ID in the format \"domain\\user\" or \"user@domain\"."
//        }
//
//        if Utilities.isNUSNETIDValid(NUSNETIDTextField.text!) {
//            return "Enter your user ID in the format \"domain\\user\" or \"user@domain\"."
//        }
//        return nil
//    }
    
//    func validatePassword() -> String? {
//        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
//            return "Enter your password"
//        }
//        return nil
//    }
    
    func validateFields() -> String? {
        // may need to change to NUSEmailTextField!!!
        if NUSNETIDTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please enter your NUS email."
        }
        
        let cleanNUSEmail = NUSNETIDTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !Utilities.isNUSEmailValid(cleanNUSEmail) {
            return "Please enter your NUS email ending in @u.nus.edu or @nus.edu.sg. For default NUS email, please follow the format of e1234567@u.nus.edu"
        }
              
        
        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please enter your password."
        }
        
        return nil
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        // validate the NUSNETID and password
        let error = validateFields()
        
        if error != nil {
            // something wrong with the field, pop up keyboard
            showError(error!)
        } else {
            // create validated text fields
            let NUSNETID = NUSNETIDTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            // sign in user
            Auth.auth().signIn(withEmail: NUSNETID, password: password) { [weak self] authResult, error in
              guard let strongSelf = self else { return }
                if error != nil {
                    // could not log in
                    strongSelf.errorLabel.text = error!.localizedDescription
                    strongSelf.errorLabel.alpha = 1.0
                } else {
                    // sign in successfully
                    // transit to home screen
                    strongSelf.transitionToHomepage()
                }
            }
        }
    }
    
    func showError(_ errorMessage: String) {
        errorLabel.numberOfLines = 0
        errorLabel.text = errorMessage
        errorLabel.alpha = 1.0
    }
    
    func transitionToHomepage() {
        let homepageViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homepageViewController) as? HomepageViewController
        view.window?.rootViewController = homepageViewController
        view.window?.makeKeyAndVisible()
    }
}

