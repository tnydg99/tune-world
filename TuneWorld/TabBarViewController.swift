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
        guard let tabBarItemCount = self.tabBar.items?.count else { return }
        for tabBarItemIndex in 1..<tabBarItemCount {
            self.tabBar.items?[tabBarItemIndex].isEnabled = false
//            self.viewControllers?[tabBarItemIndex].navigationItem.title = self.tabBar.items?[tabBarItemIndex].title
        }
        tabBarController?.tabBar.items?[0].isEnabled = true
        tabBarController?.tabBar.selectedItem = tabBarController?.tabBar.items?[0]
        NotificationCenter.default.addObserver(self, selector: #selector(musicAdded(_:)), name: ModelManager.shared.kMusicAddedNotificationName, object: nil)
        self.navigationController?.hidesBarsWhenVerticallyCompact = true
        self.navigationController?.hidesBarsOnTap = true
        self.navigationController?.hidesBarsOnSwipe = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func musicAdded(_ notification: Notification) {
        if ModelManager.shared.player?.playbackState == nil {
            ModelManager.shared.player?.setRepeat(.off, callback: nil)
            ModelManager.shared.player?.setShuffle(true, callback: nil)
            ModelManager.shared.player?.setIsPlaying(true, callback: nil)
        }
        ModelManager.shared.playMusic(ModelManager.shared.nowPlayingIndex)
    }
    
   override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "Now Playing" {
            guard let songVC = tabBarController?.viewControllers?[3] as? SongViewController else { return }
            songVC.songName = ModelManager.shared.nowPlayingSongs[0].name!
            songVC.artistName = ModelManager.shared.nowPlayingSongs[0].artist!
            songVC.songImage = UIImage(data: ModelManager.shared.nowPlayingSongs[0].image! as Data)
            songVC.backgroundImage = UIImage(data: ModelManager.shared.nowPlayingSongs[0].image! as Data)
            tabBarController?.selectedViewController = tabBarController?.viewControllers?[3]
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        if viewController.isKind(of: SongViewController.self) {
//            guard let songVC = viewController as? SongViewController else {
//                return
//            }
//            songVC.songName = ModelManager.shared.nowPlayingSongs[0].name!
//            songVC.artistName = ModelManager.shared.nowPlayingSongs[0].artist!
//            songVC.songImage = UIImage(data: ModelManager.shared.nowPlayingSongs[0].image! as Data)
//            songVC.backgroundImage = UIImage(data: ModelManager.shared.nowPlayingSongs[0].image! as Data)
//            _ = songVC.view
//        }
//    }
}
