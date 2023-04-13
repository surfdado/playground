//
//  MapView.swift
//  Float Control
//
//  Created by Davorin Mista on 10/30/21.
//

import SwiftUI
import MapKit
import AVFoundation

struct MapView: UIViewRepresentable {
    @EnvironmentObject var locationMgr: LocationManager
    var isActiveRide: Bool
    @State private var chartLocation = PosAnnotation(coordinate: CLLocationCoordinate2D(), vescstate: 1)

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.isPitchEnabled = false
        mapView.delegate = context.coordinator
        if (isActiveRide) {
            mapView.showsUserLocation = true
            mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
        }
        let line = locationMgr.polyLine(regenerate: true)
        mapView.addOverlays(line)
        mapView.addAnnotations(locationMgr.alerts)
        mapView.addAnnotations(locationMgr.newAlerts)
        locationMgr.hasInitialAlerts = false
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        //If you changing the Map Annotation then you have to remove old Annotations
        //mapView.removeAnnotations(mapView.annotations)
        AudioServicesPlayAlertSound(SystemSoundID(1103))

        if locationMgr.alerts.isEmpty && locationMgr.loadedLocations.isEmpty && locationMgr.newAlerts.isEmpty && locationMgr.addedLocations.isEmpty {
            // trip restarted?
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
        }
        if locationMgr.hasInitialAlerts {
            mapView.addAnnotations(locationMgr.alerts)
            locationMgr.hasInitialAlerts = false
        }
        if locationMgr.hasNewAlerts() {
            mapView.addAnnotations(locationMgr.popNewAlerts())
        }
        let line = locationMgr.polyLine(regenerate: locationMgr.hasInitialLocations)
        locationMgr.hasInitialLocations = false
        mapView.addOverlays(line)

        if isActiveRide {
            // set region automatically to track the current ride
            mapView.setRegion(locationMgr.region, animated: true)
        }
        else {
            // let the user change region as needed
            if locationMgr.userSpan != nil {
                //let span = locationMgr.userSpan!
                //let region = MKCoordinateRegion(center: mapView.centerCoordinate, span: span)
                //mapView.setRegion(span, animated: true)
            } else {
                mapView.setRegion(locationMgr.region, animated: true)
            }
        }
        mapView.showsScale = locationMgr.isLarge
        mapView.showsCompass = locationMgr.isLarge
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    private let locationMgr = LocationManager.shared
    private var modifyingMap = false

    init(_ parent: MapView) {
        self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //Custom View for Annotation
        guard let annotation = annotation as? AlertAnnotation else {
            guard let annotation = annotation as? PosAnnotation else {
                return nil
            }
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customView")
            annotationView.canShowCallout = false
            annotationView.isEnabled = true
            if (annotation.vescstate == 2) || (annotation.vescstate == 3) || (annotation.vescstate == 4) {
                annotationView.image = UIImage(named: "tiltbackPin")
            } else {
                annotationView.image = UIImage(named: "cruisePin")
            }
            return annotationView
        }
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customView")
        annotationView.canShowCallout = true
        annotationView.isEnabled = true

        let btn = UIButton(type: .detailDisclosure)
        annotationView.rightCalloutAccessoryView = btn
        annotationView.image = UIImage(named: "alertPin")
        return annotationView
     }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.systemBlue
            renderer.lineWidth = 6
            return renderer
        }
        return MKOverlayRenderer()
    }

    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        locationMgr.userSpan = mapView.region//.span
        let span = mapView.region.span
        let s: Double = (abs(span.latitudeDelta) + abs(span.longitudeDelta)) / 2
        DispatchQueue.main.async {
            if self.parent.isActiveRide {
                self.locationMgr.region = mapView.region
                self.locationMgr.setspan(s: s)
            }
            else {
                self.locationMgr.setspan(s: s + 1)
            }
        }
    }
/*        if nextRegionChangeIsFromUserInteraction {
            nextRegionChangeIsFromUserInteraction = false;
            locationMgr.userSpan = mapView.region.span
        }
    }
    
    var nextRegionChangeIsFromUserInteraction = false
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if let view = mapView.subviews.first {
            for recognizer in view.gestureRecognizers ?? [] {
                if (recognizer.state == .began || recognizer.state == .ended) {
                    nextRegionChangeIsFromUserInteraction = true;
                    break;
                }
            }
        }
    }
    */
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        /*if nextRegionChangeIsFromUserInteraction {
            nextRegionChangeIsFromUserInteraction = false;
            locationMgr.userSpan = mapView.region.span
        }*/
        
        // enforce maximum zoom level
        if (mapView.camera.altitude < 130.00 && !modifyingMap) {
            modifyingMap = true // prevents strange infinite loop case

            mapView.camera.altitude = 130.00

            modifyingMap = false
        }
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? AlertAnnotation else {
            return
        }
        locationMgr.alertTitle = "alert"
        locationMgr.alertMessage = "bla bla details"
        locationMgr.showAlertDetails = true
    }
}
