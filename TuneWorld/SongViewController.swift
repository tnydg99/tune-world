//
//  SongViewController.swift
//  TuneWorld
//
//  Created by Austin Tucker on 5/23/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit

class SongViewController: UIViewController {
    
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView?
    @IBOutlet var songImageViewCollection: [UIImageView]!
    @IBOutlet var songLabelCollection: [UILabel]!
    @IBOutlet var artistLabelCollection: [UILabel]!
    @IBOutlet var playPauseButtonCollection: [UIButton]!
    
    override func viewDidLoad() {
        //when the view loads, add the music changed observer
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(musicChanged(_:)), name: ModelManager.shared.kMusicChangedNotificationName, object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //when the view appears, set the song details and for any button in the play/pause button collection, set them to the appropriate image
        super.viewWillAppear(animated)
        if ModelManager.shared.nowPlayingSongs.count > 0 {
            setSongDetails()
            for button in playPauseButtonCollection {
                button.setImage(ModelManager.shared.isPlaying ? #imageLiteral(resourceName: "Pause-48") : #imageLiteral(resourceName: "Play-48"), for: .normal)
            }
        }
    }
    
    func musicChanged(_ notification: Notification) {
        //when the music changes, set the appropriate song details
        setSongDetails()
    }
    
    func setSongDetails(){
        //set the song view image, song name, artist name & background image for any given size class 
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
        //when the rewind button is pressed, play the last played song and show the song details
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
        //when the play/pause button is pressed, switch on/off the playback and show the correct image/name
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
        //when forward button is pressed, skip to the next song in line and show the song details
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
}
