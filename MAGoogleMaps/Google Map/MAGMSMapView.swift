//
//  MAGMSMapView.swift
//  MAMaps
//
//  Created by Muneeb Ali on 05/07/2018.
//  Copyright © 2018 Muneeb Ali. All rights reserved.
//

import Foundation
import GoogleMaps


enum TravelModes: Int {
    case driving
    case walking
    case bicycling
}


class MAGMSMapView: GMSMapView {
    
    //MARK: - Variables
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    let baseURLDirection = "https://maps.googleapis.com/maps/api/directions/json?"
    var originPinImage: UIImage!
    var destinationPinImage: UIImage!
    var moveingObjectPinImage: UIImage!
    var dummyCoordinates = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    
    
    //MARK: - Init Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    //MARK: - Setup Map Methods
    func setUpMap(location: CLLocationCoordinate2D) {
        
        cameraFocus(location: location, zoomLevel: 10.0)
        settings.myLocationButton = true
        isMyLocationEnabled = true
        isIndoorEnabled = true
        settings.compassButton = true
    }
    
    func cameraFocus(location: CLLocationCoordinate2D, zoomLevel: Float = 15.0) {
        let cameraPosition = GMSCameraPosition.camera(withTarget: location, zoom: zoomLevel)
        camera = cameraPosition
    }
    
    
    //MARK: - Current Location Method
    func currentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = true
        } else {
            // Fallback on earlier versions
        }
        locationManager.startUpdatingLocation()
    }
    
    
    //MARK: - Map Terrin Type
    func mapTerrin() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: Messages.SelectOption, preferredStyle: .actionSheet)
        
        
        alert.addAction(UIAlertAction(title: Title.Hybrid, style: .default , handler:{ (UIAlertAction) in
            self.mapType = .hybrid
        }))
        
        
        alert.addAction(UIAlertAction(title: Title.Normal, style: .default , handler:{ (UIAlertAction) in
            self.mapType = .normal
        }))
        
        
        alert.addAction(UIAlertAction(title: Title.Satellite, style: .default , handler:{ (UIAlertAction) in
            self.mapType = .satellite
        }))
        
        
        alert.addAction(UIAlertAction(title: Title.Terrain, style: .default, handler:{ (UIAlertAction) in
            self.mapType = .terrain
        }))
        
        alert.addAction(UIAlertAction(title: Title.Dismiss, style: .cancel, handler:{ (UIAlertAction) in
            
        }))
        
        return alert
    }
    
    
    //MARK: - Set Marker
    func setDefaultMarkerOnMap(locationCoordinate: CLLocationCoordinate2D, title: String, snippet: String) -> GMSMarker {
        
        let marker = GMSMarker()
        marker.position = locationCoordinate
        marker.title = title
        marker.snippet = snippet
        marker.tracksViewChanges = true
        marker.tracksInfoWindowChanges = true
        marker.map = self
        cameraFocus(location: locationCoordinate)
        return marker
    }
    
    
    func setMarkerWithImageOnMap(locationCoordinate: CLLocationCoordinate2D, image: UIImage, title: String, snippet: String) -> GMSMarker {
        
        let marker = GMSMarker()
        marker.position = locationCoordinate
        marker.icon = image
        marker.title = title
        marker.snippet = snippet
        marker.tracksViewChanges = true
        marker.tracksInfoWindowChanges = true
        marker.map = self
        cameraFocus(location: locationCoordinate)
        return marker
    }
    
    
    func setMarkerWithViewOnMap(locationCoordinate: CLLocationCoordinate2D, pinView: UIView, title: String, snippet: String) -> GMSMarker {
        
        let marker = GMSMarker()
        marker.position = locationCoordinate
        marker.iconView = pinView
        marker.title = title
        marker.snippet = snippet
        marker.tracksViewChanges = true
        marker.tracksInfoWindowChanges = true
        marker.map = self
        cameraFocus(location: locationCoordinate)
        return marker
    }
    
    
    //MARK: - Draw Circle
    func drawCircleOnLocation(coordinates: CLLocationCoordinate2D, radius: CLLocationDistance = 100, fillColor: UIColor = .clear, strokeColor: UIColor = .cyan, strokeWidth: CGFloat = 1.0) {
        
        let circle = GMSCircle(position: coordinates, radius: radius)
        circle.fillColor = fillColor.withAlphaComponent(0.5)
        circle.strokeColor = strokeColor
        circle.strokeWidth = strokeWidth
        circle.map = self
        cameraFocus(location: coordinates)
        
    }
    
    
    //MARk: - Object Move
    func moveObject(startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D, marker: GMSMarker) {
        let angle = self.getBearingBetweenTwoPoints(endCoordinate, point2: startCoordinate);

        marker.rotation = angle
        CATransaction.begin()
        CATransaction.setAnimationDuration(10.0)
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.position = endCoordinate
        CATransaction.commit()
    }
    
    // Car Rotation
    func getBearingBetweenTwoPoints(_ point1 : CLLocationCoordinate2D, point2 : CLLocationCoordinate2D) -> Double {
        
        // Returns a float with the angle between the two points
        //        let x = point1.longitude - point2.longitude
        //        let y = point1.latitude - point2.latitude
        let x1 = point1.latitude * .pi/180
        let x2 = point2.latitude * .pi/180
        let y1 = point1.longitude * .pi/180
        let y2 = point2.longitude * .pi/180
        
        let differenceLongitude = y2 - y1;
        
        let y = sin(differenceLongitude) * cos(x2)
        
        let x = cos(x1) * sin(x2) - sin(x1) * cos(x2) * cos(differenceLongitude)
        
        let theta_rad = atan2(y,x);
        
        var theta_deg = (theta_rad / .pi * 180)
        theta_deg  = ((theta_deg + 360).truncatingRemainder(dividingBy: 360)) + 90
        return theta_deg;
    }
}

//***************************************************************************************************************************************************

//MARK: - Find Address  Methods
extension MAGMSMapView {

    //Find Custome Location
    func findAddress(_ address: String!, withCompletionHandler completionHandler: @escaping ((_ status: String, _ success: Bool, _ locationCoordinates: CLLocationCoordinate2D, _ address: String, _ placeID: String) -> Void)) {
        
        if let lookupAddress = address {
            var geocodeURLString = baseURLGeocode + "address=" + lookupAddress
            geocodeURLString = geocodeURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let geocodeURL = URL(string: geocodeURLString)
            
            DispatchQueue.main.async(execute: { () -> Void in
                let geocodingResultsData = try? Data(contentsOf: geocodeURL!)
                
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: geocodingResultsData!, options: .mutableContainers) as! [String:Any]
                    let status = dictionary["status"] as! String
                    
                    if status == "OK" {
                        let allResults = dictionary["results"] as! [[String:Any]]
                        
                        var locationData = allResults[0]
                        let geometry = locationData["geometry"] as! [String:Any]
                        let location = geometry["location"] as! [String:Any]
                        let coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(truncating: location["lat"] as! NSNumber), longitude: CLLocationDegrees(truncating: location["lng"] as! NSNumber))
                        let address =  locationData["formatted_address"] as! String
                        let placeID =  locationData["place_id"] as! String
                        
                        completionHandler(status, true, coordinates, address, placeID)
                    } else {
                        completionHandler(status, false, CLLocationCoordinate2D(), "", "")
                    }
                } catch let error {
                    print(error)
                    completionHandler("", false, CLLocationCoordinate2D(), "", "")
                }
            })
        }
        else {
            completionHandler("No valid address.", false, CLLocationCoordinate2D(), "", "")
        }
    }
}


//***************************************************************************************************************************************************
//MARK: - Draw Route
extension MAGMSMapView {
    
    func getDirections(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: TravelModes = .driving, completionHandler: @escaping ((_ status: String, _ success: Bool, _ totalDistance: Double, _ TotalDuration: String, _ originCoordinates: CLLocationCoordinate2D, _ destinationCoordinates: CLLocationCoordinate2D) -> Void)) {
        
        if let originLocation = origin {
            if let destinationLocation = destination {
                var directionURLString = baseURLDirection + "origin=" + originLocation + "&destination=" + destinationLocation
                directionURLString = directionURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                
                if let routeWaypoints = waypoints {
                    directionURLString += "&waypoints=optimize:true"
                    
                    for waypoint in routeWaypoints {
                        directionURLString += "|" + waypoint
                    }
                }
                
                
                directionURLString += "&mode=" + travelMode.rawValue.description
                let directionURL = URL(string: directionURLString)
                
                DispatchQueue.main.async(execute: { () -> Void in
                    let directionData = NSData(contentsOf: directionURL!)
                    
                    do{
                        let dictionary = try JSONSerialization.jsonObject(with: directionData! as Data, options: .mutableContainers) as! [String:Any]
                        
                        let status = dictionary["status"] as! String
                        
                        if status == "OK" {
                            
                            let (routePolylines, routeLegs, originCoordinate, destinationCoordinate, originAddress, destinationAddress) = self.getRouteData(routeData: dictionary["routes"] as! [[String:Any]])
                            let (totalDistance, totalDuration) = self.calculateTotalDistanceAndDuration(routeLegs: routeLegs)
                            self.clear()
                            self.cameraFocus(location: originCoordinate)
                            
                            //Origin MArker
                            if self.originPinImage == nil {
                                _ = self.setDefaultMarkerOnMap(locationCoordinate: originCoordinate, title: originAddress, snippet: "")
                            } else {
                                _ = self.setMarkerWithImageOnMap(locationCoordinate: originCoordinate, image: self.originPinImage, title: originAddress, snippet: "")
                            }
                            //Destination MArker
                            if self.destinationPinImage == nil {
                                _ = self.setDefaultMarkerOnMap(locationCoordinate: destinationCoordinate, title: destinationAddress, snippet: "")
                            } else {
                                _ = self.setMarkerWithImageOnMap(locationCoordinate: destinationCoordinate, image: self.destinationPinImage, title: destinationAddress, snippet: "")
                            }
                            
                            
                            self.drawRoute(route: routePolylines["points"] as! String)
                            completionHandler(status, true, totalDistance, totalDuration, originCoordinate, destinationCoordinate)
                        }
                        else {
                            completionHandler(status, false, 0.0, "", self.dummyCoordinates, self.dummyCoordinates)
                        }
                    } catch let error{
                        print(error)
                        completionHandler("", false, 0.0, "", self.dummyCoordinates, self.dummyCoordinates)
                    }
                })
            }
            else {
                completionHandler("Destination is nil.", false, 0.0, "", self.dummyCoordinates, self.dummyCoordinates)
            }
        }
        else {
            completionHandler("Origin is nil", false, 0.0, "", self.dummyCoordinates, self.dummyCoordinates)
        }
    }
    
    //***************************************************************************************************************************************************
    func getRouteData(routeData: [[String:Any]]) -> ([String:Any], [[String:Any]], CLLocationCoordinate2D, CLLocationCoordinate2D, String, String) {
        let selectedRoute = routeData[0]
        let routePolylines = selectedRoute["overview_polyline"] as! [String:Any]
        
        let routeLegs = selectedRoute["legs"] as! [[String:Any]]
        
        let startLocation = routeLegs[0]["start_location"] as! [String:Any]
        let originCoordinate = CLLocationCoordinate2D(latitude: startLocation["lat"] as! Double, longitude: startLocation["lng"] as! Double)
        
        let endLocation = routeLegs[routeLegs.count - 1]["end_location"] as! [String:Any]
        let destinationCoordinate = CLLocationCoordinate2D(latitude: endLocation["lat"] as! Double, longitude: endLocation["lng"] as! Double)
        
        let originAddress = routeLegs[0]["start_address"] as! String
        let destinationAddress = routeLegs[routeLegs.count - 1]["end_address"] as! String
        
        return (routePolylines, routeLegs, originCoordinate, destinationCoordinate, originAddress, destinationAddress)
    }
    
    //***************************************************************************************************************************************************
    func calculateTotalDistanceAndDuration(routeLegs: [[String:Any]]) -> (Double, String) {
        
        var totalDistanceInMeters = 0
        var totalDurationInSeconds = 0
        
        for leg in routeLegs {
            totalDistanceInMeters += (leg["distance"] as! [String:Any])["value"] as! Int
            totalDurationInSeconds += (leg["duration"] as! [String:Any])["value"] as! Int
        }
        let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
    
        let mins = totalDurationInSeconds / 60
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = totalDurationInSeconds % 60
        
        let totalDuration = "Duration: \(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"
        return (distanceInKilometers, totalDuration)
    }
    
    //***************************************************************************************************************************************************
    func drawRoute(route: String) {
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        let routePolyline = GMSPolyline(path: path)
        routePolyline.strokeWidth = 5.0
        routePolyline.strokeColor = .green
        //Gradient Route
//        let redYellow = GMSStrokeStyle.gradient(from: .green, to: .cyan)
//        routePolyline.spans = [GMSStyleSpan(style: redYellow)]
        
        //Show Directions
        routePolyline.geodesic = true
        
        routePolyline.map = self
    }
    //***************************************************************************************************************************************************
//    func configureMapAndMarkersForRoute(originCoordinate: CLLocationCoordinate2D, originPinImage: UIImage, originAddress: String, ) {
//        
//        if wayPoints.count > 0 {
//            for waypoint in wayPoints {
//                let lat : Double = (waypoint.components(separatedBy: ",")[0] as NSString).doubleValue
//                let lng : Double = (waypoint.components(separatedBy: ",")[1] as NSString).doubleValue
//                
//                let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
//                marker.map = mapView
//                //marker.icon = GMSMarker.markerImage(with: UIColor.purple)
//                marker.icon = UIImage(named: "MiddlePin")
//                
//                markerArray.append(marker)
//            }
//        }
//    }
}



//MARK: - CLLocationManagerDelegate Methods
extension MAGMSMapView: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            cameraFocus(location: location.coordinate, zoomLevel: 10.0)
            locationManager.stopUpdatingLocation()
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
