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
import FBSDKShareKit

class WorldMapViewController: UIViewController, FBSDKAppInviteDialogDelegate {

    @IBOutlet weak var worldMapView: MKMapView!
    @IBOutlet weak var spotifyPlayerView: UIView!
    @IBOutlet weak var songLabel: MarqueeLabel!
    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var fastForwardButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    let dialog = FBSDKAppInviteDialog()
    var playlistName : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "TuneWorld"
        worldMapView.isRotateEnabled = false
        if ModelManager.shared.nowPlayingSongs.count != 0 {
            artistImageView.image = UIImage(data: ModelManager.shared.nowPlayingSongs[ModelManager.shared.nowPlayingIndex].image! as Data)
            songLabel.text = ModelManager.shared.nowPlayingSongs[ModelManager.shared.nowPlayingIndex].name! + " - " + ModelManager.shared.nowPlayingSongs[ModelManager.shared.nowPlayingIndex].artist! + " "
            songLabel.restartLabel()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rewindButtonPressed(_ sender: UIButton) {
        ModelManager.shared.player?.skipPrevious(nil)
        if ModelManager.shared.nowPlayingIndex > 0 {
           ModelManager.shared.nowPlayingIndex -= 1
        }
        artistImageView.image = UIImage(data: ModelManager.shared.nowPlayingSongs[ModelManager.shared.nowPlayingIndex].image! as Data)
        songLabel.text = ModelManager.shared.nowPlayingSongs[ModelManager.shared.nowPlayingIndex].name! + " - " + ModelManager.shared.nowPlayingSongs[ModelManager.shared.nowPlayingIndex].artist! + " "
        songLabel.restartLabel()
        playPauseButton.setImage(#imageLiteral(resourceName: "Pause-48"), for: .normal)
        ModelManager.shared.playMusic(ModelManager.shared.nowPlayingIndex)
    }
    
    @IBAction func playPauseButtonPressed(_ sender: UIButton) {
        ModelManager.shared.player?.setIsPlaying(!(ModelManager.shared.player?.playbackState.isPlaying)!, callback: nil)
        if (ModelManager.shared.player?.playbackState.isPlaying)! {
            sender.setImage(#imageLiteral(resourceName: "Play-48"), for: .normal)
        } else {
            sender.setImage(#imageLiteral(resourceName: "Pause-48"), for: .normal)
        }
    }
    
    @IBAction func fowardButtonPressed(_ sender: UIButton) {
        ModelManager.shared.player?.skipNext(nil)
        ModelManager.shared.nowPlayingIndex += 1
        if ModelManager.shared.nowPlayingIndex < ModelManager.shared.nowPlaying.count {
            playPauseButton.setImage(#imageLiteral(resourceName: "Pause-48"), for: .normal)
            artistImageView.image = UIImage(data: ModelManager.shared.nowPlayingSongs[ModelManager.shared.nowPlayingIndex].image! as Data)
            songLabel.text = ModelManager.shared.nowPlayingSongs[ModelManager.shared.nowPlayingIndex].name! + " - " + ModelManager.shared.nowPlayingSongs[ModelManager.shared.nowPlayingIndex].artist! + " "
            songLabel.restartLabel()
            ModelManager.shared.playMusic(ModelManager.shared.nowPlayingIndex)
        }
    }
    
    
    @IBAction func facebookShareButtonPressed(_ sender: UIButton) {
        if dialog.canShow() {
            dialog.content = ModelManager.shared.content
            dialog.delegate = self
            dialog.show()
        }
    }
    
    @IBAction func mapTapGestureMade(_ sender: UITapGestureRecognizer) {
        if !(tabBarController?.tabBar.items?[2].isEnabled)! {
            tabBarController?.tabBar.items?[2].isEnabled = true
        }
        let point = sender.location(in: self.worldMapView)
        let coordinates = self.worldMapView.convert(point, toCoordinateFrom: self.worldMapView)
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let geocoder = CLGeocoder()
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
    
    //MARK FBSDKAppInviteDialogDelegate
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print(results)
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        
    }
}
