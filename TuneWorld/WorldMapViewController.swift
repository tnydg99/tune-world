//
//  WorldMapViewController.swift
//  TuneWorld
//
//  Created by Austin Tucker on 5/19/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import MarqueeLabel
import TwitterKit
import Social

class WorldMapViewController: UIViewController {

    @IBOutlet weak var worldMapView: MKMapView!
    @IBOutlet weak var spotifyPlayerView: UIView!
    @IBOutlet weak var songLabel: MarqueeLabel!
    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    
    override func viewDidLoad() {
        //register the observer for when music will change
        super.viewDidLoad()
        self.navigationItem.title = "TuneWorld"
        worldMapView.isRotateEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(musicChanged(_:)), name: ModelManager.shared.kMusicChangedNotificationName, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        //set the song details of the currently playing song if the song is set to play
        super.viewWillAppear(animated)
        if ModelManager.shared.nowPlayingSongs.count > 0 {
            setSongDetails()
            playPauseButton.imageView?.image = ModelManager.shared.isPlaying ? #imageLiteral(resourceName: "Pause-48") : #imageLiteral(resourceName: "Play-48")
        }
    }
    
    func musicChanged(_ notification: Notification) {
        //when music changes, change the song details
        setSongDetails()
    }
    
    func setSongDetails(){
        //details to set: artist image, song label text. restart the marquee label.
        artistImageView.image = UIImage(data: ModelManager.shared.nowPlayingSongs[ModelManager.shared.nowPlayingIndex].image! as Data)
        songLabel.text = ModelManager.shared.nowPlayingSongs[ModelManager.shared.nowPlayingIndex].name! + " - " + ModelManager.shared.nowPlayingSongs[ModelManager.shared.nowPlayingIndex].artist! + " "
        songLabel.restartLabel()
    }
    
    func presentSocialMedia(_ service: String) {
        //present social media popover depending on service passed in
        let composer = SLComposeViewController(forServiceType: service)
        composer?.setInitialText("I am listening to \(ModelManager.shared.nowPlayingSongs[ModelManager.shared.nowPlayingIndex].name!) by \(ModelManager.shared.nowPlayingSongs[ModelManager.shared.nowPlayingIndex].artist!) using the TuneWorld app!")
        self.present(composer!, animated: true, completion: nil)
    }
    
    @IBAction func rewindButtonPressed(_ sender: UIButton) {
        //when the rewind button is pressed, play the last played song and show the song details
        ModelManager.shared.player?.skipPrevious(nil)
        if ModelManager.shared.nowPlayingIndex > 0 {
           ModelManager.shared.nowPlayingIndex -= 1
        }
        setSongDetails()
        playPauseButton.setImage(#imageLiteral(resourceName: "Pause-48"), for: .normal)
        ModelManager.shared.playMusic(ModelManager.shared.nowPlayingIndex)
    }
    
    @IBAction func playPauseButtonPressed(_ sender: UIButton) {
        //when the play/pause button is pressed, switch on/off the playback and show the correct image/name
        ModelManager.shared.player?.setIsPlaying(!(ModelManager.shared.player?.playbackState.isPlaying)!, callback: nil)
        if (ModelManager.shared.player?.playbackState.isPlaying)! {
            sender.setImage(#imageLiteral(resourceName: "Play-48"), for: .normal)
            ModelManager.shared.isPlaying = false
        } else {
            sender.setImage(#imageLiteral(resourceName: "Pause-48"), for: .normal)
            ModelManager.shared.isPlaying = true
        }
    }
    
    @IBAction func fowardButtonPressed(_ sender: UIButton) {
        //when forward button is pressed, skip to the next song in line and show the song details
        ModelManager.shared.player?.skipNext(nil)
        ModelManager.shared.nowPlayingIndex += 1
        if ModelManager.shared.nowPlayingIndex < ModelManager.shared.nowPlayingSongs.count {
            playPauseButton.setImage(#imageLiteral(resourceName: "Pause-48"), for: .normal)
            setSongDetails()
            ModelManager.shared.playMusic(ModelManager.shared.nowPlayingIndex)
        }
    }
    
    @IBAction func facebookButtonPressed(_ sender: UIButton) {
        //present the facebook popup
       presentSocialMedia(SLServiceTypeFacebook)
    }
    
    @IBAction func twitterButtonPressed(_ sender: UIButton) {
        //present the twitter popover is user is logged in
        if (Twitter.sharedInstance().sessionStore.existingUserSessions().count != 0) {
            // App must have at least one logged-in user to compose a Tweet
            presentSocialMedia(SLServiceTypeTwitter)
        } else {
            // Log in, and then check again
            Twitter.sharedInstance().logIn { session, error in
                if session != nil { // Log in succeeded
                    self.presentSocialMedia(SLServiceTypeTwitter)
                } else {
                    let alert = UIAlertController(title: "No Twitter Accounts Available", message: "You must log in before presenting a composer.", preferredStyle: .alert)
                    self.present(alert, animated: false, completion: nil)
                }
            }
        }
    }
    
    @IBAction func mapTapGestureMade(_ sender: UITapGestureRecognizer) {
        //enable the playlists view if it is disabled and then fetch the correct playlist and songs on that playlist based on selected country
        if !(self.tabBarController?.tabBar.items?[2].isEnabled)! {
            self.tabBarController?.tabBar.items?[2].isEnabled = true
        }
        let point = sender.location(in: self.worldMapView)
        let coordinates = self.worldMapView.convert(point, toCoordinateFrom: self.worldMapView)
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let geocoder = CLGeocoder()
        DispatchQueue.main.async {
            geocoder.reverseGeocodeLocation(location, completionHandler: {
                (placemarks, error) in
                if (placemarks?.count)! > 0 {
                    guard let placemark = placemarks?[0], let country = placemark.country else { return }
                    let formattedCountry = country.replacingOccurrences(of: " ", with: "%20").lowercased()
                    let url = "http://ws.audioscrobbler.com/2.0/?method=geo.gettoptracks&country=\(formattedCountry)&api_key=317d5d825c8e7268a6ec6730d9cc071e&format=json"
                    let playlistName = ModelManager.shared.formatPlaylistName(country: country)
                    DispatchQueue.global().async {
                        ModelManager.shared.musicAdapter.getLastFMData(url: url, playlistName: playlistName)
                        ModelManager.shared.fetchPlaylists(playlistName: playlistName)
                        for playlist in ModelManager.shared.playlists {
                            ModelManager.shared.fetchSongs(playlist: playlist)
                            ModelManager.shared.addSongsToNowPlaying(playlist)
                        }
                    }
                }
            })
        }
    }
}
