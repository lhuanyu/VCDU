//
//  PerformanceExtension.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/7.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import Foundation
import CoreData


extension Performance
    
{
    class func performance(plan plan:FlightPlan, context: NSManagedObjectContext) -> Performance? {
        var performance: Performance?
        let request:NSFetchRequest = NSFetchRequest(entityName: "Performance")
        request.predicate = NSPredicate(format: "unique = %@", plan.name)
        do {
            let matches = try context.executeFetchRequest(request)
            if matches.count > 1 {
                
            } else if matches.count == 1 {
                performance = matches.last as? Performance
            } else {
                performance = NSEntityDescription.insertNewObjectForEntityForName("Performance", inManagedObjectContext: context) as? Performance
                performance!.unique = plan.name
                Performance.n1Limit(performance!, context: context)
                Performance.vnav(performance!, context: context)
                Performance.takeoff(performance!, context: context)

            }
        } catch let error as NSError {
            error.isProxy()
            //handle error here
        }
        
        return performance
    }

    
    class func takeoff(performance:Performance,context:NSManagedObjectContext) -> Takeoff? {
        
        if let takeoff = NSEntityDescription.insertNewObjectForEntityForName("Takeoff", inManagedObjectContext: context) as? Takeoff {
            takeoff.performance = performance
            return takeoff
        }
        
        return nil
    }
    
    class func vnav(performance:Performance,context:NSManagedObjectContext) -> Vnav? {
        
        if let vnav = NSEntityDescription.insertNewObjectForEntityForName("Vnav", inManagedObjectContext: context) as? Vnav {
            vnav.performance = performance
            return vnav
        }
        
        return nil
    }

    
    class func n1Limit(performance:Performance,context:NSManagedObjectContext) -> N1Limit? {
        
        if let n1Limit = NSEntityDescription.insertNewObjectForEntityForName("N1Limit", inManagedObjectContext: context) as? N1Limit {
            n1Limit.performance = performance
            return n1Limit
        }
        
        return nil
    }
    
    



    



    

    
}