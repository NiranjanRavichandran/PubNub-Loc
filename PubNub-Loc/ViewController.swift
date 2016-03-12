//
//  ViewController.swift
//  PubNub-Loc
//
//  Created by Niranjan Ravichandran on 12/03/16.
//  Copyright © 2016 uncc. All rights reserved.
//

import UIKit
import PubNub
import CoreLocation

let configuration = PNConfiguration(publishKey: "pub-c-b4b5b0ef-140c-4a61-ac9e-177f72543636", subscribeKey: "sub-c-43c05518-e7c4-11e5-a027-0619f8945a4f")

class ViewController: UIViewController, PNObjectEventListener, CLLocationManagerDelegate {
    
    var client: PubNub?
    var locationManager = CLLocationManager()
    let shareButton = UIButton(frame: CGRectMake(0, 0, 150, 40))
    var isSharing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        client = PubNub.clientWithConfiguration(configuration)
        client?.addListener(self)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        shareButton.backgroundColor = UIColor(red: 80/255, green: 85/255, blue: 95/255, alpha: 1.0)
        shareButton.titleLabel?.textColor = UIColor.whiteColor()
        shareButton.center = self.view.center
        shareButton.layer.cornerRadius = 4
        shareButton.setTitle("Share Location", forState: .Normal)
        shareButton.addTarget(self, action: "shareLocation", forControlEvents: .TouchUpInside)
        self.view.addSubview(shareButton)
        
        let mapButton = UIButton(frame: CGRectMake(0, (self.view.frame.height - 45), self.view.frame.width, 45))
        mapButton.setTitle("View on Map", forState: .Normal)
        mapButton.backgroundColor = UIColor(red: 251/255, green: 95/255, blue: 95/255, alpha: 1.0)
        mapButton.addTarget(self, action: "goToMapView", forControlEvents: .TouchUpInside)
        self.view.addSubview(mapButton)
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last {
            print("current position: \(newLocation.coordinate.longitude) , \(newLocation.coordinate.latitude)")
            let message = "{\"lat\":\(newLocation.coordinate.latitude),\"lng\":\(newLocation.coordinate.longitude), \"alt\": \(newLocation.altitude)}"
            client?.publish(message, toChannel: "locTrack", compressed: false, withCompletion: nil)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location update failed with error: \(error.description)")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func shareLocation() {
        if !isSharing {
            isSharing = true
            locationManager.startUpdatingLocation()
            shareButton.setTitle("Stop Sharing", forState: .Normal)
        }else {
            isSharing = false
            locationManager.stopUpdatingLocation()
            shareButton.setTitle("Start Sharing", forState: .Normal)
            
            let message = "{\"alertCode\": \(100)}"
            client?.publish(message, toChannel: "locTrack", compressed: false, withCompletion: nil)
        }
    }
    
    func goToMapView() {
        self.navigationController?.pushViewController(MapViewController(), animated: true)
    }
}

