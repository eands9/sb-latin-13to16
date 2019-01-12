//
//  ViewController.swift
//  SpellingBee-4th
//
//  Created by Eric Hernandez on 11/30/18.
//  Copyright © 2018 Eric Hernandez. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class ViewController: UIViewController {

    //text to speech
    @IBOutlet weak var answerTxt: UITextField!
    @IBOutlet weak var progressLbl: UILabel!
    @IBOutlet weak var checkAnsBtn: UIButton!
    @IBOutlet weak var repeatBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var showBtn: UIButton!
    @IBOutlet weak var sentenceBtn: UIButton!
    
    var questionNumber: Int = 0
    var randomPick: Int = 0
    var correctAnswers: Int = 0
    var numberAttempts: Int = 0
    var totalNumberOfQuestions: Int = 0
    
    var markedQuestionsCount: Int = 0
    var isTesting: Bool = true
    var isLoadedTrackedQuestions: Bool = false
    var markedQuestions = [Word]()
    
    var IsCorrect: Bool = true
    var isStartOver: Bool = false
    var wrongAlready: Bool = false
    
    let congratulateArray = ["Great Job", "Excellent", "Way to go", "Alright", "Right on", "Correct", "Well done", "Awesome"]
    let retryArray = ["Try again","Oooops"]
    let allWords = WordBank()
    
    // Speech to Text
    @IBOutlet weak var startStopBtn: UIButton!
    
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US")) //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    var lang: String = "en-US"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readMe(myText: "Spell \(allWords.list[0].spellWord).")
        
        //Keep Recording Disabled for now
        startStopBtn.isEnabled = false
        
        /*
        //speech to text
        startStopBtn.isEnabled = false  //2
        speechRecognizer?.delegate = self as? SFSpeechRecognizerDelegate  //3
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.startStopBtn.isEnabled = isButtonEnabled
            }
        }
        */
        // Get a count of number of questions
        let numberOfQuestions = allWords.list
        // Get the size of the array
        totalNumberOfQuestions = numberOfQuestions.count
        
        self.answerTxt.becomeFirstResponder()
    }
    /* Disable Audio
    //speech to text
    @IBAction func startStopAct(_ sender: Any) {
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            startStopBtn.isEnabled = false
            startStopBtn.setTitle("Start Recording", for: .normal)
            checkBtnIsTesting()
            
        } else {
            startRecording()
            startStopBtn.setTitle("Stop Recording", for: .normal)
            
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record, mode: .default)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.answerTxt.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.startStopBtn.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        answerTxt.text = "Say something, I'm listening!"
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            startStopBtn.isEnabled = true
        } else {
            startStopBtn.isEnabled = false
        }
    }
*/
    
    //text to speech
    @IBAction func checkBtn(_ sender: Any) {
        disableAllBtn()
        if isTesting == true {
            checkBtnIsTesting()
        }
        else {
            checkBtnIsReview()
        }
        
    }
    
    func checkBtnIsTesting(){
        let spellWord = allWords.list[questionNumber].spellWord
        
        if spellWord == answerTxt.text?.lowercased() {
            //congratulate
            randomPositiveFeedback()
            
            //Wait 2 seconds before showing the next question
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when){
                //spell next word
                //self.questionNumber += 1
                self.nextWordIsTesting()
            }
            
            //clear texview
            answerTxt.text = ""
        
            //increment number of correct answers
            correctAnswers += 1
            numberAttempts += 1
            updateProgress()
            
        }
        else {
            randomTryAgain()
            numberAttempts += 1
            updateProgress()
            
            IsCorrect = false
            wrongAlready = true
        }
        enableAllBtn()
    }
    
    func trackMarkedQuestions(){
        let trackedSentence = allWords.list[questionNumber].fullSentence
        let trackedWord = allWords.list[questionNumber].spellWord
        
        markedQuestions.append(Word(word: trackedWord, sentence: trackedSentence))
        markedQuestionsCount += 1
        

    }
    func checkBtnIsReview(){
        let correctAnswer = markedQuestions[questionNumber].spellWord
        
        if answerTxt.text == correctAnswer{
            //congratulate
            randomPositiveFeedback()
            
            //questionNumber += 1
            //next Question
            nextWordIsReview()
            /*
             correctAnswers += 1
             numberAttempts += 1
             updateProgress()
             numberFailed = 0
             */
        }
            
        else{
            disableAllBtn()
            readMe(myText: "The correct answer is")
            answerTxt.textColor = (UIColor.red)
            answerTxt.text = correctAnswer
            

            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when){
                //next problem
                self.nextWordIsReview()
            }
        }

    }
    
    func nextWordIsTesting(){

        if IsCorrect == false{
            trackMarkedQuestions()
            IsCorrect = true
        }
        
        answerTxt.text = ""
        
        if isStartOver == true {
            questionNumber = 0
            isStartOver = false
        }
        else {
            questionNumber += 1
        }
        
        
        //if there are 14 questions, the number below should be 13 (always one less)
        if questionNumber <= totalNumberOfQuestions - 1 {
            //wordLabel.text = allWords.list[questionNumber].spellWord
            readMe(myText: "Spell \(allWords.list[questionNumber].spellWord).")
            answerTxt.text = ""
        }
        else if markedQuestionsCount == 0 {

            let alert = UIAlertController(title: "Awesome", message: "You've finished all the questions, do you want to start over again?", preferredStyle: .alert)
            
            let restartAction = UIAlertAction(title: "Restart", style: .default, handler: { (UIAlertAction) in
                self.startOver()
            })
            
            alert.addAction(restartAction)
            present(alert, animated: true, completion: nil)
        }
        else {
            isTesting = false
            disableAllBtn()
            readMe(myText: "Let us review")
            
            let when1 = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when1){
                //spell next word
                self.questionNumber = 0
                self.readMe(myText: "Spell \(self.markedQuestions[self.questionNumber].spellWord).")
                self.answerTxt.text = ""
                self.answerTxt.textColor = (UIColor.red)
                self.enableAllBtn()
            }
        }
        enableAllBtn()
    }
    
    func nextWordIsReview(){
        questionNumber += 1
        answerTxt.text = ""
        disableAllBtn()
        if questionNumber <= markedQuestionsCount - 1  {
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when){
                self.readMe(myText: "Spell \(self.markedQuestions[self.questionNumber].spellWord).")
                self.answerTxt.text = ""
                self.enableAllBtn()
            }
        }
        else {

            let alert = UIAlertController(title: "Awesome", message: "You've finished all the questions, do you want to start over again?", preferredStyle: .alert)
            
            let restartAction = UIAlertAction(title: "Restart", style: .default, handler: { (UIAlertAction) in
                self.startOver()
            })
            
            alert.addAction(restartAction)
            present(alert, animated: true, completion: nil)
        }
        enableAllBtn()
    }
    
    @IBAction func sentenceBtn(_ sender: Any) {
        answerTxt.text = allWords.list[questionNumber].fullSentence
    }
    
    @IBAction func showWordBtn(_ sender: Any) {
        showWord()
        numberAttempts += 1
        updateProgress()
    }
    
    func showWord(){
        checkAnsBtn.isEnabled = false
        if isTesting == true && wrongAlready == false {
            answerTxt.text = allWords.list[questionNumber].spellWord.uppercased()
            trackMarkedQuestions()
        }
        else if isTesting == true && wrongAlready == true{
            answerTxt.text = allWords.list[questionNumber].spellWord.uppercased()
        }
        else {
            answerTxt.text = markedQuestions[questionNumber].spellWord.uppercased()
        }
    }
    
    @IBAction func nextSpellWord(_ sender: Any) {
        if isTesting == true {
            nextWordIsTesting()
        }
        else {
            nextWordIsReview()
        }
    }
    
    func readMe( myText: String) {
        let utterance = AVSpeechUtterance(string: myText )
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    func startOver(){
        questionNumber = 0
        correctAnswers = 0
        numberAttempts = 0
        updateProgress()

        markedQuestionsCount = 0
        markedQuestions = [Word]()
        
        isTesting = true
        isStartOver = true
        answerTxt.textColor = (UIColor.black)
        nextWordIsTesting()
    }
    func randomPositiveFeedback(){
        randomPick = Int(arc4random_uniform(8))
        checkAnsBtn.isEnabled = false
        readMe(myText: congratulateArray[randomPick])
    }
    func randomTryAgain(){
        randomPick = Int(arc4random_uniform(2))
        readMe(myText: retryArray[randomPick])
    }
    func readSentence(){
        if isTesting == true {
            let spellSentence = allWords.list[questionNumber].fullSentence
            readMe(myText: spellSentence)
        }
        else {
            let spellSentence = markedQuestions[questionNumber].fullSentence
            readMe(myText: spellSentence)
        }
    }
    
    func updateProgress(){
        progressLbl.text = "Correct/Attempt: \(correctAnswers) / \(numberAttempts)"
    }
    
    @IBAction func repeatBtn(_ sender: Any) {
        if isTesting == true {
            readMe(myText: allWords.list[questionNumber].spellWord)
        }
        else {
            readMe(myText: markedQuestions[questionNumber].spellWord)
        }
    }
    
    func disableAllBtn(){
        checkAnsBtn.isEnabled = false
        repeatBtn.isEnabled = false
        showBtn.isEnabled = false
        sentenceBtn.isEnabled = false
        nextBtn.isEnabled = false
    }
    func enableAllBtn(){
        checkAnsBtn.isEnabled = true
        repeatBtn.isEnabled = true
        showBtn.isEnabled = true
        sentenceBtn.isEnabled = true
        nextBtn.isEnabled = true
    }
}

