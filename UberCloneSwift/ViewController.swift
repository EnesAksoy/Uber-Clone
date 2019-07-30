//
//  ViewController.swift
//  UberCloneSwift
//
//  Created by ENES AKSOY on 19.07.2019.
//  Copyright © 2019 ENES AKSOY. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var choiceSegment: UISegmentedControl!
    
    var driver:Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func logIn(_ sender: Any) {
        
        if (email.text?.isEmpty)! && (password.text?.isEmpty)! {
            showAlert(title: "HATA", message: "Lütfen boş alan bırakmayınız")
        }else {
            Auth.auth().signIn(withEmail: email.text!, password: password.text!, completion:  { (user, error) in
                if error != nil {
                    self.showAlert(title: "HATA", message: error!.localizedDescription)
                }else{
                    
                    if self.driver{
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let passengerVC = storyboard.instantiateViewController(withIdentifier: "DriverVC")
                        
                        self.present(passengerVC,animated: true,completion: nil)
                        self.email.text = ""
                        
                    }else{
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let passengerVC = storyboard.instantiateViewController(withIdentifier: "PassengerVC")
                        
                        self.present(passengerVC,animated: true,completion: nil)
                        self.email.text = ""
                    }
              
                }
            })
        }
    }
    
    @IBAction func selectUserType(_ sender: Any) {
        
        if choiceSegment.selectedSegmentIndex == 0 {
            print("yolcu seçildi")
            driver = false
            if (!(email.text?.isEmpty)!) {
                self.logIn(sender)
            }
            
        }else{
            
            print("sürücü seçildi")
            driver = true
            if (!(email.text?.isEmpty)!) {
                self.logIn(sender)
            }
        }
        
    }
}

