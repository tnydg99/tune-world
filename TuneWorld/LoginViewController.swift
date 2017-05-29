//
//  LoginViewController.swift
//  TuneWorld
//
//  Created by Austin Tucker on 5/21/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, SFSafariViewControllerDelegate {

    var firstLoad : Bool = false
    var authViewController : UIViewController?
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        //when the view loads, register the session observer
        super.viewDidLoad()
        self.navigationItem.title = "Login"
        NotificationCenter.default.addObserver(self, selector: #selector(sessionUpdated(_:)), name: ModelManager.shared.kSessionNotificationName, object: nil)
        firstLoad = true
    }

    override func viewWillAppear(_ animated: Bool) {
        //when the view appears, make sure that the session is not erroring out
        super.viewWillAppear(animated)
        let auth = SPTAuth.defaultInstance()
        if auth?.session == nil {
            return
        }
    }

    func authViewControllerWithURL(url: URL) -> UIViewController {
        //display authentication view in safari
        var viewController : UIViewController?
        let safari = SFSafariViewController(url: url)
        safari.delegate = self
        viewController = safari
        viewController?.modalPresentationStyle = .pageSheet
        return viewController!
    }
    
    func sessionUpdated(_ notification: Notification) {
        //once the session has been authenticated, navigate to other views
        let auth = SPTAuth.defaultInstance()
        presentedViewController?.dismiss(animated: true, completion: nil)
        if auth?.session != nil && (auth?.session.isValid())! {
            showPlayer()
        }
    }

    func showPlayer() {
        //navigate to other views after authentication (either the map view or the playlist view)
        firstLoad = false
        ModelManager.shared.handleNewSession()
        ModelManager.shared.fetchPlaylists(playlistName: "")
        if ModelManager.shared.playlists.count == 0 {
            self.tabBarController?.tabBar.items?[1].isEnabled = true
            self.tabBarController?.selectedViewController = tabBarController?.viewControllers?[1]
        } else {
            self.tabBarController?.tabBar.items?[2].isEnabled = true
            self.tabBarController?.selectedViewController = tabBarController?.viewControllers?[2]
        }
    }
    
    func openLoginPage() {
        //present the safari view controller if it is supprted
        let auth = SPTAuth.defaultInstance()
        if SPTAuth.supportsApplicationAuthentication() {
            UIApplication.shared.open((auth?.spotifyAppAuthenticationURL())!, options: [:], completionHandler: nil)
        } else {
            authViewController = authViewControllerWithURL(url: SPTAuth.defaultInstance().spotifyWebAuthenticationURL())
            self.definesPresentationContext = true
            self.present(authViewController!, animated: true, completion: nil)
        }
    }
    
    func renewTokenAndShowPlayer() {
        // if continuous token handling is enabled, then renew session and show the player.
        let auth = SPTAuth.defaultInstance()
        auth?.renewSession(auth?.session, callback: {
        (error, session) in
            auth?.session = session
            if error != nil {
                print(error!)
                return
            }
            self.showPlayer()
        })
    }
    
    //MARK SFSafariViewControllerDelegate
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        //navigate to safari
        openLoginPage()
    }

}
