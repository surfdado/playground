//
//  AlertAnnotation.swift
//  Float Control
//
//  Created by Davorin Mista on 10/31/21.
//

import Foundation
import MapKit

class PosAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var vescstate: UInt

    init(coordinate: CLLocationCoordinate2D, vescstate: UInt)
    {
        self.coordinate = coordinate
        self.vescstate = vescstate
    }
    func setCoordinate(coord: CLLocationCoordinate2D) {
        coordinate = coord
    }
}

class AlertAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D

    init(title: String?,
         subtitle: String?,
         coordinate: CLLocationCoordinate2D)
    {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        //self.incident = incident
    }
}
