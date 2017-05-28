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
        super.viewDidLoad()
        self.navigationItem.title = "Songs"
        navigationItem.backBarButtonItem?.title = "Playlists"
        navigationItem.hidesBackButton = false
        self.definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        songTableView.reloadData()
        
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
        return ModelManager.shared.playlistSongs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        return 85
    }
}
