//
//  UserProfileController.swift
//  IgFirebase
//
//  Created by Derek on 2019/2/26.
//  Copyright © 2019 Derek. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController:UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    var userId:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        
        setupLogOutButton()
        
        fetchUser()
        
//        fetchOrderedPosts()
    }
    
    
    var posts = [Post]()
    var user:User?
    
    /*
 
     static func fetchUserWithUID(uid:String, completion: @escaping (User) -> ()) {
     Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
     
     guard let userDictionary = snapshot.value as? [String:Any] else {return}
     
     let user = User(uid: uid, dictionary: userDictionary)
     
     completion(user)
     
     }) { (error) in
     print("Failed to fetch user for posts:", error)
     }
     }
 */
    
    
    //重要
    fileprivate func fetchUser() {
        
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            
            self.user = user
            
            self.navigationItem.title = self.user?.username
            //MARK: 2. 接著來到viewDidLoad裡面的fetchUser, 並reloadData，reloadData後會再回到viewForSupplementaryElementOfKind，此時header.user已經有值，一有值就會跳到didset
            self.collectionView.reloadData()
            
            self.fetchOrderedPosts()
        }
        
    }
    
    fileprivate func fetchOrderedPosts() {
        guard let uid = self.user?.uid else {return}
        let ref = Database.database().reference().child("posts").child(uid)
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
         
            guard let user = self.user else {return}
            
            let post = Post(user: user, dictionary: dictionary)
            
            self.posts.insert(post, at: 0)
            self.collectionView.reloadData()
            
        }) { (err) in
            print("Failed to fetch ordered posts:", err)
        }
    }
    
    fileprivate func setupLogOutButton() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
        
    }
    
    @objc func handleLogOut() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { (_) in
            print("Perform log out")
            
            do{
                //登出
                try Auth.auth().signOut()
               
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
                
            }catch let signOutErr{
                print("Failed to sign out:", signOutErr)
            }
           
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
        //MARK: 3. user的didset設定完跳回這裡
        cell.post = posts[indexPath.item]

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //MARK: 1. 畫面剛讀入先來到viewForSupplementaryElementOfKind
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        header.user = self.user
        
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 200)
    }
    
}


