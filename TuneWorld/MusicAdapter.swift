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
    
    func getSpotifyMusic(url : String, playlist: Playlist) {
        Alamofire.request(url).responseJSON(completionHandler: {
            response in
            if let data = response.data {
                self.parseSpotifyData(data: data, playlist: playlist)
            }
        })
    }
    
    func getLastFMData(url : String, playlistName: String) {
        let fetchRequest : NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Playlist")
        fetchRequest.predicate = NSPredicate(format: "name == %@", playlistName)
        do {
            let count = try ModelManager.shared.context.count(for: fetchRequest)
            if count == 0 {
                Alamofire.request(url).responseJSON(completionHandler: {
                    response in
                    if let data = response.data {
                        self.parseLastFMData(data: data, playlistName: playlistName)
                    }
                })
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    func parseSpotifyData(data: Data, playlist: Playlist) {
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
                        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ModelManager.shared.context, sectionNameKeyPath: nil, cacheName: nil)
                        try fetchResultsController.performFetch()
                        let count = try ModelManager.shared.context.count(for: fetchRequest)
                        if count == 1 {
                            ModelManager.shared.nowPlaying.append(uri!)
                            ModelManager.shared.nowPlayingSongs.append(fetchResultsController.fetchedObjects![0] as! Song)
                            NotificationCenter.default.post(name: ModelManager.shared.kMusicAddedNotificationName, object: nil)
                        }
                    }
                    
                }
            }
            
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func parseLastFMData(data: Data, playlistName: String) {
        do {
            var playlist : Playlist?
            var rootJSONDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? JSONDictionary
            if let tracks = rootJSONDictionary?["tracks"] as? JSONDictionary {
                if let attributes = tracks["@attr"] as? JSONDictionary {
                    if let country = attributes["country"] as? String {
                        if let entity = NSEntityDescription.entity(forEntityName: "Playlist", in: ModelManager.shared.context) {
                            playlist = NSManagedObject(entity: entity, insertInto: ModelManager.shared.context) as? Playlist
                            playlist?.setValue(playlistName, forKey: "name")
                            playlist?.setValue(country, forKey: "country")
                        }
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
                        if let entity = NSEntityDescription.entity(forEntityName: "Song", in: ModelManager.shared.context) {
                            let song = NSManagedObject(entity: entity, insertInto: ModelManager.shared.context) as! Song
                            song.setValue(name, forKey: "name")
                            song.setValue(artistName, forKey: "artist")
                            song.setValue(rank, forKey: "rank")
                            song.setValue(image, forKey: "image")
                            playlist?.addToSongs(song)
                        }
                    }
                    do {
                        try ModelManager.shared.context.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

    
