//
//  MusicAdapter.swift
//  TuneWorld
//
//  Created by Austin Tucker on 5/20/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class MusicAdapter: NSObject {

    typealias JSONDictionary = [String:AnyObject]
    //var searchURL = "https://api.spotify.com/v1/search?q=track%3AThe+Less+I+Know+the+Better+artist%3ATame+Impala&type=track"
    
    func getSpotifyMusic(url : String, playlist: Playlist) {
        Alamofire.request(url).responseJSON(completionHandler: {
            response in
            if let data = response.data {
                self.parseSpotifyData(data: data, playlist: playlist)
            }
        }).resume()
    }
    
    func getLastFMData(url : String) {
        Alamofire.request(url).responseJSON(completionHandler: {
            response in
            if let data = response.data {
                self.parseLastFMData(data: data)
            }
        }).resume()
    }
    
    func parseSpotifyData(data: Data, playlist: Playlist) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        do {
            var songName : String?
            var artistName : String?
            var uri : String?
            var rootJSONDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? JSONDictionary
            if let tracks = rootJSONDictionary?["tracks"] as? JSONDictionary {
                if let items = tracks["items"] as? [JSONDictionary] {
                    for item in items {
                        if let artists = item["artists"] as? [JSONDictionary] {
                            for artist in artists {
                                artistName = artist["name"] as? String
                            }
                        }
                        songName = item["name"] as? String
                        uri = item["uri"] as? String
                        let fetchRequest : NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Song")
                        fetchRequest.predicate = NSPredicate(format: "playlist.name == %@ && name == %@ && artist == %@", playlist.name!, songName!, artistName!)
                        let count = try context.count(for: fetchRequest)
                        if count != 0 {
                            ModelManager.shared.nowPlaying.append(uri!)
                        }
                    }
                    
                }
            }
            
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func parseLastFMData(data: Data) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        do {
            var country : String?
            var playlist = Playlist()
            var rootJSONDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? JSONDictionary
            if let tracks = rootJSONDictionary?["tracks"] as? JSONDictionary {
                if let attributes = tracks["@attr"] as? JSONDictionary {
                    country = attributes["country"] as? String
                    let date = Date()
                    let playlistName = "\(String(describing: country)) - \(String(describing: date))"
                    
                    if let entity = NSEntityDescription.entity(forEntityName: "Playlist", in: context) {
                        playlist = NSManagedObject(entity: entity, insertInto: context) as! Playlist
                        playlist.setValue(playlistName, forKey: "name")
                        playlist.setValue(country, forKey: "country")
                    }

                }
                if let trackArray = tracks["track"] as? [JSONDictionary] {
                    for track in trackArray {
                        var artistName : String?
                        var rank : Int32?
                        var image : NSData?
                        let name = track["name"] as? String
                        if let artist = track["artist"] as? JSONDictionary {
                            artistName = artist["name"] as? String
                        }
                        if let artist = track["artist"] as? JSONDictionary {
                            artistName = artist["name"] as? String
                        }
                        if let albumArts = track["image"] as? [JSONDictionary] {
                            let images = albumArts[2]
                            let albumArtURL = URL(string: images["#text"] as! String)
                            image = NSData(contentsOf: albumArtURL!)
                        }
                        if let attributes = track["@attr"] as? JSONDictionary {
                            rank = attributes["rank"] as? Int32
                        }
                        if let entity = NSEntityDescription.entity(forEntityName: "Song", in: context) {
                            let song = NSManagedObject(entity: entity, insertInto: context) as! Song
                            song.setValue(name, forKey: "name")
                            song.setValue(artistName, forKey: "artist")
                            song.setValue(rank, forKey: "rank")
                            song.setValue(image, forKey: "image")
                            playlist.addToSongs(song)
                        }
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

    
