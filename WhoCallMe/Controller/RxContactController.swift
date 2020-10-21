//
//  RxContactController.swift
//  WhoCallMe
//
//  Created by 영준 이 on 2018. 5. 8..
//  Copyright © 2018년 leesam. All rights reserved.
//

import Foundation
import RxSwift
import Contacts
import FirebaseCrashlytics

class RxContactController : NSObject{
    let contactStore = CNContactStore();
    static let shared = RxContactController();
    
    /**
         Requests authorization to access contacts
     */
    func requestAccess() -> Observable<Bool>{
        return Observable<Bool>.create({ (observer) -> Disposable in
            self.contactStore.requestAccess(for: .contacts) { (result, error) in
                if let error = error{
                    //emit error to allow to access contacts
                    Crashlytics.crashlytics().record(error: error);
                    observer.onError(error);
                    return;
                }
                
                observer.onNext(result);
                observer.onCompleted();
            }
            
            return Disposables.create();
        })
    }
    
    /**
        Requests contacts to fetch
    */
    func requestContacts(_ keysToFetch: [CNKeyDescriptor], identifiers: [String]? = nil) -> Observable<[CNContact]>{
        let containerID = self.contactStore.defaultContainerIdentifier();
        let predicate = identifiers != nil ? CNContact.predicateForContacts(withIdentifiers: identifiers!) : CNContact.predicateForContactsInContainer(withIdentifier: containerID);
        print("contacts predicate => \(predicate)");
        //let andPredicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [predicate, NSPredicate.init(format: "imageDataAvailable == true")]);
        
        print("Contacts Default Container ID[\(containerID)]");
        return Observable<[CNContact]>.create { [unowned self](observer) -> Disposable in
            do{
                let contacts = try self.contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch);
                //contacts.last?.imageDataAvailable
                observer.onNext(contacts);
                observer.onCompleted();
            }catch let error{
                Crashlytics.crashlytics().record(error: error);
                observer.onError(error);
            }
            
            return Disposables.create();
        }
    }
    
    /**
         Saves modification of given contact
         - parameter contact: contact to save modification
         - returns: returns result of saving, if result is true, saving is success, otherwise it is failed.
     */
    func save(_ contact : CNMutableContact) -> Observable<Bool>{
        return Observable<Bool>.create({ (observer) -> Disposable in
            let req = CNSaveRequest();
            
            do{
                req.update(contact);
                try self.contactStore.execute(req);
                observer.onNext(true);
                observer.onCompleted();
            }catch(let error){
                print("Contact saving is failed. error[\(error)]");
                Crashlytics.crashlytics().record(error: error);
                observer.onError(error);
            }
            
            return Disposables.create();
        })
    }
}
