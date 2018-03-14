//
//  HomeViewController.swift
//  Tindog
//
//  Created by Doyle on 6/03/18.
//  Copyright © 2018 Doyle. All rights reserved.
//

import UIKit
import RevealingSplashView
import Firebase

class NavigationImageView: UIImageView {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: 76, height: 39)
    }
}

class HomeViewController: UIViewController {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var homeWrapper: UIStackView!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var nopeImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lbCarName: UILabel!
    
    let leftbtn = UIButton(type: .custom)
    let rightBtn = UIButton(type: .custom)
    var currentUserProfile: UserModel?
    var currentMatch: MatchModel?
    var secondUserUid: String?
    
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named:"splash_icon")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: UIColor.white)
    
    var users = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(revealingSplashView)
        self.revealingSplashView.animationType = SplashAnimationType.popAndZoomOut
        self.revealingSplashView.startAnimation()
        let titleView = NavigationImageView()
        titleView.image = UIImage(named: "Actions")
        self.navigationItem.titleView = titleView
        let homeGR = UIPanGestureRecognizer(target: self, action: #selector(cardDragged))
        self.cardView.addGestureRecognizer(homeGR)
        
        self.leftbtn.imageView?.contentMode = .scaleAspectFit
        let leftBarButton =  UIBarButtonItem(customView: leftbtn)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        self.rightBtn.imageView?.contentMode = .scaleAspectFit
        self.rightBtn.setImage(UIImage(named: "match_inactive"), for: .normal)
        let rightBarBtn =  UIBarButtonItem(customView: rightBtn)
        self.navigationItem.rightBarButtonItem = rightBarBtn
        
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let _ = user {
                print("el usuario inicio correctamente" )
            }else{
                print("El usuario hizo logout")
            }
            DataBaseService.instance.observerUserProfile { (userDict) in
                self.currentUserProfile = userDict
                UpdateDBService.instance.observeMatch { (matchDict) in
                    print("update Match")
                    if let match = matchDict {
                        if let user = self.currentUserProfile{
                            if user.userIsOnMatch == false {
                                print("tiene un match")
                                self.currentMatch = match
                                self.changeRightBtn(active: true)
                            }
                        }
                    }else{
                        self.changeRightBtn(active: false)
                    }
                }
            }
            self.getUsers()
        }
        
        
    }
    
    func changeRightBtn(active: Bool){
        if active {
            self.rightBtn.addTarget(self, action: #selector(goToMatch(sender:)), for: .touchUpInside)
            self.rightBtn.setImage(UIImage(named: "match_active"), for: .normal)
        }else{
            self.rightBtn.removeTarget(nil, action: nil, for: .allEvents)
            self.rightBtn.setImage(UIImage(named: "match_inactive"), for: .normal)
           
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            self.leftbtn.setImage(UIImage(named: "login_active"), for: .normal)
            self.leftbtn.removeTarget(nil, action: nil, for: .allEvents)
            self.leftbtn.addTarget(self, action: #selector(goToProfile(sender:)), for: .touchUpInside)
        }else{
            self.leftbtn.setImage(UIImage(named: "login"), for: .normal)
            self.leftbtn.removeTarget(nil, action: nil, for: .allEvents)
            self.leftbtn.addTarget(self, action: #selector(goToLogin(sender:)), for: .touchUpInside)
        }
    }
    
    @objc func goToLogin(sender: UIButton){
        print("push")
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController")
        present(loginViewController, animated: true, completion: nil)
    }
    
    @objc func goToProfile(sender: UIButton){
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let profileViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileViewController.currentUserProfile = currentUserProfile
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    @objc func goToMatch(sender: UIButton){
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let matchViewController = storyBoard.instantiateViewController(withIdentifier: "MatchViewController") as! MatchViewController
        matchViewController.currentUserProfile = self.currentUserProfile
        matchViewController.currentMatch = self.currentMatch
        present(matchViewController, animated: true, completion: nil)
    }
    
    func getUsers(){
        DataBaseService.instance.User_Ref.observeSingleEvent(of: .value) { (snapshot) in
            let usersSnapshot = snapshot.children.flatMap{UserModel(snapshot: $0 as! DataSnapshot)}
            for user in usersSnapshot{
                print("user: \(user.email)")
                if self.currentUserProfile?.uid != user.uid{
                    self.users.append(user)
                }
            }
            if self.users.count > 0 {
                self.updateImage(uid: (self.users.first?.uid)!)
            }
        }
    }
    
    @objc func cardDragged(gesture: UIPanGestureRecognizer){
        //print("Drag \(gesture.translation(in: view))")
        let cardPoint = gesture.translation(in: view)
        self.cardView.center = CGPoint(x: self.view.bounds.width/2 + cardPoint.x, y: self.view.bounds.height/2 + cardPoint.y)
        
        let xFromCenter = self.view.bounds.width / 2 - self.cardView.center.x
        var rotate = CGAffineTransform(rotationAngle: xFromCenter/300)
        let scale = min(100/abs(xFromCenter), 1)
        var finalTransform = rotate.scaledBy(x: scale, y: scale)
        self.cardView.transform = finalTransform
        
        if  self.cardView.center.x < (self.view.bounds.width/2 - 100){
            self.nopeImage.alpha = min(abs(xFromCenter/100), 1)
        }
        if  self.cardView.center.x > (self.view.bounds.width/2 + 100){
            self.likeImage.alpha = min(abs(xFromCenter/100), 1)
        }
        
        if gesture.state == .ended {
            print(self.cardView.center.x)
            if  self.cardView.center.x < (self.view.bounds.width/2 - 100){
                print("dislike")
            }
            if  self.cardView.center.x > (self.view.bounds.width/2 + 100){
                print("like")
                //Created Match
                if let uid2 = self.secondUserUid{
                    DataBaseService.instance.createFirebaseDBMatch(uid: (self.currentUserProfile?.uid)!, uid2: uid2)
                }
            }
            
            //Update Image
            if self.users.count > 0 {
                self.updateImage(uid: self.users[self.random(0..<self.users.count)].uid)
            }
            rotate = CGAffineTransform(rotationAngle: 0)
            finalTransform = rotate.scaledBy(x: 1, y: 1)
            self.cardView.transform = finalTransform
            self.cardView.center = CGPoint(x: self.homeWrapper.bounds.width/2, y: self.homeWrapper.bounds.height/2 - 30)
            self.likeImage.alpha = 0
            self.nopeImage.alpha = 0
        }
    }
    
    func updateImage(uid:String){
        DataBaseService.instance.User_Ref.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let userProfile = UserModel(snapshot: snapshot){
                self.secondUserUid = userProfile.uid
                self.userImage.sd_setImage(with: URL(string: userProfile.profileImage), completed: nil)
                self.lbCarName.text = userProfile.displayName
            }
        }
    }
    
    func random(_ range: Range<Int>)-> Int{
        return range.lowerBound + Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
}
