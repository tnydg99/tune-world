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
        super.viewWillAppear(animated)
        ModelManager.shared.fetchPlaylists(playlistName: "")
        playlistTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ModelManager.shared.playlists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
        cell.textLabel?.text = ModelManager.shared.playlists[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ModelManager.shared.fetchSongs(playlist: ModelManager.shared.playlists[indexPath.row])
        if firstLoad {
            guard let tabBarItemCount = tabBarController?.tabBar.items?.count else { return }
            for tabBarItemIndex in 0..<tabBarItemCount {
                tabBarController?.tabBar.items?[tabBarItemIndex].isEnabled = true
            }
            firstLoad = false
            DispatchQueue.global().async {
                ModelManager.shared.addSongsToNowPlaying(ModelManager.shared.playlists[indexPath.row])
            }
        } else {
            let alert = UIAlertController(title: "Add Playlist", message: "Would you like to add this playlist to Now Playing?", preferredStyle: .actionSheet)
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
        if segue.identifier == "toAlbumsSegue" {
            let destination = segue.destination as? AlbumTableViewController
            let index = sender as! IndexPath
            destination?.playlist = ModelManager.shared.playlists[index.row]
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
}
