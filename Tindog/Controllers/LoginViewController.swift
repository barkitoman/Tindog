//
//  LoginViewController.swift
//  Tindog
//
//  Created by Doyle on 12/03/18.
//  Copyright © 2018 Doyle. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnView: UIButton!
    @IBOutlet weak var lbSubLogin: UILabel!
    @IBOutlet weak var btnSubLogin: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    var registerMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
//        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
//    @objc func handleTap(sender: UITapGestureRecognizer){
//        self.view.endEditing(true)
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(titulo: String, message: String){
        let alertView = UIAlertController(title: titulo, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    @IBAction func actionLoginRegistrer(_ sender: Any) {
        if self.txtEmail.text == "" || self.txtPassword.text == "" {
            self.showAlert(titulo: "Error", message: "No puedes tener campos vacios")
        }else{
            if let email = self.txtEmail.text{
                if let password = self.txtPassword.text{
                    if registerMode {
                        self.registrerUser(email: email, password: password)
                    }else{
                        self.loginUser(email: email, password: password)
                    }
                }
            }
        }
    }
    
    func registrerUser(email: String, password: String){
        Auth.auth().createUser(withEmail: email, password: password, completion: {(user, error) in
            if error != nil {
                self.showAlert(titulo: "Error", message: error!.localizedDescription)
            }else{
                if let user = user {
                    let userData = ["provider": user.providerID,
                                    "email": user.email!,
                                    "profileImage": "https://i.imgur.com/oaBVoWI.jpg",
                                    "displayName": "Crispeta",
                                    "userIsOnMatch": false] as [String: Any]
                    DataBaseService.instance.createFirebaseDBUser(uid: user.uid, userData: userData)
                }
                print("Registro")
            }
        })
        
    }
    
    func loginUser(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
            if error != nil {
                self.showAlert(titulo: "Error", message: error!.localizedDescription)
            }else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func actionGoLogin(_ sender: Any) {
        if self.registerMode{
            self.btnView.setTitle("Login", for: .normal)
            self.lbSubLogin.text = "¿Eres nuevo?"
            self.btnSubLogin.setTitle("Registrate", for: .normal)
            self.registerMode = false
        }else{
            self.btnView.setTitle("Crear Cuenta", for: .normal)
            self.lbSubLogin.text = "¿Ya tienes Cuenta?"
            self.btnSubLogin.setTitle("Login", for: .normal)
            self.registerMode = true
        }
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentInset.bottom = keyboardSize.height + 90
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        scrollView.contentInset.bottom = 0
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtEmail.resignFirstResponder()
        txtPassword.resignFirstResponder()
        return true
    }
    
}
