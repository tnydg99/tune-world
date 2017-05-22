//
//  ModelManager.swift
//  TuneWorld
//
//  Created by Austin Tucker on 5/19/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit
import CoreData

class ModelManager: NSObject {
    static var shared = ModelManager()
    var musicAdapter = MusicAdapter()
    var playlistSongs : [Song] = []
    var playlists : [Playlist] = []
    var nowPlaying : [String] = []
    let kCLientID = "492517f79b4445a693a31aed968fe484"
    let kCallbackURL = "tuneworld://returnAfterLogin"
    let kTokenSwapURL = "http://localhost:1234/swap"
    let kTokenRefreshServiceURL = "http://localhost:1234/refresh"
    
    var context : NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return self.context
        }
        return appDelegate.persistentContainer.viewContext
    }

    private override init () { }
    
    func fetchPlaylists(playlistName: String) {
        do {
            let fetchRequest : NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Playlist")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            if playlistName != "" {
                fetchRequest.predicate = NSPredicate(format: "name == %@", playlistName)
            }
            let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            try fetchResultsController.performFetch()
            playlists = fetchResultsController.fetchedObjects! as! [Playlist]
        } catch {
            print("Unable to fetch objects with the error: \(error.localizedDescription)")
        }
    }
    
    func fetchSongs(playlist: Playlist) {
        do {
            let fetchRequest : NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Song")
            let sortByNameDescriptor = NSSortDescriptor(key: "rank", ascending: true)
            fetchRequest.predicate = NSPredicate(format: "playlist.name == %@", playlist.name!)
            fetchRequest.sortDescriptors = [sortByNameDescriptor]
            let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            try fetchResultsController.performFetch()
            playlistSongs = fetchResultsController.fetchedObjects! as! [Song]
        } catch {
            print("Unable to fetch objects with the error: \(error.localizedDescription)")
        }
    }
}
