//
//  PlaylistTableViewController.swift
//  TuneWorld
//
//  Created by Austin Tucker on 5/19/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit

class PlaylistTableViewController: UITableViewController {

    var firstLoad : Bool = false
    @IBOutlet var playlistTableView: UITableView!
    override func viewDidLoad() {
        //when view loads show the playlist alert
        super.viewDidLoad()
        self.navigationItem.title = "Playlists"
        firstLoad = true
        let alert = UIAlertController(title: "Select a playlist", message: "Please select a playlist to start playing.", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
        self.definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //when the view appears, fetch the playlists from core data and reload the table
        super.viewWillAppear(animated)
        ModelManager.shared.fetchPlaylists(playlistName: "")
        playlistTableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //playlist count
        return ModelManager.shared.playlists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //display each playlist created in core data
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
        cell.textLabel?.text = ModelManager.shared.playlists[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //when a playlist is selected, fetch songs from core data
        ModelManager.shared.fetchSongs(playlist: ModelManager.shared.playlists[indexPath.row])
        if firstLoad {
            //if this is the first time showing this view, the playlist selected will be added to the now playing track list and other pages will be viewable
            guard let tabBarItemCount = self.tabBarController?.tabBar.items?.count else { return }
            for tabBarItemIndex in 0..<tabBarItemCount {
                self.tabBarController?.tabBar.items?[tabBarItemIndex].isEnabled = true
            }
            firstLoad = false
            DispatchQueue.global().async {
                ModelManager.shared.addSongsToNowPlaying(ModelManager.shared.playlists[indexPath.row])
            }
        } else {
            //otherwise ask the user if they would like to add more songs to the playlist.
            let alert = UIAlertController(title: "Add Playlist", message: "Would you like to add this playlist to Now Playing?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
                alert in
                ModelManager.shared.addSongsToNowPlaying(ModelManager.shared.playlists[indexPath.row])
                self.performSegue(withIdentifier: "toAlbumsSegue", sender: indexPath)
            })
            let noAction = UIAlertAction(title: "No", style: .default, handler: {
                alert in
                self.performSegue(withIdentifier: "toAlbumsSegue", sender: indexPath)
            })
            alert.addAction(yesAction)
            alert.addAction(noAction)
            present(alert, animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //assign indexpath of playlists table for view to show
        if segue.identifier == "toAlbumsSegue" {
            let destination = segue.destination as? AlbumTableViewController
            let index = sender as! IndexPath
            destination?.playlist = ModelManager.shared.playlists[index.row]
        }
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source (playlist + songs) and core data
            do {
                ModelManager.shared.fetchSongs(playlist: ModelManager.shared.playlists[indexPath.row])
                for song in ModelManager.shared.playlistSongs {
                        ModelManager.shared.context.delete(song)
                }
                ModelManager.shared.playlistSongs.removeAll()
                ModelManager.shared.context.delete(ModelManager.shared.playlists[indexPath.row])
                ModelManager.shared.playlists.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                try ModelManager.shared.context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
