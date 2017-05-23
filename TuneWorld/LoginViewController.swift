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
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(sessionUpdated(_:)), name: ModelManager.shared.kSessionNotificationName, object: nil)
        firstLoad = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let auth = SPTAuth.defaultInstance()
        if auth?.session == nil {
            return
        }
        
        if (auth?.session.isValid())! && firstLoad {
            //code login and allow player to play
            //showPlayer()
            return
        }
        
        if (auth?.hasTokenRefreshService)! {
            //code login and allow player to play
            //renewTokenAndShowPlayer
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func authViewControllerWithURL(url: URL) -> UIViewController {
        var viewController : UIViewController?
        let safari = SFSafariViewController(url: url)
        safari.delegate = self
        viewController = safari
        viewController?.modalPresentationStyle = .pageSheet
        return viewController!
    }
    
    func sessionUpdated(_ notification: Notification) {
        let auth = SPTAuth.defaultInstance()
        presentedViewController?.dismiss(animated: true, completion: nil)
        if auth?.session != nil && (auth?.session.isValid())! {
            showPlayer()
        } else {
            //failed login
        }
    }

    func showPlayer() {
        firstLoad = false
        let tuneWorldVC = storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        present(tuneWorldVC, animated: true, completion: nil)
    }
    
    func openLoginPage() {
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
        openLoginPage()
    }

}
