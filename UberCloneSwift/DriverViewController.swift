//
//  DriverViewController.swift
//  UberCloneSwift
//
//  Created by ENES AKSOY on 27.07.2019.
//  Copyright © 2019 ENES AKSOY. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class DriverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var taksiCagiranlar : [DataSnapshot] = []
    var konumYoneticisi = CLLocationManager()
    var soforKonum = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        konumYoneticisi.delegate = self
        konumYoneticisi.desiredAccuracy = kCLLocationAccuracyBest // Konumu en iyi şekilde ayarlar.
        konumYoneticisi.requestWhenInUseAuthorization() // Uygulama açıkken konuma erişecek.
        konumYoneticisi.startUpdatingLocation() //Uygulama kullanılıyorken konumu güncelleyecek.
        
        Database.database().reference().child("TaksiCagiranlar").observe(.childAdded) { (snapshot) in
            self.taksiCagiranlar.append(snapshot)
            self.tableView.reloadData()
        }
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (updateTimer) in
            self.tableView.reloadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let soforKoord = manager.location?.coordinate{
            soforKonum = soforKoord
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        
        print("tıklandı")
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
            
        } catch  {
            print("Çıkış yapılamadı")
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taksiCagiranlar.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "taksiCagiranlarCell", for: indexPath)
        
        let snapshot = taksiCagiranlar[indexPath.row]
        if let taksiCagiranlarVerisi = snapshot.value as? [String:AnyObject]{
            if let email = taksiCagiranlarVerisi["email"] as? String {
                if let enlem = taksiCagiranlarVerisi["enlem"] as? Double{
                    if let boylam = taksiCagiranlarVerisi["boylam"] as? Double{
                        
                        let soforKonumBilgileri = CLLocation(latitude: soforKonum.latitude, longitude: soforKonum.longitude)
                        let yolcuKonumBilgileri = CLLocation(latitude: enlem, longitude: boylam)
                        
                        let uzaklik = soforKonumBilgileri.distance(from: yolcuKonumBilgileri) / 1000
                        let yaklasikUzaklik = round(uzaklik*100)/100
                        
                        cell.textLabel?.text = "\(email) - \(yaklasikUzaklik) km mesafede"
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let passengerVC = storyboard.instantiateViewController(withIdentifier: "TaxiRequestVC")
        
        self.present(passengerVC,animated: true,completion: nil)
    }
    
    

}
