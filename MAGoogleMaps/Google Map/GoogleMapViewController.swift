//
//  GoogleMapViewController.swift
//  MAMaps
//
//  Created by Muneeb Ali on 07/06/2018.
//  Copyright © 2018 Muneeb Ali. All rights reserved.
//

import UIKit
import GoogleMaps


struct Location {
    let countryName: String
    let name: String
    let locationCoordinate: CLLocationCoordinate2D
}



class GoogleMapViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var mapView: MAGMSMapView!
    @IBOutlet weak var menuButton: UIButton!
    
    //MARK: - Variables
    
    let initialLocation = CLLocationCoordinate2D(latitude: 33.6844, longitude: 73.0479)
    var originCoordinates = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var destinationCoordinates = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    let location = [
        Location(countryName: "Pakistan", name: "Islamabad", locationCoordinate: CLLocationCoordinate2D(latitude: 33.7080, longitude: 73.0497)) ,
        Location(countryName: "Pakistan", name: "Islamabad", locationCoordinate: CLLocationCoordinate2D(latitude: 33.7132, longitude: 73.0497)),
        Location(countryName: "Pakistan", name: "Islamabad", locationCoordinate: CLLocationCoordinate2D(latitude: 33.7182, longitude: 73.0497))
    ]
    
    
    var marker = GMSMarker()
    var originMarker = GMSMarker()
    var destinationMarker = GMSMarker()
    var routePolyline = GMSPolyline()
    var routePolyline11 : GMSPolyline?
    var markerArray = [GMSMarker]()
    var wayPoints = [String]()
    var travelMode = TravelModes.driving
    var startCord = CLLocationCoordinate2D()
    var endCord = CLLocationCoordinate2D()
    var searchController: UISearchController?
    var resultView: UITextView?
    
    
    
    //MARK: - UIViewController Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

    
    //MARK: - Setup Method
    func setupUIViewController() {
        mapView.setUpMap(location: initialLocation)
    }
    
    @objc func menuTapped() {
        
    }
    
    //MARK: - IBActions
    @IBAction func menuButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: Messages.SelectOption, preferredStyle: .actionSheet)
        
        //--------------------------------------------- Current Location ---------------------------------------------
        alert.addAction(UIAlertAction(title: Title.CurrentLocation, style: .default , handler:{ (UIAlertAction)in
            self.mapView.currentLocation()
        }))
        
        //--------------------------------------------- May Type ---------------------------------------------
        alert.addAction(UIAlertAction(title: Title.MapType, style: .default , handler:{ (UIAlertAction) in
            self.present(self.mapView.mapTerrin(), animated: true, completion: nil)
        }))
        
        //--------------------------------------------- Set Pin ---------------------------------------------
        alert.addAction(UIAlertAction(title: Title.SetPin, style: .default , handler:{ (UIAlertAction) in
            
            _ = self.mapView.setDefaultMarkerOnMap(locationCoordinate: self.location[0].locationCoordinate, title:  self.location[0].name, snippet:  self.location[0].countryName)
            
            _ = self.mapView.setMarkerWithImageOnMap(locationCoordinate:  self.location[1].locationCoordinate, image: #imageLiteral(resourceName: "GooglePin"), title: self.location[1].name, snippet: self.location[1].countryName)
            
            let pinView = MapPinView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
            _ = self.mapView.setMarkerWithViewOnMap(locationCoordinate: self.location[2].locationCoordinate, pinView: pinView, title: self.location[2].name, snippet: self.location[2].countryName)
        }))
        
        //--------------------------------------------- Draw Circle ---------------------------------------------
        alert.addAction(UIAlertAction(title: Title.DrawCircle, style: .default , handler:{ (UIAlertAction) in
            
            self.mapView.drawCircleOnLocation(coordinates: self.location[0].locationCoordinate)
            
            self.mapView.drawCircleOnLocation(coordinates: self.location[1].locationCoordinate, radius: 200, fillColor: .blue, strokeColor: .brown, strokeWidth: 2.0)
        }))
        
        //--------------------------------------------- Find Address ---------------------------------------------
        alert.addAction(UIAlertAction(title: Title.FindAddress, style: .default , handler:{ (UIAlertAction) in
            self.addressAlert()
        }))
        
        //--------------------------------------------- Route Draw ---------------------------------------------
        alert.addAction(UIAlertAction(title: Title.DrawRoute, style: .default , handler:{ (UIAlertAction) in
            self.routeDrawAlert()
        }))
        
        //--------------------------------------------- Moving Object Pin On Route ---------------------------------------------
        alert.addAction(UIAlertAction(title: Title.MovingPin, style: .default , handler:{ (UIAlertAction) in
            let moveAbleMarker = self.mapView.setMarkerWithImageOnMap(locationCoordinate: self.originCoordinates, image: #imageLiteral(resourceName: "Pin3"), title: "", snippet: "")
            self.mapView.moveObject(startCoordinate: self.originCoordinates, endCoordinate: self.destinationCoordinates, marker: moveAbleMarker)
            
        }))
        
        //--------------------------------------------- Dismiss ---------------------------------------------
        alert.addAction(UIAlertAction(title: Title.Dismiss, style: .cancel, handler:{ (UIAlertAction) in
            
        }))
        
        self.present(alert, animated: true, completion: {
            
        })
    }
    
}



extension GoogleMapViewController {
    
    func addressAlert() {
        let addressAlert = UIAlertController(title: "Address Finder", message: "Type the address you want to find:", preferredStyle: UIAlertControllerStyle.alert)
        
        addressAlert.addTextField { (textField) -> Void in
            textField.placeholder = "Enter Address?"
        }
        
        let findAction = UIAlertAction(title: "Find Address", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            
            let address = (addressAlert.textFields![0] as UITextField).text! as String
            
            self.mapView.findAddress(address, withCompletionHandler: { (status, success, locationCoordinates, locationAddress, placeID)  -> Void in
                if !success {
                    print(status)
                    
                    if status == "ZERO_RESULTS" {
                        let alert = UIAlertController(title: "Error", message: "The location could not be found.", preferredStyle: UIAlertControllerStyle.alert)
                        let close = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
                        }
                        alert.addAction(close)
                    }
                }
                else {
                    _ = self.mapView.setMarkerWithImageOnMap(locationCoordinate: locationCoordinates, image: #imageLiteral(resourceName: "GooglePin"), title: locationAddress, snippet: "")
                }
            })
        }
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
            
        }
        
        addressAlert.addAction(findAction)
        addressAlert.addAction(closeAction)
        
        present(addressAlert, animated: true, completion: nil)
    }
    
    
    //***************************************************************************************************************************************************
    
    func routeDrawAlert() {
        let directionAlert = UIAlertController(title: "Create Route", message: "Connect locations with a route:", preferredStyle: UIAlertControllerStyle.alert)
        
        directionAlert.addTextField { (textField) -> Void in
            textField.placeholder = "Enter Origin?"
        }
        
        directionAlert.addTextField { (textField) -> Void in
            textField.placeholder = "Enter Destination?"
        }
        
        
        let routeAction = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            let origin = (directionAlert.textFields![0] as UITextField).text! as String
            let destination = (directionAlert.textFields![1] as UITextField).text! as String

            self.mapView.originPinImage = #imageLiteral(resourceName: "Pin1")
            self.mapView.destinationPinImage = #imageLiteral(resourceName: "Pin2")
            self.mapView.getDirections(origin: origin, destination: destination, waypoints: nil, travelMode: TravelModes.driving, completionHandler: { (status, success, totalDistance, totalDuration, originCoordinates, destinationCoordinates) in
                self.originCoordinates = originCoordinates
                self.destinationCoordinates = destinationCoordinates
            })
        }
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
            
        }
        
        directionAlert.addAction(routeAction)
        directionAlert.addAction(closeAction)
        
        present(directionAlert, animated: true, completion: nil)
    }
}
