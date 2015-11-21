//
//  HandleDataMethodsExtension.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/3/18.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import CoreLocation
import MapKit


extension FlightPlan
{
    class func fisrtFlightPlan(origin: String = "", destination: String = "" ,context:NSManagedObjectContext) -> FlightPlan?
    {
        var plan:FlightPlan?
        
        let request:NSFetchRequest = NSFetchRequest(entityName: "FlightPlan")
        request.predicate = NSPredicate(format: "name = %@", "ACTFPLN")
        var error:NSError?
        
        do {
            let matches = try context.executeFetchRequest(request)
            if error != nil || matches.count > 1 {
                //handle error here
            } else if matches.count == 1 {
                plan = matches.last as? FlightPlan
                if origin != "" {
                    plan?.origin = origin
                } else if destination != "" {
                    plan?.destination = destination
                }

            } else {
                plan = NSEntityDescription.insertNewObjectForEntityForName("FlightPlan", inManagedObjectContext: context) as? FlightPlan
                plan?.name = "ACTFPLN"
                plan?.origin = origin
                plan?.destination = destination
                plan?.takeoff = ""
                plan?.departure = ""
                plan?.arrive = ""
                plan?.approach = ""
                plan?.flightNO = ""
            }
        } catch let error1 as NSError {
            error = error1
        }
        
        
        if plan?.origin != "" && plan?.destination != ""{
            if let a1 = Airport.airport(name: plan!.origin, context: context) , a2 = Airport.airport(name: plan!.destination, context: context) {
                plan?.distance = FlightPlan.distance(latitude1: a1.latitude.doubleValue, longitude1: a1.longitude.doubleValue, latitude2: a2.latitude.doubleValue, longitude2: a2.longitude.doubleValue)
            }
        } else if plan?.origin == plan?.destination && plan?.origin != "" {
            plan?.distance = 0
        } else {
            plan?.setNilValueForKey("distance")
        }

        return plan
    }
    
        class func distance(latitude1 latitude1:Double, longitude1:Double, latitude2:Double, longitude2:Double) -> Double
    {
        let location1 = CLLocation(latitude: latitude1, longitude: longitude1)
        let location2 = CLLocation(latitude: latitude2, longitude: longitude2)
        let distance = location1.distanceFromLocation(location2)

        return round(distance / 1852)
    }
    
    //prepare procedure waypoint for legs
    func  star()-> [Waypoint]?   {
        if let procedure = Procedure.procedure(name: self.arrive, airport: nil, isDep: nil, infoDictionary: nil, context: self.managedObjectContext!) {
                return procedure.waypoint.array as? [Waypoint]
            }
        return nil
    }
    
    func dep()-> [Waypoint]? {
        if let procedure = Procedure.procedure(name: self.departure, airport: nil, isDep: nil, infoDictionary: nil, context: self.managedObjectContext!) {
            return procedure.waypoint.array as? [Waypoint]
        }
        return nil
    }
    
    func app()-> [Waypoint]? {
        if let destAirport = Airport.airport(name: self.destination, context: self.managedObjectContext!) {
            if let approach = Procedure.procedure(name: self.destination + self.approach, airport: destAirport, isDep: false, infoDictionary: nil, context: self.managedObjectContext!) {
                    return approach.waypoint.array as? [Waypoint]
            }
        }
        return nil
    }
}



extension Airport
{
    class func validatingData(airport: String) -> String?
    {
        if let path = NSBundle.mainBundle().pathForResource("Airport", ofType: "plist") {
            if let data = NSDictionary(contentsOfFile: path) {
                if data[airport] != nil {
                    return nil
                }
            }
        }
        return "INVALID INPUT"
    }

    class func airport(name name: String, context: NSManagedObjectContext) -> Airport?
    {
        var airport:Airport?
        
        let request:NSFetchRequest = NSFetchRequest(entityName: "Airport")
        request.predicate = NSPredicate(format: "name = %@", name)
        var error:NSError?

        do {
            let matches = try context.executeFetchRequest(request)
            if error != nil || matches.count > 1 {
                //handle error here
            } else if matches.count == 1 {
                airport = matches.last as? Airport
            } else if let path = NSBundle.mainBundle().pathForResource("Airport", ofType: "plist") {
                if let data = NSDictionary(contentsOfFile: path) {
                    if let airportInfo = data[name] as? NSDictionary  {
                        airport = NSEntityDescription.insertNewObjectForEntityForName("Airport", inManagedObjectContext: context) as? Airport
                        airport?.name = name

                        //coordinate
                        if let x = airportInfo["Latitude"] as? Double , y = airportInfo["Longitude"] as? Double {
                            airport?.latitude = x
                            airport?.longitude = y
                        }
                        //procedue
                        //departure
                        if let departures = airportInfo["Departure"] as? NSDictionary {
                            for departure in departures.allKeys as! [String]  {
                                Procedure.procedure(name: departure, airport: airport!, isDep: true, infoDictionary: departures[departure] as? [String:AnyObject], context: context)
                            }

                        }
                        //arrival
                        if let arrives = airportInfo["Arrive"] as? NSDictionary {
                            for arrive in arrives.allKeys as! [String]  {
                                Procedure.procedure(name: arrive, airport: airport!, isDep: false, infoDictionary:arrives[arrive] as? [String:AnyObject], context: context)
                            }
                        }
                    }
                }
            }
        } catch let error1 as NSError {
            error = error1
        }
        return airport
    }
    
    
    func addProcedureObject(value: Procedure)
    {
        let items = self.mutableSetValueForKey("procedures")
        items.addObject(value)
    }
    
    func addProcedureObjects(values:[Procedure])
    {
        let items = self.mutableSetValueForKey("procedure")
        items.addObjectsFromArray(values)
    }
    
    func removeProcedureObject(value:Procedure)
    {
        let items = self.mutableSetValueForKey("procedure")
        items.removeObject(value)
    }
   
}

extension Waypoint
{

    class func waypoint(name name: String, context: NSManagedObjectContext) -> Waypoint?
    {
        var point:Waypoint?
        
        let request:NSFetchRequest = NSFetchRequest(entityName: "Waypoint")
        request.predicate = NSPredicate(format: "name = %@", name)
        var error:NSError?
        do {
            let matches = try context.executeFetchRequest(request)
            if error != nil || matches.count > 1 {
                //handle error here
            } else if matches.count == 1 {
                point = matches.last as? Waypoint
            } else if let path = NSBundle.mainBundle().pathForResource("Waypoint", ofType: "plist") {
                if let data = NSDictionary(contentsOfFile: path) {
                    if let pointInfo = data[name] as? NSDictionary  {
                        point = NSEntityDescription.insertNewObjectForEntityForName("Waypoint", inManagedObjectContext: context) as? Waypoint
                        
                        point?.name = pointInfo["Name"] as! String
                        
                        if let latitude = pointInfo["Latitude"] as? Double ,longitude = pointInfo["Longitude"] as? Double {
                            point?.latitude = latitude
                            point?.longitude = longitude
                        }
                        
                        if let isAiport = pointInfo["isAirport"] as? Bool {
                            point?.isAirport = isAiport
                        }
                    }
                }
            }
        } catch let error1 as NSError {
            error = error1
        }
        return point
    }
    
    
    
    class func legInfo(firstPoint first: Waypoint, secondPoint second: Waypoint) -> (heading: Double, distance: Double) {

        let lgt1 = first.longitude.doubleValue.radians
        let lat1 = first.latitude.doubleValue.radians
        let lgt2 = second.longitude.doubleValue.radians
        let lat2 = second.latitude.doubleValue.radians
        
        let ΔLongitude = lgt2 - lgt1
        
        var headingAngle = atan2(sin(ΔLongitude),cos(lat1) * tan(lat2) - sin(lat1) * cos(ΔLongitude)).degree
        
        if headingAngle < 0 {
            headingAngle = headingAngle + 360
        }
        
        let location1 = CLLocation(latitude: first.latitude.doubleValue, longitude: first.longitude.doubleValue)
        let location2 = CLLocation(latitude: second.latitude.doubleValue, longitude: second.longitude.doubleValue)
        let distance = location1.distanceFromLocation(location2)
        
        return (headingAngle , distance / 1852)
    }
    
    func createWaypointWith(bearing: Double, distance: Double, name:String) -> Waypoint? {
    
        
        let radius =  6371.393 * 1000
        let lgt1 = self.longitude.doubleValue.radians
        let lat1 = self.latitude.doubleValue.radians
        let α = bearing.radians
        //calculate the node A - the point at which the great circle crosses the equator in the northward direction
        let bearing0 = asin(sin(α)*cos(lat1))
        let distance01 = atan2(tan(lat1),cos(α))
        let lgt01 = atan2(sin(α)*cos(lat1)*sin(distance01),cos(distance01))
        let lgt0 = lgt1 - lgt01
        
        //calculate arbitary point with bearing and distance
        let dis = distance01 + distance * 1852 / radius
        
        var lat2 = asin(cos(bearing0)*sin(dis)).degree
        var lgt2 = (atan2(sin(bearing0)*sin(dis), cos(dis)) + lgt0).degree
        
        if lat2 < -90 {
            lat2 = lat2 + 180
        } else if lat2 > 90 {
            lat2 = lat2 - 180
        }
        
        if lgt2 < -180 {
            lgt2 = lgt2 + 360
        } else if lgt2 > 180 {
            lgt2 = lgt2 - 360
        }
        
        let point = NSEntityDescription.insertNewObjectForEntityForName("Waypoint", inManagedObjectContext: self.managedObjectContext!) as? Waypoint
        point?.name = name
        point?.latitude = lat2
        point?.longitude = lgt2
        point?.isCreatedByPilot = true
        
        return  point
    }
    
    func createWaypoint(bearing1:Double,antherWaypoint point:Waypoint,bearing2:Double, name:String) ->Waypoint? {
        
        let k1 = tan(-bearing1.radians+M_PI_2).cgfloat
        let k2 = tan(-bearing2.radians+M_PI_2).cgfloat
        //let p1 = CGPointZero
        let p2 = point.mapPoint - self.mapPoint
        if k1 != k2 {
            let x = (p2.y + k2*p2.x)/(k1-k2)
            let y = x*k1
            let newMapPoint = CGPointMake(x, y) + self.mapPoint
            let coordinate = newMapPoint.coordinate
            let point = NSEntityDescription.insertNewObjectForEntityForName("Waypoint", inManagedObjectContext: self.managedObjectContext!) as? Waypoint
            point?.name = name
            point?.isCreatedByPilot = true
            point?.latitude = coordinate.latitude
            point?.longitude = coordinate.longitude
            return point
        }
        return nil
    }
    
    func createWaypoint(latitude:Double,longitude:Double,name:String) -> Waypoint? {
        let point = NSEntityDescription.insertNewObjectForEntityForName("Waypoint", inManagedObjectContext: self.managedObjectContext!) as? Waypoint
        point?.name = name
        point?.latitude = latitude
        point?.longitude = longitude
        point?.isCreatedByPilot = true

        return point
    }
    
    var mapPoint:CGPoint {
        let coordinate = CLLocationCoordinate2DMake(self.latitude.doubleValue,self.longitude.doubleValue )
        let mkMapPoint = MKMapPointForCoordinate(coordinate)
        let point = CGPointMake(mkMapPoint.x.cgfloat / SCALE_FACTOR.cgfloat,-mkMapPoint.y.cgfloat / SCALE_FACTOR.cgfloat)
        return point
    }

    
}

extension Runaway
{

    class func runaway(name name: String, airport:Airport, isDep:Bool? = nil, context: NSManagedObjectContext) -> Runaway?
    {
        var runaway:Runaway?
        let request:NSFetchRequest = NSFetchRequest(entityName: "Runaway")
        request.predicate = NSPredicate(format: "unique = %@", airport.name + name)
        var error:NSError?

        do {
            let matches = try context.executeFetchRequest(request)
            if error != nil || matches.count > 1 {
                //handle error here
            } else if matches.count == 1 {
                runaway = matches.last as? Runaway
            } else if isDep != nil {
                runaway = NSEntityDescription.insertNewObjectForEntityForName("Runaway", inManagedObjectContext: context) as? Runaway
                runaway!.unique = airport.name + name
                runaway!.name = name
                runaway!.airport = airport
                runaway!.isDepatrure = isDep!
                
                if let path = NSBundle.mainBundle().pathForResource("Runaway", ofType: "plist") {
                    if let data = NSDictionary(contentsOfFile: path) {
                        if let runawayData = data.valueForKeyPath("\(airport.name).\(name)") as? NSDictionary {
                            //runaway!.heading = runawayData["Heading"] as! NSNumber
                            runaway!.length = runawayData["Length"] as! NSNumber
                        }
                    }
                }
            }
        } catch let error1 as NSError {
            error = error1
        }
        return runaway
    }
}

extension Procedure
{
    class func procedure(name name: String, airport:Airport? = nil, isDep:Bool? = nil, infoDictionary: [String:AnyObject]? = nil, context: NSManagedObjectContext) -> Procedure?
    {
        var procedure:Procedure?
        let request:NSFetchRequest = NSFetchRequest(entityName: "Procedure")
        request.predicate = NSPredicate(format: "name = %@", name)
        var error:NSError?
        do {
            let matches = try context.executeFetchRequest(request)
            if error != nil || matches.count > 1 {
                //handle error here
            } else if matches.count == 1 {
                procedure = matches.last as? Procedure
            } else if airport != nil {
                procedure = NSEntityDescription.insertNewObjectForEntityForName("Procedure", inManagedObjectContext: context) as? Procedure
                procedure?.name = name
                procedure?.airport = airport!
                procedure?.isDeparture = isDep ?? true
                //add waypoints
                if let path = NSBundle.mainBundle().pathForResource("Procedure", ofType: "plist") {
                    if let data = NSDictionary(contentsOfFile: path) {
                        if let points = data[name] as? [String]  {
                            for pointName in points {
                                if let point = Waypoint.waypoint(name: pointName, context: context) {
                                    procedure?.addPointObject(point)
                                }
                            }
                        }
                    }
                }
                
                if infoDictionary != nil{
                    for runawayInfo in infoDictionary! {
                        if let approches = runawayInfo.1 as? [String] {
                            for approch in approches {
                                if let runaway = Runaway.runaway(name:approch, airport: airport!, isDep:false, context: context) {
                                    procedure?.addRunawayObject(runaway)
                                }
                            }
                        } else if let runaway = Runaway.runaway(name:runawayInfo.0, airport:airport!,isDep:true, context: context) {
                            procedure?.addRunawayObject(runaway)
                        }
                    }
                }
            }
        } catch let error1 as NSError {
            error = error1
        }
        return procedure
    }

    func addRunawayObject(value: Runaway)
    {
        let items = self.mutableOrderedSetValueForKey("runaway")
        items.addObject(value)
    }
    
    func addPointObject(value: Waypoint)
    {
        let items = self.mutableOrderedSetValueForKey("waypoint")
        items.addObject(value)
    }
    
}



