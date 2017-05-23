//
//  ModelManager.swift
//  TuneWorld
//
//  Created by Austin Tucker on 5/19/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class ModelManager: NSObject, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    static var shared = ModelManager()
    var musicAdapter = MusicAdapter()
    var playlistSongs : [Song] = []
    var playlists : [Playlist] = []
    var nowPlaying : [String] = []
    var nowPlayingSongs : [Song] = []
    let kCLientID = "492517f79b4445a693a31aed968fe484"
    let kCallbackURL = "tuneworld://callback"
    let kSessionNotificationName = Notification.Name("sessionUpdated")
    let kMusicAddedNotificationName = Notification.Name("musicAdded")
    var player = SPTAudioStreamingController.sharedInstance()
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
    
    func formatPlaylistName(country: String) -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let formattedDate = formatter.string(from: date)
        let playlistName = "\(String(describing: country)) - \(formattedDate)"
        return playlistName
    }
    
    func handleNewSession() {
        let auth = SPTAuth.defaultInstance()
        do {
            try player?.start(withClientId: kCLientID, audioController: nil, allowCaching: true)
            player?.delegate = self;
            player?.playbackDelegate = self;
            player?.diskCache = SPTDiskCache.init(capacity: 1024 * 1024 * 64)
            player?.login(withAccessToken: auth?.session.accessToken)
            player?.setIsPlaying(false, callback: nil)
        } catch {
            print(error.localizedDescription)
        }
//
//        if (player == nil) {
//            player = SPTAudioStreamingController.sharedInstance()
//            do {
//                try player?.start(withClientId: kCLientID, audioController: nil, allowCaching: true)
//                player?.delegate = self;
//                player?.playbackDelegate = self;
//                player?.diskCache = SPTDiskCache.init(capacity: 1024 * 1024 * 64)
//                player?.login(withAccessToken: auth?.session.accessToken)
//            } catch {
//                print(error.localizedDescription)
//            }
//        } else {
//            player = nil;
//            let alert = UIAlertController(title: "Error Initializing", message: "Error", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//            alert.present(alert, animated: true, completion: nil)
//            closeSession()
//        }
    }
    
    func closeSession() {
        let auth = SPTAuth.defaultInstance()
        auth?.session = nil
    }
    
    func playMusic() {
        if nowPlaying.count > 0 { //&& !(player?.playbackState.isPlaying)! {
                player?.playSpotifyURI(nowPlaying[0], startingWith: 0, startingWithPosition: 0, callback: {
                    error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
            })
        }
    }
    
    //MARK
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        nowPlaying.remove(at: 0)
        playMusic()
    }
    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController!) {
        closeSession()
    }
    
    
//    func activateAudioSession() {
//        var audioSession: AVAudioSession?
//        do {
//            try audioSession?.setCategory("AVAudioSessionCategoryPlayback")
//        } catch {
//            print(error)
//        }
//        do {
//            try audioSession?.setActive(true)
//        } catch {
//            print(error)
//        }
//    }
//    
//    func deactivateAudioSession() {
//        var audioSession: AVAudioSession?
//        do {
//            try audioSession?.setActive(false)
//        } catch {
//            print(error)
//        }
//    }
}
