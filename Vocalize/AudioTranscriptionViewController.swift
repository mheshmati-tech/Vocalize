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
    @IBOutlet weak var SentimentEmoji: UILabel!
    
    
    //Displays alert message
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    func initializeLabel(){
        if let transcripton = recordingToTranscribe.value(forKey: "transcription") as? String {
            updateTranscriptionLabel(transcriptionText: transcripton)
            checkSentimentAnalysis()
        } else {
            // We don't have trancription and need permission from user
            requestTranscribePermissions()
        }
    }
    
    
    func updateTranscriptionLabel(transcriptionText:String){
        self.transcribeText.text = transcriptionText
    }
    
    
    
    
    
    
    //permission
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { [unowned self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    
                    do {
                        let path = try FileHelper.getRecordingFileName((self.recordingToTranscribe.value(forKey: "fileName") as? String)!)
                        self.makeTranscriptionRequest(url: path, onCompletion: { transcribedText in
                            self.activityIndicator.stopAnimating()
                            // Update the label
                            self.updateTranscriptionLabel(transcriptionText: transcribedText)
                            // Save it to Core Data
                            self.saveTranscriptionToCoreData(transcriptionValue: transcribedText)
                            // Run sentiment analysis
                            self.checkSentimentAnalysis()
                            
                        })
                        
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
    
    
    
    func checkSentimentAnalysis(){
        if let sentiment = recordingToTranscribe.value(forKey: "sentimentValue") as? String {
            updateSentimentLabel(sentiment: sentiment)
        } else {
            // Make API request
            makeSentimentAnalysisRequest(onCompletion: { documents in
                let sentiment = documents!.documents[0].sentiment!
                // Store it in Core Data
                self.saveSentimentToCoreData(sentimentValue: sentiment)
                // Update the label
                self.updateSentimentLabel(sentiment: sentiment)
            })
            
        }
        
    }
    
    func updateTranscriptionLabel(transcription:String) {
        DispatchQueue.main.async {
            self.transcribeText.text = transcription
        }
    }
    
    func saveTranscriptionToCoreData(transcriptionValue:String){
        recordingToTranscribe.setValue(transcriptionValue, forKey: "transcription")
        appDelegate.saveContext()
    }
    
    func updateSentimentLabel(sentiment: String) {
        DispatchQueue.main.async {
            switch sentiment {
            case "neutral":
                self.sentimentText.text = "Overall feeling: Neutral"
                self.SentimentEmoji.text = "😐"
            case "positive":
                self.sentimentText.text = "Overall feeling: Positive"
                self.SentimentEmoji.text = "😃"
            case "negative":
                self.sentimentText.text = "Overall feeling: Negative"
                self.SentimentEmoji.text = "☹️"
            default:
                self.sentimentText.text = ""
                self.SentimentEmoji.text = ""
            }
        }
    }
    
    func saveSentimentToCoreData(sentimentValue:String){
        recordingToTranscribe.setValue(sentimentValue, forKey: "sentimentValue")
        appDelegate.saveContext()
    }
    
    /**
     1. Check if transcription is available locally
     1. If yes, updateLabel
     1. Check if sentiment is available locally
     1. If yes, update sentimentLabel
     2. If no, make Sentiment API call
     1. Store it in Core Data
     2. Update sentimentLabel
     2. If no,
     1. Get transcription permissions
     If we already have permissions, we begin transcribing
     If we don't, we ask for permissions
     1. Make transcription request
     1. Make Sentiment API call
     1. Store it in Core Data
     2. Update sentimentLabel
     */
    
    
    
    func makeTranscriptionRequest(url: URL, onCompletion: @escaping (String) -> ()) {
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
                onCompletion(result.bestTranscription.formattedString)
            }
        }
    }
    
    

    func makeSentimentAnalysisRequest(onCompletion: @escaping (Documents?) -> ()) {
        let urlString = "https://vocalize.cognitiveservices.azure.com/text/analytics/v3.0/sentiment"
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
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(APIKey.ClientSecret, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No Data")
                return
            }
            
            var sentimentData: Documents?
            let decoder = JSONDecoder()
            do {
                sentimentData = try decoder.decode(Documents.self, from: data)
                onCompletion(sentimentData)
                
            } catch {
                print("Error Occured while decoding. \(error)")
            }
        }
        
        task.resume()
    }
}

