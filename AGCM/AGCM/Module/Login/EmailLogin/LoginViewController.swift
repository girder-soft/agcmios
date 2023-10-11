//
//  LoginViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 24/01/23.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
    }
    
    @IBAction func resetPasswordButtonAction(_ sender: UIButton) {
        
        if let resetPassword_VC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "ResetPasswordViewController") as? ResetPasswordViewController {
            self.present(resetPassword_VC, animated: true)
        }
        
    }
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else {
            ProgressHUD.showError("Enter valid email")
            return
        }
        guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !password.isEmpty else {
            ProgressHUD.showError("Enter valid password")
            return
        }
        loginWithCredential(email: email, password: password)
    }
    
    private func loginWithCredential(email: String, password: String) {
        ProgressHUD.show()
        viewModel.loginWithCredential(email: email, password: password) {[weak self] in
            ProgressHUD.dismiss()
            self?.loginSuccess()
        } onError: {error in
            if error == .invalidCredentials {
                ProgressHUD.showError("Please enter valid credentials")
            } else if error == .noInternet {
                ProgressHUD.showError("No Internet connection")
            } else {
                ProgressHUD.showError("Something went wrong, please try again.")
            }
        }
    }
    
    private func loginSuccess() {
        if let window = UIApplication.shared.window {
            let home_VC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            window.rootViewController = home_VC
        }
    }
    
}
