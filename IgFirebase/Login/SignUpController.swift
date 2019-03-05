//
//  ViewController.swift
//  IgFirebase
//
//  Created by Derek on 2019/2/25.
//  Copyright © 2019 Derek. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let plusPhotoButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage {
            
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
            
        }else if let originalImage = info[.originalImage] as? UIImage {
            
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.clipsToBounds = true
     
        dismiss(animated: true, completion: nil)
    }
    
    let emailTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    @objc func handleTextInputChange() {
        
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && usernameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        }else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    let usernameTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
         tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
         tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let signUpButton:UIButton = {
       let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    let alreadyHaveAccountButton:UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor:UIColor.rgb(red: 17, green: 154, blue: 237)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()
    
    @objc func handleAlreadyHaveAccount() {
        navigationController?.popViewController(animated: true)
    }
    //MARK: 重要
    @objc func handleSignUp() {
        
        guard let email = emailTextField.text, email != "",
            let username = usernameTextField.text, username != "",
            let password = passwordTextField.text, password != "" else {
                print("Please input data correctly")
                return
        }
        
        //創建User
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if let error = error {
                print("Failed to create user:", error)
                return
            }
            print("Sucessfully created user:", user?.user.uid ?? "")
            
            //把照片轉成data再上傳到Storage
            guard let image = self.plusPhotoButton.imageView?.image else {return}
            
            guard let uploadData = image.jpegData(compressionQuality: 0.3) else {return}
            
            let filename = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_image").child(filename)
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if let error = error {
                    print("Failed to upload profile image:", error)
                    return
                }
                    //上傳後會取得downloadURL，將username & profileImageUrl放入字典
                    storageRef.downloadURL(completion: { (downloadURL, error) in
                        if let error = error {
                            print("Failed to fetch downloadURL:", error)
                            return
                        }
                        guard let profileImageUrl = downloadURL?.absoluteString else {return}
                        print("Successfully uploaded profile image.", profileImageUrl)
                        
                        guard let uid = user?.user.uid else {return}
                        let dictionaryValues = ["username":username, "profileImageUrl":profileImageUrl]
                        let values = [uid:dictionaryValues]
                       
                        //以uid為key值，上傳values到database
                        Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (error, ref) in
                            
                            if let error = error {
                                print("Failed to save user info into db:", error)
                                return
                            }
                            print("Successfully saved user info to db")
                            
                            guard let mainTabBarController =  UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
                            
                            mainTabBarController.setupViewControllers()
                            
                            self.dismiss(animated: true, completion: nil)
                        })

                    })
                
                print("Successfully uploaded profile image:")
                
            })
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = .white
        view.addSubview(plusPhotoButton)
        
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        setupInputFields()
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
    }
    
    fileprivate func setupInputFields() {
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
    }

}

