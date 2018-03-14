//
//  ProfileViewController.swift
//  Tindog
//
//  Created by Doyle on 12/03/18.
//  Copyright © 2018 Doyle. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ProfileViewController: UIViewController {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lbUserName: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    
    var currentUserProfile: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgProfile.sd_setImage(with: URL(string: (self.currentUserProfile?.profileImage)!) , completed: nil)
        self.imgProfile.round()
        self.lbEmail.text = self.currentUserProfile?.email
        self.lbUserName.text = self.currentUserProfile?.displayName
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeProfileBtn(_ sender: Any) {
        try! Auth.auth().signOut()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func ActionimportUsers(_ sender: Any) {
        let users = [
            ["email": "barcoleon9@gmail.com", "password":"123456", "displayName":"Bruno", "profileImage": "https://i.imgur.com/VXAkKUF.jpg"],
            ["email": "barcoleon1@gmail.com", "password":"123456", "displayName":"Pelotudo", "profileImage": "https://i.imgur.com/FbyEJrj.jpg"],
            ["email": "barcoleon2@gmail.com", "password":"123456", "displayName":"Ruso", "profileImage": "https://i.imgur.com/U57lAkr.jpg"],
            ["email": "barcoleon3@gmail.com", "password":"123456", "displayName":"Mateo", "profileImage": "https://i.imgur.com/fyh3w3B.jpg"],
            ["email": "barcoleon4@gmail.com", "password":"123456", "displayName":"Luna", "profileImage": "https://i.imgur.com/p76aAvI.jpg"],
            ["email": "barcoleon5@gmail.com", "password":"123456", "displayName":"Siro", "profileImage": "https://i.imgur.com/ZBSOaSi.jpg"],
            ["email": "barcoleon6@gmail.com", "password":"123456", "displayName":"Elvis Presly", "profileImage": "https://i.imgur.com/kARmJbY.jpg"],
            ["email": "barcoleon7@gmail.com", "password":"123456", "displayName":"Teodoro", "profileImage": "https://i.imgur.com/U57lAkr.jpg"],
            ["email": "barcoleon8@gmail.com", "password":"123456", "displayName":"Chiquitin", "profileImage": "https://i.imgur.com/p76aAvI.jpg"]]
        
        for userDemo in users{
            Auth.auth().createUser(withEmail: userDemo["email"]!, password: userDemo["password"]!, completion: { (user, error) in
                if let user = user {
                    let userData = ["provider": user.providerID,
                                    "email": user.email!,
                                    "profileImage": userDemo["profileImage"]!,
                                    "displayName": userDemo["displayName"]!,
                                    "userIsOnMatch" : false] as [String: Any]
                    DataBaseService.instance.createFirebaseDBUser(uid: user.uid, userData: userData)
                }
            })
        }
    }

}
