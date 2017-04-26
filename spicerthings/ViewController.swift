//
//  ViewController.swift
//  spicerthings
//
//  Created by futurehelp on 4/18/17.
//  Copyright © 2017 com.untitled. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController, UITextViewDelegate {
    
    
    //  Declare controls
    @IBOutlet weak var imageViewSpicer: UIImageView!
    @IBOutlet weak var labelSpicerThings: UILabel!
    @IBOutlet weak var textFieldSpicerThings: UITextView!
    @IBOutlet weak var textFieldSpicerFinish: UITextView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    var labelPlaceHolder : UILabel!
    
    //  SpicerItem object
    var items: [SpicerItem] = []
    
    //  Array for all English articles
    var articles: [String] = ["the", "a", "an"]
    
    //  Array for all English prepositions
    var prepositions: [String] = ["with", "at", "from", "into", "during", "including", "until", "against", "among", "throughout", "despite", "towards", "upon", "concerning", "of", "to", "in", "for", "on", "by", "about", "like", "through", "over", "before", "between", "after", "since", "without", "under", "within", "along", "following", "across", "behind", "beyond", "plus", "except", "but", "up", "out", "around", "down", "off", "above", "near"]
    
    //  Array for English subject pronouns
    var subjectPronouns: [String] = ["i", "you", "he", "she", "it", "they", "we"]
    
    //  Array for English object pronouns
    var objectPronouns: [String] = ["me", "you", "him", "her", "it", "us", "them"]
    
    //  Array for to be verb
    var toBeVerb: [String] = ["am", "is", "are", "was", "were", "have", "has"]
    
    //  Array for to want verb
    var toWantVerb: [String] = ["want", "wants", "wanted", "wanting"]
    
    //  Image array for animation
    let imageArray = [UIImage(named: "left.png")!, UIImage(named: "straight.png")!, UIImage(named: "right.png")!]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Hide the keyboard.
        self.hideKeyboardWhenTappedAround()
        
        // Set the background.
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "hipster-background.png")
        self.view.insertSubview(backgroundImage, at: 0)
        
        //  Define the delegate.
        textFieldSpicerThings.delegate = self as UITextViewDelegate
        //  Create a UILabel object.
        labelPlaceHolder = UILabel()
        labelPlaceHolder.text = "We landed on the moon."
        labelPlaceHolder.font = UIFont.italicSystemFont(ofSize: (textFieldSpicerThings.font?.pointSize)!)
        labelPlaceHolder.sizeToFit()
        //  Attach the label object to the TextField.
        textFieldSpicerThings.addSubview(labelPlaceHolder)
        //  Set the label object properties.
        labelPlaceHolder.frame.origin = CGPoint(x: 5, y: (textFieldSpicerThings.font?.pointSize)! / 2)
        labelPlaceHolder.textColor = UIColor.lightGray
        labelPlaceHolder.isHidden = !textFieldSpicerThings.text.isEmpty
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        labelPlaceHolder.isHidden = !textView.text.isEmpty
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func buttonCopy(_ sender: Any) {
        UIPasteboard.general.string = textFieldSpicerFinish.text
        let alert = UIAlertController(title: "SPICER THINGS", message: "Spicer copied to the clipboard!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Thanks!", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func buttonGetSpicerThings(_ sender: Any) {
        
        //  Load the spicer animation.
        imageViewSpicer.animationImages = imageArray
        imageViewSpicer.animationDuration = 1.0
        imageViewSpicer.animationRepeatCount = 1
        imageViewSpicer.startAnimating()
        
        
        let url = NSURL(string: _JSON_PAGE_LINK)!
        
        let task = URLSession.shared.dataTask(with: url as URL) { (data, response, error) -> Void in
            if let urlContent = data {
                do {
                    //  Get the JSON result.
                    let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    //  Convert the JSON result into an array to load into SpicerItem objects.
                    let jsonResultArray = (jsonResult as! NSMutableArray)
                    
                    //  Get the JSON element count.
                    let jsonResultArrayCount = jsonResultArray.count
                    
                    //  Create and load the objects.
                    for i in 0...(jsonResultArrayCount-1)
                    {
                        if let dictionaryValue = jsonResultArray[i] as? NSDictionary
                        {
                            let value = dictionaryValue["quote"] as? NSString
                            self.items.append(SpicerItem(quote: value! as String))
                        }
                    }
                    
                    //  Set the sentence to lowercase.
                    let spicerMessage = self.textFieldSpicerThings.text.lowercased()
                    //  Remove all puncuation marks.
                    let strippedSpicer = removeSpecialCharsFromString(text: spicerMessage)
                    //  Run generateSpicerThings.
                    let newQuote = self.generateSpicerThings(message: strippedSpicer)
                    
                    //  Post the new result.
                    DispatchQueue.main.async(){
                        self.textFieldSpicerFinish.text = newQuote
                    }
                } catch {
                    print("Error JSON")
                }
            }
        }
        
        task.resume()
    }
    
    func generateSpicerThings(message: String) -> String {
        
        
        var flagged = 0
        let spicerWords = message.characters.split{$0 == " "}.map(String.init)
        var strippedWords = [String]()
        var spicerResults = [String]()
        var newQuote = ""
        var spicerQuote = ""
        
        //  Run through all the words and remove all prepositions, pronouns, and articles.
        //  If any are found, set the flag to 1, and only store words with a flag of 0.
        for words in spicerWords
        {
            for i in 0...(articles.count-1)
            {
                if(articles[i] == words)
                {
                    flagged = 1
                }
            }
            for i in 0...(prepositions.count-1)
            {
                if(prepositions[i] == words)
                {
                    flagged = 1
                }
            }
            for i in 0...(subjectPronouns.count-1)
            {
                if(subjectPronouns[i] == words)
                {
                    flagged = 1
                }
            }
            for i in 0...(objectPronouns.count-1)
            {
                if(objectPronouns[i] == words)
                {
                    flagged = 1
                }
            }
            for i in 0...(toBeVerb.count-1)
            {
                if(toBeVerb[i] == words)
                {
                    flagged = 1
                }
            }
            for i in 0...(toWantVerb.count-1)
            {
                if(toWantVerb[i] == words)
                {
                    flagged = 1
                }
            }
            if(flagged != 1)
            {
                strippedWords.append(words)
            }
            flagged = 0
        }
        
        //  Run through all the quotes and see if they are found in the sentence.
        for objects in items {
            for word in strippedWords {
                if objects.quote.lowercased().range(of:word) != nil {
                    newQuote = objects.quote
                    //  Save all quotes that are correlated with the sentence.
                    spicerResults.append(newQuote)
                }
            }
        }
        
        //  Get count of possible matches.
        let spicerResultsCount = spicerResults.count
        
        if(spicerResultsCount > 0)
        {
            //  If multiple quotes exist for a word, then randomize the array.
            let randomIndex = Int(arc4random_uniform(UInt32(spicerResults.count)))
            print("randomIndex: \(randomIndex)")
            print(spicerResults[randomIndex])
            spicerQuote = spicerResults[randomIndex]
        }
        else
        {
            //  If no quote matches any of the words, use the default quote.
            spicerQuote = "Regardless of what people say, there is always 1.5 million jelly beans per package."
        }
        
        //  Return randomized array.
        return spicerQuote
    }
    
    // Button call to send to twitter.
    @IBAction func buttonTwitter(_ sender: Any) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText(textFieldSpicerThings.text + " 🗣👇\n" + textFieldSpicerFinish.text + "\n#spicerthings")
            self.present(twitterSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

//  Extension to hide the keyboard.
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

//  Remove punctuation characters from the phrase.
func removeSpecialCharsFromString(text: String) -> String {
    let okayChars : Set<Character> =
        Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890".characters)
    return String(text.characters.filter {okayChars.contains($0) })
}

