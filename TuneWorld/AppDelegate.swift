//
//  AppDelegate.swift
//  TuneWorld
//
//  Created by User on 5/15/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SPTAudioStreamingDelegate {

    var window: UIWindow?
    var auth : SPTAuth?
    var player: SPTAudioStreamingController?
    var authViewController: UIViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        auth = SPTAuth.defaultInstance()
//        player = SPTAudioStreamingController.sharedInstance()
        // The client ID you got from the developer site
        auth?.clientID = ModelManager.shared.kCLientID
        // The redirect URL as you entered it at the developer site
        auth?.redirectURL = URL(string: ModelManager.shared.kCallbackURL)
        // Setting the `sessionUserDefaultsKey` enables SPTAuth to automatically store the session object for future use.
        auth?.sessionUserDefaultsKey = ModelManager.shared.kSessionUserDefaultsKey
        // Set the scopes you need the user to authorize. `SPTAuthStreamingScope` is required for playing audio.
        auth?.requestedScopes = [SPTAuthStreamingScope]
        //Set the token refresh service url.
        //auth?.tokenRefreshURL = URL(string: ModelManager.shared.kTokenRefreshServiceURL)
        //Set the token swap service url.
        //auth?.tokenSwapURL = URL(string: ModelManager.shared.kTokenSwapURL)
//         // Become the streaming controller delegate
//         player?.delegate = self;
//         
//         // Start up the streaming controller.
//        do {
//            try player?.start(withClientId: auth?.clientID)
//        } catch {
//            print(error.localizedDescription)
//        }
//        
//        
//         // Start authenticating when the app is finished launching
//        DispatchQueue.main.async {
//            self.startAuthenticationFlow()
//        }
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        auth = SPTAuth.defaultInstance()
        let authCallback : SPTAuthCallback = {
            (error, session) in
            if error != nil {
                print(error!)
            } else {
                self.auth?.session = session
            }
            NotificationCenter.default.post(name: ModelManager.shared.kNotificationName, object: nil)
        }
        
        if (auth?.canHandle(url))! {
            auth?.handleAuthCallback(withTriggeredAuthURL: url, callback: authCallback)
            return true
        }
        return false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "TuneWorld")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

//    //MARK: - Spotify Helper Functions 
//    func startAuthenticationFlow() {
//    // Check if we could use the access token we already have
//        if let session = auth?.session {
//            if (session.isValid()) {
//                // Use it to log in
//                //[self startLoginFlow];
//            } else {
//                // Get the URL to the Spotify authorization portal
//                let authURL : URL = auth!.spotifyAppAuthenticationURL()
//                // Present in a SafariViewController
//                authViewController = SFSafariViewController(url: authURL)
//                window?.rootViewController = authViewController
//            }
//        }
//    }
    
//    func startLoginFlow(openURL: URL) -> Bool {
//        if (auth?.canHandle(openURL))! {
//            authViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
//            authViewController = nil
//            auth?.handleAuthCallback(withTriggeredAuthURL: openURL, callback: {
//                (error, session) in
//                if (session != nil) {
//                    self.player?.login(withAccessToken: self.auth?.session.accessToken)
//                }
//            })
//            return true
//        }
//        return false
//    }
    
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

