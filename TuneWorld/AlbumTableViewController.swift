//
//  AlbumTableViewController.swift
//  TuneWorld
//
//  Created by Austin Tucker on 5/19/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit

class AlbumTableViewController: UITableViewController {
    
    @IBOutlet var songTableView: UITableView!
    var playlist : Playlist?
    
    override func viewDidLoad() {
        //when the view loads, set the view to have appropriate features in the navigation item
        super.viewDidLoad()
        self.navigationItem.title = "Songs"
        navigationItem.backBarButtonItem?.title = "Playlists"
        navigationItem.hidesBackButton = false
        self.definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //when the view appears, reload the song data
        super.viewWillAppear(animated)
        songTableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //songs in playlist count
        return ModelManager.shared.playlistSongs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //display the song cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath)
        let songLabel = cell.viewWithTag(1) as? UILabel
        let artistLabel = cell.viewWithTag(2) as? UILabel
        let imageView = cell.viewWithTag(3) as? UIImageView
        songLabel?.text = ModelManager.shared.playlistSongs[indexPath.row].name
        artistLabel?.text = ModelManager.shared.playlistSongs[indexPath.row].artist
        imageView?.image = UIImage(data: ModelManager.shared.playlistSongs[indexPath.row].image! as Data)
        return cell
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //hard coded row value
        return 85
    }
}
