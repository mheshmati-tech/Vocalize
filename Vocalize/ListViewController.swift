//
//  ListViewController.swift
//  Vocalize
//
//  Created by Maryam Heshmati on 7/8/20.
//  Copyright © 2020 Maryam Heshmati. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class ListViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    var numberOfRecords: Int = 0
    var audioplayer:AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let number:Int = UserDefaults.standard.object(forKey: "myNumber") as? Int {
            numberOfRecords = number
        }
    }
    
    // Getting the path directory
    func getDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    //Displays alert message
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //play the audio
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")
        do {
            audioplayer = try AVAudioPlayer(contentsOf: path)
            audioplayer.play()
        } catch {
            displayAlert(title: "Ooops", message: "Recording Failed :(")
            
        }
    }
    
    
    @IBOutlet weak var myTableView: UITableView!
    
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return numberOfRecords
        }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AudioRecordingCell", for: indexPath) as! ListViewCell
            
            //cell.label.text = "name of audio file"
            
            //cell.textLabel?.text = String(indexPath.row + 1)
            return cell
        }
    
}


