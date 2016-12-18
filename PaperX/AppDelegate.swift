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
import XCGLogger
import GCDKit

let LOG: XCGLogger = {
    // Setup XCGLogger
    let LOG = XCGLogger.defaultInstance()
    LOG.xcodeColorsEnabled = true // Or set the XcodeColors environment variable in your scheme to YES
    LOG.xcodeColors = [
        .Verbose: .lightGrey,
        .Debug: .red,
        .Info: .darkGreen,
        .Warning: .orange,
        .Error: XCGLogger.XcodeColor(fg: UIColor.redColor(), bg: UIColor.whiteColor()), // Optionally use a UIColor
        .Severe: XCGLogger.XcodeColor(fg: (255, 255, 255), bg: (255, 0, 0)) // Optionally use RGB values directly
    ]
    return LOG
}()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    var dataController: DataController!
    let container = CKContainer.defaultContainer()
    let fileManager = NSFileManager()
    var documentsDirectory: String?
    var userDefaults = NSUserDefaults.standardUserDefaults()
    var documentURL: NSURL?
    var ubiquityURL: NSURL?
    var metaDataQuery: NSMetadataQuery?
    var containerURL: NSURL?
    
    
    func setupCloud() {
        containerURL = fileManager.URLForUbiquityContainerIdentifier(nil)
        
        
        if doesDocumentsDirectoryExist() {
            LOG.debug("This folder already exists.")
        } else {
            LOG.debug("Doesnt folder already exists.")
            //self.createDocumentsDirectory()
        }
        
        LOG.debug("DOES EXIST exist \(self.doesDocumentsDirectoryExist())")
    }
    
    func doesDocumentsDirectoryExist() -> Bool {
        var isDirectory = false as ObjCBool
        
        if let cUrl = containerURL {
            documentsDirectory = cUrl.path!.stringByAppendingString("/Documents")
            
            if let directory = documentsDirectory {
                if fileManager.fileExistsAtPath(directory,
                                                isDirectory: &isDirectory) {
                    if isDirectory {
                        return true
                    }
                }
            }
        }
     
        return false
    }
    
    
    func storeFile(fileName: String, fileContents: String, fileType: String) {
        LOG.debug("Storing a file in the directory...")
        if let directory = documentsDirectory {
            let path = directory.stringByAppendingString("/\(fileName).\(fileType)")
            
            
            LOG.debug("WRITING TO\(path)")
            
            GCDBlock.async(.Default) {
                do {
                    try fileContents.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
                } catch {
                    LOG.severe("ERROR WRITING \(fileName)")
                }
                }.notify(.Main) {
                    LOG.debug("Done write file: \(fileName)")
            }
            
            
        } else {
            LOG.debug("The directory was not found.")
        }
    }
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {


        application.statusBarHidden = true
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barStyle = .Black
        UINavigationBar.appearance().barTintColor = UIColor.blackColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        

        dataController = DataController()
        
        LOG.setup(.Debug, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLogLevel: .Debug)
        
        self.setupCloud()
        
        self.testData()
        
        if application.isRegisteredForRemoteNotifications() == false {
            LOG.debug("Not registered for push notifications. Registering now...")
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge],
                                                      categories: nil)
            LOG.debug("Requesting change to user notification settings...")
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        GCDBlock.async(.Default) {
            if let iCloud = self.fileManager.URLForUbiquityContainerIdentifier(nil) {
                
                self.ubiquityURL = iCloud
                self.ubiquityURL = self.ubiquityURL!.URLByAppendingPathComponent("Documents")
                
                
                LOG.debug("icloud \(self.ubiquityURL)")
                
                self.metaDataQuery = NSMetadataQuery()
                
                self.metaDataQuery?.predicate =
                    NSPredicate(format: "%K like 'savefile.txt'",
                        NSMetadataItemFSNameKey)
                self.metaDataQuery?.searchScopes =
                    [NSMetadataQueryUbiquitousDocumentsScope]
                
                
                
                self.metaDataQuery!.startQuery()
            } else {
                LOG.debug("not icloud")// doesn't exist
            }
            
            }.notify(.Main) {
                LOG.debug("do stuff")// doesn't exist
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
    
    func startQuery() {
        LOG.debug("Starting the query now...")
        
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
            LOG.debug("Successfully started the query.")
        } else {
            LOG.debug("Failed to start the query.")
        }
    }
    
    
    //MARK: - iCloud
    
    func handleIdentityChanged(notification: NSNotification) {
        if let currentiCloudToken = fileManager.ubiquityIdentityToken {
            LOG.debug("The new token is \(currentiCloudToken)")
            let newTokenData = NSKeyedArchiver.archivedDataWithRootObject(currentiCloudToken)
            userDefaults.setObject(newTokenData, forKey: "so.raven.PaperX.UbiquityIdentityToken")
        } else {
            LOG.debug("User has logged out of iCloud")
            userDefaults.removeObjectForKey("so.raven.PaperX.UbiquityIdentityToken")
        }
    }
    
    func iCloudAccountAvailabilityChanged(notification: NSNotification) {
        LOG.debug("iCloudAccountAvailabilityChanged")
    }
    
    /* Just a little method to help us display alert dialogs to the user */
    func displayAlertWithTitle(title: String, message: String) {
        
        LOG.debug(message)
        
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
    func applicationBecameActive(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(AppDelegate.handleIdentityChanged(_:)),
                                                         name: NSUbiquityIdentityDidChangeNotification,
                                                         object: nil)
    }
    
    /* Stop listening for those notifications when the app becomes inactive */
    func applicationBecameInactive(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: NSUbiquityIdentityDidChangeNotification,
                                                            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification: [NSObject:AnyObject],
                     fetchCompletionHandler: (UIBackgroundFetchResult) -> Void) {
        LOG.debug("recieved remote")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        LOG.debug("Failed to receive remote notifications \(error)")
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        LOG.debug("Successfully registered for remote notifications")
    }
    
    func testData() {
        let filePath = NSBundle.mainBundle().pathForResource("test", ofType: "ris")
        
        let items = RISFileParser.readFile(filePath!)
        
        self.dataController?.saveResults("TESTER", results: items)
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

