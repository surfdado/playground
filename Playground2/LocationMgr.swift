//
//  LocationMgr.swift
//  Float Control
//
//  Created by Davorin Mista on 10/29/21.
//

import UIKit
import CoreLocation
import AVFoundation
import MapKit
import CoreData

struct GPSData {
    var gps_lat_accuracy = 0.0
    var gps_vert_accuracy = 0.0
    var gps_speed_accuracy = 0.0
    var gps_latitude = 0.0
    var gps_longitude = 0.0
    var gps_speed = 0.0
    var gps_elevation_diff = 0.0
    var gps_altitude = 0.0
    var gps_course = 0.0
    var gps_distance = 0.0
    var gps_slope = 0.0
    var skipped = 0
    var count = 0
    var multi_loc = 0
    var isvalid = false
    var date = Date()
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    //let coreDataMgr = CoreDataManager.shared

    let cll = CLLocationManager()

    @Published var gps = GPSData()
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 36.953, longitude: -122.03), span: MKCoordinateSpan(latitudeDelta: 0.025,
                                                                                                                                           longitudeDelta: 0.025))
    @Published var isLarge = false

    var lastLocation = CLLocation()
    var loadedLocations: [CLLocation] = []
    var addedLocations: [CLLocation] = []
    var alerts: [AlertAnnotation] = []
    var newAlerts: [AlertAnnotation] = []
    var hasInitialAlerts = false
    var hasInitialLocations = false
    var isTracking = false
    var userSpan: MKCoordinateRegion? = nil
    var zoomFactor = 1.0
    @Published var spansize: Double = 0
    
    var lastDistanceDistance: Float = 0
    var lastDistanceLocLast = CLLocation()
    var lastDistanceLocNew = CLLocation()

    var elevationGained = 0.0
    var elevationLost = 0.0
    var lastSlope = 0.0
    var longMin = 0.0
    var longMax = 0.0
    var latMin = 0.0
    var latMax = 0.0

    var lineColorVariant = 0

    @Published var showAlertDetails = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    override init() {
        super.init()
        self.startLocationUpdates()
        self.highresUpdates(enable: true)
    }

    func polyLine(regenerate: Bool) -> [MKPolyline] {
        
        // 1
        //let locations = locationList?.array as! [Location]
        var coordinates: [(CLLocation, CLLocation)] = []
        var speeds: [Double] = []
        var minSpeed = 0.0
        var maxSpeed = 0.0

        // 2
        // loaded the save route first
        if (regenerate) {
            for (first, second) in zip(loadedLocations, loadedLocations.dropFirst()) {
                let start = CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude)
                let end = CLLocation(latitude: second.coordinate.latitude, longitude: second.coordinate.longitude)
                coordinates.append((start, end))
                
                let time = abs(first.timestamp.timeIntervalSince(second.timestamp))
                let isBreak = time > 60

                let speed = isBreak ? 0 : abs(second.speed)// time > 0 ? distance / time : 0
                speeds.append(speed)
            }
            // now load the newly added route
            for (first, second) in zip(addedLocations, addedLocations.dropFirst()) {
                let start = CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude)
                let end = CLLocation(latitude: second.coordinate.latitude, longitude: second.coordinate.longitude)
                coordinates.append((start, end))
                
                let time = abs(first.timestamp.timeIntervalSince(second.timestamp))
                let isBreak = time > 60

                let speed = isBreak ? 0 : second.speed// time > 0 ? distance / time : 0
                speeds.append(speed)
            }
        }
        else {
            if addedLocations.count > 0 {
                if let last = loadedLocations.last,
                   let first = addedLocations.first {
                    let start = CLLocation(latitude: last.coordinate.latitude, longitude: last.coordinate.longitude)
                    let end = CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude)
                    coordinates.append((start, end))

                    let time = abs(first.timestamp.timeIntervalSince(last.timestamp))
                    let isBreak = time > 60

                    let speed = isBreak ? 0 : first.speed// time > 0 ? distance / time : 0
                    speeds.append(speed)
                }
            }
            for (first, second) in zip(addedLocations, addedLocations.dropFirst()) {
                let start = CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude)
                let end = CLLocation(latitude: second.coordinate.latitude, longitude: second.coordinate.longitude)
                coordinates.append((start, end))
                    
                let time = abs(first.timestamp.timeIntervalSince(second.timestamp))
                let isBreak = time > 60

                let speed = isBreak ? 0 : second.speed// time > 0 ? distance / time : 0
                speeds.append(speed)
            }
        }
        updateRoute()

        //4
        minSpeed = 0
        maxSpeed = 10
        let midSpeed = 6.0 //speeds.reduce(0, +) / Double(speeds.count)
        
        //5
        var segments: [MKPolyline] = []
        for ((start, end), speed) in zip(coordinates, speeds) {
            let coords = [start.coordinate, end.coordinate]
            let segment = MKPolyline(coordinates: coords, count: 2)
            if speed != 0 {
                segments.append(segment)
            }
        }
        return segments
    }

    func setspan(s: Double) {
        spansize = s
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLoc = locations.last
        let count = locations.count
        if newLoc != nil{
            let loc = newLoc!
            let howRecent = loc.timestamp.timeIntervalSinceNow
            //AudioServicesPlayAlertSound(SystemSoundID(1051))

            guard loc.horizontalAccuracy < 20 && abs(howRecent) < 10 else {
                gps.skipped += 1
                return
            }
            if (!isTracking) {
                return
            }
            if (count > 1) {
                gps.multi_loc += 1
            }
            gps.count += 1
            gps.gps_lat_accuracy = loc.horizontalAccuracy
            gps.gps_vert_accuracy = loc.verticalAccuracy
            gps.gps_speed_accuracy = loc.speedAccuracy
            gps.gps_latitude = loc.coordinate.latitude
            gps.gps_longitude = loc.coordinate.longitude
            gps.gps_speed = loc.speed
            let elevation_diff = loc.altitude - gps.gps_altitude
            gps.gps_altitude = loc.altitude
            gps.gps_course = loc.course
            if gps.isvalid && (lastLocation != CLLocation(latitude: 36.953, longitude: -122.03)) {
                let last_distance = loc.distance(from: lastLocation)
                gps.gps_distance += last_distance
                if elevation_diff > 0 {
                    elevationGained += elevation_diff
                }
                else {
                    elevationLost += abs(elevation_diff)
                }
                gps.gps_slope = gps.gps_slope * 0.5 + (elevation_diff / last_distance) * 0.5
            }
            gps.isvalid = true
            
            latMin = min(latMin, gps.gps_latitude)
            latMax = max(latMax, gps.gps_latitude)
            longMin = min(longMin, gps.gps_longitude)
            longMax = max(longMax, gps.gps_longitude)
            let deltaLat = max(0.0001, latMax - latMin);
            let deltaLong = max(0.0001, longMax - longMin);
            var span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            var center = loc.coordinate

            if ((deltaLat > 0.005) || (deltaLong > 0.005)) {
            } else {
                center = CLLocationCoordinate2D(latitude: latMin + (latMax-latMin)/2,
                                                    longitude: longMin + (longMax-longMin)/2)
                span = MKCoordinateSpan(latitudeDelta: deltaLat * 1.05,
                                            longitudeDelta: deltaLong * 1.05)
            }

            if (userSpan != nil) {
                span = userSpan!.span
            }
            region = MKCoordinateRegion(center: center,
                                        span: MKCoordinateSpan(latitudeDelta: span.latitudeDelta,
                                                               longitudeDelta: span.longitudeDelta))

            lastLocation = loc
            addedLocations.append(loc)
        }
    }
    
    func highresUpdates(enable: Bool) {
        if enable {
            cll.distanceFilter = 5
        } else {
            cll.distanceFilter = 20
        }
    }

    func findUserLocation() {
        cll.delegate = self
        cll.requestLocation()
    }

    func stopLocationUpdates() {
        cll.stopUpdatingLocation()
        gps.isvalid = false
        isTracking = false
    }

    func startLocationUpdates() {
        if (isTracking) {
            //cll.startUpdatingLocation()
            return
        }
        if (cll.authorizationStatus != .authorizedAlways) && (cll.authorizationStatus != .authorizedWhenInUse) {
            print("No Permission")
            return
        }

        cll.delegate = self
        cll.activityType = .otherNavigation //.fitness
        cll.distanceFilter = 20
        cll.startUpdatingLocation()
        //print("allowsBackgroundLocationUpdates:")
        //print(cll.allowsBackgroundLocationUpdates)
        cll.allowsBackgroundLocationUpdates = true
        isTracking = true
    }
    
    func updateRoute() {
        loadedLocations += addedLocations
        addedLocations.removeAll()
    }

    func hasNewAlerts() -> Bool {
        return newAlerts.count > 0
    }
    func popNewAlerts() -> [MKAnnotation] {
        alerts.append(contentsOf: newAlerts)
        let popalerts = newAlerts
        newAlerts.removeAll()
        return popalerts
    }
    func resetView() {
        userSpan = nil
    }
    func restartTrip() {
        loadedLocations.removeAll()
        addedLocations.removeAll()
        alerts.removeAll()
        newAlerts.removeAll()
        hasInitialAlerts = false
        elevationGained = 0.0
        elevationLost = 0.0
        longMin = gps.gps_longitude
        longMax = gps.gps_longitude
        latMin = gps.gps_latitude
        latMax = gps.gps_latitude
        region = MKCoordinateRegion(center: lastLocation.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.0015,
                                                           longitudeDelta: 0.0015))
        gps = GPSData()
        userSpan = nil
    }
}
