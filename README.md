# MAGoogleMaps

MAGoogleMaps is a simple map project in which Gooogle maps in extended and now its easy to use

### How To Use

* Just Drag and drop **MAGMSMapView.swift** in your project 
* Drag **UIVIew** in a UIViewController and give it custom class like:

![screen shot 2018-07-23 at 8 12 43 pm](https://user-images.githubusercontent.com/20382262/43085630-e0d9acc0-8eb4-11e8-8fc0-a375a22cb416.png)


### Functionalities 

- [Current Location](#current-location)
- [Map Types](#map-types)
- [Pin On Map](#pin-on-map)
    - [Default](#default)
    - [With custom image](#with-custom-image)
    - [With custom View](#with-custom-view)
- [Draw Circle on given location](#draw-circle-on-given-location)
- [Find Address](#find-address)
- [Draw Route](#draw-route)
- [Move Object](#move-object)


### Current Location

```swift
self.mapView.currentLocation()
```

### Map Types

```swift
self.present(self.mapView.mapTerrin(), animated: true, completion: nil)
```

### Pin On Map
    
Default
```swift
_ = self.mapView.setDefaultMarkerOnMap(locationCoordinate: self.location[0].locationCoordinate, title:  self.location[0].name, snippet:  self.location[0].countryName)
```
With Custom Image
```swift
_ = self.mapView.setMarkerWithImageOnMap(locationCoordinate:  self.location[1].locationCoordinate, image: #imageLiteral(resourceName: "GooglePin"), title: self.location[1].name, snippet: self.location[1].countryName)
```
With Custom View
```swift
 let pinView = MapPinView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
 _ = self.mapView.setMarkerWithViewOnMap(locationCoordinate: self.location[2].locationCoordinate, pinView: pinView, title: self.location[2].name, snippet: self.location[2].countryName)
```

### Draw Circle on given location

```swift
self.mapView.drawCircleOnLocation(coordinates: self.location[0].locationCoordinate)
self.mapView.drawCircleOnLocation(coordinates: self.location[1].locationCoordinate, radius: 200, fillColor: .blue, strokeColor: .brown, strokeWidth: 2.0)
```

### Find Address

```swift
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
```

### Draw Route

```swift
self.mapView.originPinImage = #imageLiteral(resourceName: "Pin1")
            self.mapView.destinationPinImage = #imageLiteral(resourceName: "Pin2")
            self.mapView.getDirections(origin: origin, destination: destination, waypoints: nil, travelMode: TravelModes.driving, completionHandler: { (status, success, totalDistance, totalDuration, originCoordinates, destinationCoordinates) in
                self.originCoordinates = originCoordinates
                self.destinationCoordinates = destinationCoordinates
            })
```

### Move Object

```swift
let moveAbleMarker = self.mapView.setMarkerWithImageOnMap(locationCoordinate: self.originCoordinates, image: #imageLiteral(resourceName: "Pin3"), title: "", snippet: "")
self.mapView.moveObject(startCoordinate: self.originCoordinates, endCoordinate: self.destinationCoordinates, marker: moveAbleMarker)
```
