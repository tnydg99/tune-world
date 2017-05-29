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
        //when the view loads, enable the login tab and add the music added obserevr
        super.viewDidLoad()
        guard let tabBarItemCount = self.tabBar.items?.count else { return }
        for tabBarItemIndex in 1..<tabBarItemCount {
            self.tabBar.items?[tabBarItemIndex].isEnabled = false
        }
        self.tabBar.items?[0].isEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(musicAdded(_:)), name: ModelManager.shared.kMusicAddedNotificationName, object: nil)
        self.navigationController?.hidesBarsWhenVerticallyCompact = true
        self.navigationController?.hidesBarsOnTap = true
        self.navigationController?.hidesBarsOnSwipe = true
        // Do any additional setup after loading the view.
    }
    
    func musicAdded(_ notification: Notification) {
        //when music is added, start playing music from the queue
        if ModelManager.shared.player?.playbackState == nil {
            ModelManager.shared.player?.setRepeat(.off, callback: nil)
            ModelManager.shared.player?.setIsPlaying(true, callback: nil)
        } else {
            if !(ModelManager.shared.player?.playbackState.isPlaying)! {
                ModelManager.shared.playMusic(ModelManager.shared.nowPlayingIndex)
            }
        }
    }
}
