//
//  CallUberViewController.swift
//  UberCloneSwift
//
//  Created by ENES AKSOY on 19.07.2019.
//  Copyright © 2019 ENES AKSOY. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase

class CallUberViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var uberMap: MKMapView!
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var taxiCalled:Bool = false
  
    @IBOutlet weak var taxiButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Konumu en iyi şekilde ayarlar.
        locationManager.requestWhenInUseAuthorization() // Uygulama açıkken konuma erişecek.
        locationManager.startUpdatingLocation() //Uygulama kullanılıyorken konumu güncelleyecek.
        
        
        if let email = Auth.auth().currentUser?.email{
            Database.database().reference().child("TaksiCagiranlar").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                self.taxiCalled = true
                self.taxiButton.setTitle("İptal Et", for: .normal)
            }
        }
    }
    
    // Konum değiştikçe konumu taki edecek fonksiyon.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let cord = manager.location?.coordinate{
            let center = CLLocationCoordinate2DMake(cord.latitude, cord.longitude)
            userLocation = center
            let span = MKCoordinateSpan( latitudeDelta: 0.01, longitudeDelta: 0.01) // Haritaya yakınlık belirler
            let region = MKCoordinateRegion(center: center, span: span)
            uberMap.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "Buradasınız"
            uberMap.addAnnotation(annotation)
            
        }
    }
    
    @IBAction func callTaxi(_ sender: Any) {
        
        let email = Auth.auth().currentUser?.email
        let userInfos:[String : Any] = ["email":email!, "enlem":userLocation.latitude, "boylam":userLocation.longitude]
        
        if taxiCalled{    // Taksi İptal Etme Kısmı
            taxiCalled = true
            taxiButton.setTitle("Taksi Çağır", for: .normal)
            Database.database().reference().child("TaksiCagiranlar").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                snapshot.ref.removeValue()
                Database.database().reference().child("TaksiCagiranlar").removeAllObservers()
            }
            
        }else{
            // Taksi Çağırma Kısmı
            
            Database.database().reference().child("TaksiCagiranlar").childByAutoId().setValue(userInfos)
            taxiButton.setTitle("İptal Et", for: .normal)
            taxiCalled = true
        }
        
        
        
    }
    
    @IBAction func logOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)   // Gelmiş olduğun sayfaya git.
        } catch  {
            print("Çıkış yapılamadı")
        }
        
    }
}
