//
//  WCMDataController.swift
//  WhoCallMe
//
//  Created by 영준 이 on 2016. 3. 13..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit
import CoreData

class WCMDataController: NSObject {
    struct EntityNames{
        static let OriginalContract = "OriginalContract";
    }
    
    static let shared = WCMDataController();
    
    var context : NSManagedObjectContext;
    static var modelName : String = "WhoCallMe";
    
    override init(){
        // MARK: prepare data model - get path for database model file
        //xcdatamodel => momd??
        guard let model_path = Bundle.main.url(forResource: type(of: self).modelName, withExtension: "momd") else{
            fatalError("Can not find Model File from Bundle");
        }
        
        //load model from model file
        guard let model = NSManagedObjectModel(contentsOf: model_path) else {
            fatalError("Can not load Model from File");
        }
        
        //create store controller?
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model);
        
        //create data context
        self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType);
        self.context.retainsRegisteredObjects = false;
        self.context.undoManager = nil;
        
        //attach to data store
        self.context.persistentStoreCoordinator = psc;
        
        // MARK: open sqlite
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask);
        
        //get path for app's url
        let docUrl = urls.last;
        
        //create path for data file
        let storeUrl = docUrl?.appendingPathComponent("WhoCallMe.sqlite");
        do {
            //set store type?
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: nil);
            NSLog("Database is Loaded");
        } catch {
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
        Creates and returns new OriginalContract
         - returns: returns new OriginalContract
    */
    func createContact() -> OriginalContract{
        let contact : OriginalContract! =
            NSEntityDescription.insertNewObject(forEntityName: EntityNames.OriginalContract, into: self.context) as? OriginalContract;
        
        self.context.insert(contact);
        
        return contact;
    }
    
    /**
        Returns list of OriginalContract fetched with given options
         - parameter predicate: fetch option, if this is set to nil, all objects will be fetched.
         - parameter sortWays: sort key for fetched list
    */
    func loadContacts(_ predicate : NSPredicate? = nil, sortWays: [NSSortDescriptor]? = []) -> [OriginalContract]{
        var values : [OriginalContract] = [];
        
        let requester = NSFetchRequest<NSFetchRequestResult>(entityName: EntityNames.OriginalContract);
        requester.predicate = predicate;
        requester.sortDescriptors = sortWays;
        
        do{
            values = try self.context.fetch(requester) as! [OriginalContract];
        } catch let error{
            fatalError("Can not load Contact from DB. error[\(error)]");
        }
        
        return values;
    }
    
    /**
        Fetches a contact with given id
         - parameter id: id to fetch a contact
         - returns: a contact fetched with given id, returns nil if there is no contact has given id
    */
    func getContact(_ id : String) -> OriginalContract?{
        return self.loadContacts(NSPredicate(format: "id == %@", id)).first;
    }
    
    /**
        Returns count of objects fetched with given option
         - returns: Count of objects fetched with given option
    */
    func countForContacts(_ predicate : NSPredicate? = nil) -> Int{
        var value = 0;
        let requester = NSFetchRequest<NSFetchRequestResult>(entityName: EntityNames.OriginalContract);
        requester.predicate = predicate;
        
        do{
            value = try self.context.count(for: requester);
        } catch let error{
            fatalError("Can not get count of Contacts from DB. error[\(error)]");
        }
        
        return value;
    }
    
    /**
        Removes a contact from database
    */
    func removeContract(_ contact : OriginalContract){
        self.context.performAndWait {
            self.context.delete(contact);
        }
    }
    
    /**
        Store changed/new/ object, deletion of object to database
    */
    func saveChanges(){
        self.context.performAndWait {
            do{ 
                try self.context.save();
            } catch {
                fatalError("Save failed Error(\(error))");
            }
        }
    }
    
    /**
        Clear all fetched object and modification
    */
    func reset(){
        self.context.reset();
    }

}
