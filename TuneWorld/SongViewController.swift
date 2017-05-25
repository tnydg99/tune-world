//
//  SongViewController.swift
//  TuneWorld
//
//  Created by Austin Tucker on 5/23/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit

class SongViewController: UITabBarController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {

    @IBOutlet weak var backgroundImageView: UIImageView?
    @IBOutlet weak var songImageView: UIImageView?
    @IBOutlet weak var songLabel: UILabel?
    @IBOutlet weak var artistLabel: UILabel?
    var songName: String?
    var artistName : String?
    var songImage : UIImage?
    var backgroundImage : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = self.view
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        songLabel?.text = ModelManager.shared.nowPlayingSongs[0].name
        artistLabel?.text = ModelManager.shared.nowPlayingSongs[0].artist
        songImageView?.image = UIImage(data: ModelManager.shared.nowPlayingSongs[0].image! as Data)
        backgroundImageView?.image = UIImage(data: ModelManager.shared.nowPlayingSongs[0].image! as Data)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rewindButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func forwardButtonPressed(_ sender: UIButton) {
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
