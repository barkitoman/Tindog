//
//  MatchViewController.swift
//  Tindog
//
//  Created by Doyle on 13/03/18.
//  Copyright © 2018 Doyle. All rights reserved.
//

import UIKit

class MatchViewController: UIViewController {

    @IBOutlet weak var lbCopyMatch: UILabel!
    @IBOutlet weak var imageFirstUser: UIImageView!
    @IBOutlet weak var imageSecondUser: UIImageView!
    @IBOutlet weak var btnDone: UIButton!
    
    var currentUserProfile: UserModel?
    var currentMatch: MatchModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageSecondUser.round()
        self.imageFirstUser.round()
        if let match = self.currentMatch {
            if let profile = self.currentUserProfile {
                var secondUid:String = ""
                if profile.uid == match.uid{
                    secondUid = match.uid2
                }else{
                    secondUid = match.uid
                }
                DataBaseService.instance.getUserProfile(uid: secondUid, handler: { (userDict) in
                    if let seconduser = userDict {
                        //init match
                        if profile.uid == match.uid{
                            self.imageFirstUser.sd_setImage(with: URL(string:  profile.profileImage), completed: nil)
                            self.imageSecondUser.sd_setImage(with: URL(string: seconduser.profileImage), completed: nil)
                            self.lbCopyMatch.text = "Esperando a \(seconduser.displayName)"
                            self.btnDone.alpha = 0
                        }else{
                            //match
                            self.imageFirstUser.sd_setImage(with: URL(string:  seconduser.profileImage), completed: nil)
                            self.imageSecondUser.sd_setImage(with: URL(string: profile.profileImage), completed: nil)
                            self.lbCopyMatch.text = "Tu mascota le gusta a \(seconduser.displayName)"
                            self.btnDone.alpha = 1
                        }
                    }
                })
                
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionAccepted(_ sender: Any) {
        if let currentMatch = self.currentMatch{
            if currentMatch.matchIsAcepted{
                
            }else{
                DataBaseService.instance.updateFirebaseDBMatch(uid: currentMatch.uid)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
