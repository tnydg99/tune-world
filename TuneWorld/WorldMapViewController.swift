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

class WorldMapViewController: UIViewController {

    @IBOutlet weak var worldMapView: MKMapView!
    @IBOutlet weak var spotifyPlayerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        worldMapView.isRotateEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func mapTapGestureMade(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.worldMapView)
        let coordinates = self.worldMapView.convert(point, toCoordinateFrom: self.worldMapView)
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) in
            if (placemarks?.count)! > 0 {
                if let placemark = placemarks?[0] {
                    if let country = placemark.country {
                        let formattedCountry = country.replacingOccurrences(of: " ", with: "%20").lowercased()
                        let url = "http://ws.audioscrobbler.com/2.0/?method=geo.gettoptracks&country=\(formattedCountry)&api_key=317d5d825c8e7268a6ec6730d9cc071e&format=json"
                        let playlistName = ModelManager.shared.formatPlaylistName(country: country)
                        DispatchQueue.global().async {
                            ModelManager.shared.musicAdapter.getLastFMData(url: url, playlistName: playlistName)
                            ModelManager.shared.fetchPlaylists(playlistName: playlistName)
                            for playlist in ModelManager.shared.playlists {
                                ModelManager.shared.fetchSongs(playlist: playlist)
                                for song in ModelManager.shared.playlistSongs {
                                    if let name = song.name?.replacingOccurrences(of: " ", with: "+"),
                                        let artist = song.artist?.replacingOccurrences(of: " ", with: "+") {
                                        let url = "https://api.spotify.com/v1/search?query=track%3A\(String(describing: name))+artist%3A\(String(describing: artist))&type=track&offset=0&limit=1"
                                        ModelManager.shared.musicAdapter.getSpotifyMusic(url: url, playlist: playlist)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
}
