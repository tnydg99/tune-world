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
            switch response.result {
            case .success( _):
                guard let data = response.data else { return }
                self.parseSpotifyData(url: url, data: data, playlist: playlist)
            case .failure(let error):
                print(error)
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
                    guard let data = response.data else { return }
                    self.parseLastFMData(data: data, playlistName: playlistName)
                })
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func parseSpotifyData(url : String, data: Data, playlist: Playlist) {
        do {
            var artistName : String?
            var rootJSONDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? JSONDictionary
            guard let tracks = rootJSONDictionary?["tracks"] as? JSONDictionary else { return }
            guard let items = tracks["items"] as? [JSONDictionary] else { return }
            for item in items {
                guard let artists = item["artists"] as? [JSONDictionary] else { return }
                for artist in artists {
                    artistName = artist["name"] as? String
                }
                let songName = item["name"] as? String
                let uri = item["uri"] as? String
                let fetchRequest : NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Song")
                fetchRequest.predicate = NSPredicate(format: "playlist.name == %@ && name == %@ && artist == %@", playlist.name!, songName!, artistName!)
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
                let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ModelManager.shared.context, sectionNameKeyPath: nil, cacheName: nil)
                do {
                    try fetchResultsController.performFetch()
                    let count = try ModelManager.shared.context.count(for: fetchRequest)
                    if count == 1 {
                        let song = fetchResultsController.fetchedObjects?[0] as! Song
                        song.setValue(uri, forKey: "uri")
                        ModelManager.shared.nowPlayingSongs.append(song)
                        do {
                            try ModelManager.shared.context.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                } catch {
                    print("here " + error.localizedDescription)
                }
                NotificationCenter.default.post(name: ModelManager.shared.kMusicAddedNotificationName, object: nil)
            }
        } catch {
            print(url + " " + error.localizedDescription)
            print(data)
        }
    }
    
    func parseLastFMData(data: Data, playlistName: String) {
        do {
            var playlist : Playlist?
            var rootJSONDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? JSONDictionary
            guard let tracks = rootJSONDictionary?["tracks"] as? JSONDictionary, let attributes = tracks["@attr"] as? JSONDictionary, let country = attributes["country"] as? String else { return }
            guard let entity = NSEntityDescription.entity(forEntityName: "Playlist", in: ModelManager.shared.context) else { return }
            playlist = NSManagedObject(entity: entity, insertInto: ModelManager.shared.context) as? Playlist
            guard let trackArray = tracks["track"] as? [JSONDictionary] else { return }
            if trackArray.count != 0 {
                playlist?.setValue(playlistName, forKey: "name")
                playlist?.setValue(country, forKey: "country")
            }
            for track in trackArray {
                guard let artist = track["artist"] as? JSONDictionary, let albumArts = track["image"] as? [JSONDictionary], let attributes = track["@attr"] as? JSONDictionary else { return }
                let name = track["name"] as? String
                let artistName = artist["name"] as? String
                let images = albumArts[2]
                let albumArtURL = URL(string: images["#text"] as! String)
                let image = NSData(contentsOf: albumArtURL!)
                let rank = attributes["rank"] as? Int32
                guard let entity = NSEntityDescription.entity(forEntityName: "Song", in: ModelManager.shared.context) else { return }
                let song = NSManagedObject(entity: entity, insertInto: ModelManager.shared.context) as! Song
                song.setValue(name, forKey: "name")
                song.setValue(artistName, forKey: "artist")
                song.setValue(rank, forKey: "rank")
                song.setValue(image, forKey: "image")
                playlist?.addToSongs(song)
            }
            do {
                try ModelManager.shared.context.save()
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

    
