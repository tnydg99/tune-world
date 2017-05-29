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
    var nowPlayingSongs : [Song] = []
    let kCLientID = "492517f79b4445a693a31aed968fe484"
    let kCallbackURL = "tuneworld://callback"
    let kSessionNotificationName = Notification.Name("sessionUpdated")
    let kMusicAddedNotificationName = Notification.Name("musicAdded")
    let kMusicChangedNotificationName = Notification.Name("musicChanged")
    let kPortaitViewOnlyControllerIndex = 3
    var isPlaying : Bool = false
    var player = SPTAudioStreamingController.sharedInstance()
    var nowPlayingIndex : Int = 0
    var context : NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return self.context
        }
        return appDelegate.persistentContainer.viewContext
    }

    private override init () {  }
    
    func fetchPlaylists(playlistName: String) {
        //fetch playlist(s) from core data
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
        //fetch songs from core data
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
        //format the playlist name to indicate what playlist is being added
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let formattedDate = formatter.string(from: date)
        let playlistName = "\(String(describing: country)) - \(formattedDate)"
        return playlistName
    }
    
    func handleNewSession() {
        //handle new session for spotify
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
    }
    
    func addSongsToNowPlaying(_ playlist: Playlist) {
        //fetch songs from spotify to add to the now playing list
        for song in self.playlistSongs {
            guard let name = song.name?.replacingOccurrences(of: " ", with: "+"), let artist = song.artist?.replacingOccurrences(of: " ", with: "+") else { return }
            let url = "https://api.spotify.com/v1/search?query=track%3A\(String(describing: name))+artist%3A\(String(describing: artist))&type=track&offset=0&limit=1"
            DispatchQueue.global().async {
                self.musicAdapter.getSpotifyMusic(url: url, playlist: playlist)
            }
        }
    }
    
    func closeSession() {
        //close the spotify session once done
        let auth = SPTAuth.defaultInstance()
        auth?.session = nil
    }
    
    func playMusic(_ index: Int) {
        //play music in the app
        if nowPlayingSongs.count > 0 {
            player?.playSpotifyURI(nowPlayingSongs[index].uri!, startingWith: 0, startingWithPosition: 0, callback: {
                error in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
            isPlaying = true
            NotificationCenter.default.post(name: self.kMusicChangedNotificationName, object: nil)
        }
    }
    
    //MARK SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        //play the next song once one ends
        nowPlayingIndex += 1
        playMusic(nowPlayingIndex)
    }
    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController!) {
        //close the session once a user logs out
        closeSession()
    }
}

