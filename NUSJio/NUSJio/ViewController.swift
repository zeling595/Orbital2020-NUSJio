//
//  ViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/5/30.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit

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
    
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var changePasswordButton: UIButton!
    @IBOutlet var forgetPasswordButton: UIButton!
    @IBOutlet var signInPageLabel: UILabel!
    @IBOutlet var NUSJioLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // styling
        NUSNETIDTextField.layer.cornerRadius = 6.0
        passwordTextField.layer.cornerRadius = 6.0
        signInButton.setTitleColor(Styles.themeOrange, for: .normal)
        changePasswordButton.setTitleColor(Styles.themeOrange, for: .normal)
        forgetPasswordButton.setTitleColor(Styles.themeOrange, for: .normal)
        view.backgroundColor = Styles.themeBlue
        signInPageLabel.textColor = UIColor.lightGray
        NUSJioLabel.textColor = Styles.themeOrange
        
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
    }
    
}

