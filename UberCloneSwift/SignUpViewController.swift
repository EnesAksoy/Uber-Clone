//
//  SignUpViewController.swift
//  UberCloneSwift
//
//  Created by ENES AKSOY on 19.07.2019.
//  Copyright © 2019 ENES AKSOY. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pass1: UITextField!
    @IBOutlet weak var pass2: UITextField!
    
    
    @IBOutlet weak var choiceSegment: UISegmentedControl!
    var driver:Bool = false // İlk başta yolcu aktif olur.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveUser(_ sender: Any) {
        
        if email.text!.isEmpty && pass1.text!.isEmpty && pass2.text!.isEmpty {
            showAlert(title: "HATA", message: "Lütfen boş alan bırakmayınız")
        }
        
        if pass1.text != pass2.text {
            showAlert(title: "HATA", message: "Şifre tekrarlarınız yanlış")
        }
        Auth.auth().createUser(withEmail: email.text!, password: pass1.text!) { (user, error) in
            
            if let error = error {
                self.showAlert(title: "HATA", message: error.localizedDescription)
            }else{
                self.showAlert(title: "TEBRİKLER", message: "Kullanıcı Kaydınız Tamamlanmıştır")
            }
        }
        
        if driver{
            let userInfos:[String:Any] = ["email":email.text!, "gorev":"sofor"]
            Database.database().reference().child("kullanicilar").childByAutoId().setValue(userInfos)
            self.email.text = ""
            
        }else{
            let userInfos:[String:Any] = ["email":email.text!, "gorev":"yolcu"]
            Database.database().reference().child("kullanicilar").childByAutoId().setValue(userInfos)
             self.email.text = ""
        }
        
    }
    
    @IBAction func selectUserType(_ sender: Any) {
        
        if choiceSegment.selectedSegmentIndex == 0 {
            
            print("yolcu seçildi")
            driver = false
            if (!(email.text?.isEmpty)!) {
                self.saveUser(sender)
            }
            
        }else{
            
            print("sürücü seçildi")
            driver = true
            if (!(email.text?.isEmpty)!) {
                self.saveUser(sender)
            }
        }
        
        
    }
    
    
    
    
}

extension UIViewController {
    func showAlert (title:String, message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        self.present(alert,animated:true,completion:nil)
    }
}
