//
//  TabBarViewController.swift
//  TuneWorld
//
//  Created by Austin Tucker on 5/22/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "TuneWorld"
        self.navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
        ModelManager.shared.handleNewSession()
        ModelManager.shared.player?.setIsPlaying(false, callback: nil)
        ModelManager.shared.playMusic()
         NotificationCenter.default.addObserver(self, selector: #selector(musicAdded(_:)), name: ModelManager.shared.kMusicAddedNotificationName, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func musicAdded(_ notification: Notification) {
        ModelManager.shared.playMusic()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
