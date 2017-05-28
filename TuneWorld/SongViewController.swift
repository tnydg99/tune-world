//
//  SongViewController.swift
//  TuneWorld
//
//  Created by Austin Tucker on 5/23/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit

class SongViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView?
    @IBOutlet var songImageViewCollection: [UIImageView]!
    @IBOutlet var songLabelCollection: [UILabel]!
    @IBOutlet var artistLabelCollection: [UILabel]!
    @IBOutlet var playPauseButtonCollection: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = self.view
        if ModelManager.shared.nowPlayingSongs.count != 0 {
            setSongDetails()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(musicChanged(_:)), name: ModelManager.shared.kMusicChangedNotificationName, object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ModelManager.shared.nowPlayingSongs.count > 0 {
            setSongDetails()
            for button in playPauseButtonCollection {
                button.setImage(ModelManager.shared.isPlaying ? #imageLiteral(resourceName: "Pause-48") : #imageLiteral(resourceName: "Play-48"), for: .normal)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func musicChanged(_ notification: Notification) {
        setSongDetails()
    }
    
    func setSongDetails(){
        for imageView in songImageViewCollection {
            imageView.image = UIImage(data: ModelManager.shared.nowPlayingSongs[ModelManager.shared.nowPlayingIndex].image! as Data)
        }
        for label in songLabelCollection {
            label.text = ModelManager.shared.nowPlayingSongs[ModelManager.shared.nowPlayingIndex].name!
        }
        
        for label in artistLabelCollection {
            label.text = ModelManager.shared.nowPlayingSongs[ModelManager.shared.nowPlayingIndex].artist!
        }
        backgroundImageView?.image = UIImage(data: ModelManager.shared.nowPlayingSongs[ModelManager.shared.nowPlayingIndex].image! as Data)
    }

    @IBAction func rewindButtonPressed(_ sender: UIButton) {
        ModelManager.shared.player?.skipPrevious(nil)
        if ModelManager.shared.nowPlayingIndex > 0 {
            ModelManager.shared.nowPlayingIndex -= 1
        }
        setSongDetails()
        for button in playPauseButtonCollection {
            button.setImage(#imageLiteral(resourceName: "Pause-48"), for: .normal)
        }
        ModelManager.shared.isPlaying = true
        ModelManager.shared.playMusic(ModelManager.shared.nowPlayingIndex)
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        ModelManager.shared.player?.setIsPlaying(!(ModelManager.shared.player?.playbackState.isPlaying)!, callback: nil)
        if (ModelManager.shared.player?.playbackState.isPlaying)! {
            for button in playPauseButtonCollection {
                button.setImage(#imageLiteral(resourceName: "Play-48"), for: .normal)
            }
            ModelManager.shared.isPlaying = false
        } else {
            for button in playPauseButtonCollection {
                button.setImage(#imageLiteral(resourceName: "Pause-48"), for: .normal)
            }
            ModelManager.shared.isPlaying = true
        }
    }
    
    @IBAction func forwardButtonPressed(_ sender: UIButton) {
        ModelManager.shared.player?.skipNext(nil)
        ModelManager.shared.nowPlayingIndex += 1
        if ModelManager.shared.nowPlayingIndex < ModelManager.shared.nowPlayingSongs.count {
            for button in playPauseButtonCollection {
                button.setImage(#imageLiteral(resourceName: "Pause-48"), for: .normal)
            }
            ModelManager.shared.isPlaying = true
            setSongDetails()
            ModelManager.shared.playMusic(ModelManager.shared.nowPlayingIndex)
        }

    }

//    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
//        let padding: CGFloat = 16.0
//        
//        // since we're calling this before the rotation, the height and width are swapped
//        let viewHeight = self.view.frame.size.width
//        let viewWidth = self.view.frame.size.height
//        
//        // if landscape
//        if UIInterfaceOrientationIsLandscape(toInterfaceOrientation) {
//            songImageViewTop.constant = (viewHeight/2.0) + (padding/2.0)
//            songImageViewTrailing.constant = (viewWidth/2.0) + (padding/2.0)
//            songImageViewLeading.constant = padding
//            
//            controlViewLeading.constant = (viewWidth/2.0) + (padding/2.0)
//            controlViewBottom.constant = padding
//            controlViewTop.constant = (viewHeight/2.0) + (padding/2.0)
//            
//        } else { // else portrait
//            songImageViewTop.constant = (viewHeight/2.0) + (padding/2.0)
//            songImageViewTrailing.constant = padding
//            songImageViewLeading.constant = (viewWidth/2.0) + (padding/2.0)
//            
//            controlViewTop.constant = padding
//            controlViewBottom.constant = (viewHeight/2.0) + (padding/2.0)
//            controlViewLeading.constant = (viewWidth/2.0) + (padding/2.0)
//        }
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
