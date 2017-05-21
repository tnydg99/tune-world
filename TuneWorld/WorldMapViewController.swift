//
//  WorldMapViewController.swift
//  TuneWorld
//
//  Created by Austin Tucker on 5/19/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit
import MapKit

class WorldMapViewController: UIViewController {

    @IBOutlet weak var worldMapView: MKMapView!
    @IBOutlet weak var spotifyPlayerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        worldMapView.isZoomEnabled = false
        worldMapView.isRotateEnabled = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
