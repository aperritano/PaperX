//
//  AppDelegate.swift
//  PaperX
//
//  Created by Anthony Perritano on 3/3/16.
//  Copyright © 2016 so.raven. All rights reserved.
//

import UIKit
import CoreData
import RandomKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    var dataController: DataController!
    let container = CKContainer.defaultContainer()
    let fileManager = NSFileManager()
    var userDefaults = NSUserDefaults.standardUserDefaults()
    var documentURL: NSURL?
    var ubiquityURL: NSURL?
    var metaDataQuery: NSMetadataQuery?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        dataController = DataController()
        
        if application.isRegisteredForRemoteNotifications() == false {
            print("Not registered for push notifications. Registering now...")
            let settings = UIUserNotificationSettings(forTypes: [.Alert,.Badge],
                                                      categories: nil)
            print("Requesting change to user notification settings...")
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        

        
        dispatch_async(dispatch_get_global_queue(Int(DISPATCH_QUEUE_PRIORITY_DEFAULT), 0)) {
            if let iCloud = self.fileManager.URLForUbiquityContainerIdentifier(nil) {
                
                self.ubiquityURL = iCloud
                self.ubiquityURL  = self.ubiquityURL!.URLByAppendingPathComponent("Documents")

                
                print("icloud \(self.ubiquityURL)")
                
                self.metaDataQuery = NSMetadataQuery()
                
                self.metaDataQuery?.predicate =
                    NSPredicate(format: "%K like 'savefile.txt'",
                                NSMetadataItemFSNameKey)
                self.metaDataQuery?.searchScopes =
                    [NSMetadataQueryUbiquitousDocumentsScope]
                
           
                
                self.metaDataQuery!.startQuery()
                
                dispatch_async(dispatch_get_main_queue(), {
                    print("do stuff")// doesn't exist
                })
            } else {
                print("not icloud")// doesn't exist
            }
        }
    
        
    
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(AppDelegate.applicationBecameActive(_:)),
                                                         name: UIApplicationDidBecomeActiveNotification,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(AppDelegate.applicationBecameInactive(_:)),
                                                         name: UIApplicationWillResignActiveNotification,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(AppDelegate.iCloudAccountAvailabilityChanged(_:)),
                                                         name: NSUbiquityIdentityDidChangeNotification,
                                                         object: nil)
        

        
        
  
        
        
        
        NSUbiquitousKeyValueStore.defaultStore().synchronize()
        return true
    }
    
    func startQuery(){
        print("Starting the query now...")
        
        metaDataQuery!.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        let predicate = NSPredicate(format: "%K like %@",
                                    NSMetadataItemFSNameKey,
                                    "*.*")
        
        metaDataQuery!.predicate = predicate
        if metaDataQuery!.startQuery() {
            NSNotificationCenter.defaultCenter().addObserver(self,
                                                             selector: Selector("metadataQueryDidFinishGathering:"),
                                                             name: NSMetadataQueryDidFinishGatheringNotification,
                                                             object: metaDataQuery!)
            print("Successfully started the query.")
        } else {
            print("Failed to start the query.")
        }
    }
    
    
    //MARK: - iCloud
    
    func handleIdentityChanged(notification: NSNotification){
        if let currentiCloudToken = fileManager.ubiquityIdentityToken {
            print("The new token is \(currentiCloudToken)")
            let newTokenData = NSKeyedArchiver.archivedDataWithRootObject(currentiCloudToken)
            userDefaults.setObject(newTokenData, forKey: "so.raven.PaperX.UbiquityIdentityToken")
        } else {
            print("User has logged out of iCloud")
            userDefaults.removeObjectForKey("so.raven.PaperX.UbiquityIdentityToken")
        }
    }
   
    func iCloudAccountAvailabilityChanged(notification: NSNotification){
        print("iCloudAccountAvailabilityChanged")
    }
    
    /* Just a little method to help us display alert dialogs to the user */
    func displayAlertWithTitle(title: String, message: String){
        
        print(message)
        
//        dispatch_async(dispatch_get_main_queue(), {
//            let controller = UIAlertController(title: title,
//                message: message,
//                preferredStyle: .Alert)
//            
//            controller.addAction(UIAlertAction(title: "OK",
//                style: .Default,
//                handler: nil))
//            self.window?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
//        })
        
    }
    
  
    /* Start listening for iCloud user change notifications */
    func applicationBecameActive(notification: NSNotification){
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(AppDelegate.handleIdentityChanged(_:)),
                                                         name: NSUbiquityIdentityDidChangeNotification,
                                                         object: nil)
    }
    
    /* Stop listening for those notifications when the app becomes inactive */
    func applicationBecameInactive(notification: NSNotification){
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: NSUbiquityIdentityDidChangeNotification,
                                                            object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func application(application: UIApplication,  didReceiveRemoteNotification: [NSObject : AnyObject],
                     fetchCompletionHandler: (UIBackgroundFetchResult) -> Void) {
        print("recieved remote")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError){
        print("Failed to receive remote notifications \(error)")
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("Successfully registered for remote notifications")
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
}

