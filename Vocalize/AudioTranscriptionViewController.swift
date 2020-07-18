//
//  AudioTranscriptionViewController.swift
//  Vocalize
//
//  Created by Maryam Heshmati on 7/15/20.
//  Copyright © 2020 Maryam Heshmati. All rights reserved.
//

import UIKit
import Speech
import CoreData

//protocol AudioTranscriptionDelegate {
//    func transcriptionPermission(permission:Bool)
//}

class AudioTranscriptionViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        self.appDelegate = appDelegate
        initializeLabel()
        
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var transcribeText: UILabel!
    var recordingToTranscribe:NSManagedObject!
    var appDelegate: AppDelegate!
    @IBOutlet weak var sentimentText: UILabel!
    
    
    //Displays alert message
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //permission
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { [unowned self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    
                    do {
                        let path = try FileHelper.getRecordingFileName((self.recordingToTranscribe.value(forKey: "fileName") as? String)!)
                        self.transcribeAudio(url: path)
                        
                        //
                    } catch {
                        self.displayAlert(title: "Permission Error", message: "Unable to find recording file to transcribe")
                    }
                } else {
                    self.transcribeText.text = "Transcription permission was declined."
                    
                    //
                }
            }
        }
    }
    
    func initializeLabel(){
        if let transcripton = recordingToTranscribe.value(forKey: "transcription") as? String {
            transcribeText.text = transcripton
            //getting the sentiment 
            sentimentAnalysis()
        } else {
            //we don't have trancription and need permission from user
            requestTranscribePermissions()
        }
    }
    
    
    //audio transcripption
    func transcribeAudio(url: URL) {
        // create a new recognizer and point it at our audio
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: url)
        
        activityIndicator.startAnimating()
        // start recognition!
        recognizer?.recognitionTask(with: request) { [unowned self] (resultParameter, error) in
            // abort if we didn't get any transcription back
            guard let result = resultParameter else {
                print("There was an error: \(error!)")
                return
            }
            
            // if we got the final transcription back, print it
            if result.isFinal {
                self.updateRecording(transcription: result.bestTranscription.formattedString )
            }
        }
    }
    
    
    func updateRecording(transcription:String){
        recordingToTranscribe.setValue(transcription, forKey: "transcription")
        self.transcribeText.text = transcription
        activityIndicator.stopAnimating()
        appDelegate.saveContext()
    }
    
    
    func sentimentAnalysis(){
        if let sentiment = recordingToTranscribe.value(forKey: "sentimentValue") as? String {
            self.sentimentText.text = sentiment
            print("I'm Fetching my sentiment BITCHESSSSSSS")
            
        } else {
            //make the API call to get the sentiment
            getSentimentAnalysis(from: urlString)
        }
    }
    
    func updateSentiment(sentimentValue:String){
        recordingToTranscribe.setValue(sentimentValue, forKey: "sentimentValue")
        self.sentimentText.text = sentimentValue
        appDelegate.saveContext()
    }
    
    
    let urlString = "https://vocalize.cognitiveservices.azure.com/text/analytics/v3.0/sentiment"
    
    private func getSentimentAnalysis(from url: String) {
        
        
        
        let document = self.transcribeText.text
          //prepare json Data
        let json: [String: Any] =
            [
                "documents": [
                    [
                        "language": "en",
                        "id": "1",
                        "text": document
                    ]
                ]
        ]
        
        
        
        
        let session = URLSession.shared
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("KEY KEY KEY:)", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        //TODO-- Change this later -- use a variable
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No Data")
                return
            }
            
            
            
            //decode JSON to object here
            var sentimentData: Documents?
            let decoder = JSONDecoder()
            do {
                sentimentData = try decoder.decode(Documents.self, from: data)
                self.updateSentiment(sentimentValue: (sentimentData?.documents[0].sentiment)!)
                print("MAKING APIIIII CALLS YOOO")
                
            } catch {
                print("Error Occured while decoding. \(error)")
            }
            
         
            
            
            //            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            //            if let responseJSON = responseJSON as? [String: Any] {
            //                print(responseJSON)
            //            }
        }
        
        task.resume()
    }
    
}

//Optional({
//    documents =     (
//                {
//            confidenceScores =             {
//                negative = 0;
//                neutral = "0.98";
//                positive = "0.02";
//            };
//            id = 1;
//            sentences =             (
//                                {
//                    confidenceScores =                     {
//                        negative = 0;
//                        neutral = "0.98";
//                        positive = "0.02";
//                    };
//                    length = 89;
//                    offset = 0;
//                    sentiment = neutral;
//                    text = "We're making a new recording to see if the load button is going to keep your lady want it";
//                }
//            );
//            sentiment = neutral;
//            warnings =             (
//            );
//        }
//    );
//    errors =     (
//    );
//    modelVersion = "2020-04-01";
//})
