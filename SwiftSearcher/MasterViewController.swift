//
//  MasterViewController.swift
//  SwiftSearcher
//
//  Created by Mac Bellingrath on 8/14/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit
import SafariServices
import CoreSpotlight
import MobileCoreServices

class MasterViewController: UITableViewController, SFSafariViewControllerDelegate {

  
    var projects = [[String]]()
    var favorites = [Int]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.editing = true
        tableView.allowsSelectionDuringEditing = true
        
        projects.append(["Project 1: Storm Viewer", "Constants and variables, UITableView, UIImageView, NSFileManager, storyboards"])
        projects.append(["Project 2: Guess the Flag", "@2x and @3x images, asset catalogs, integers, doubles, floats, operators (+=, ++, and --), UIButton, enums, CALayer, UIColor, random numbers, actions, string interpolation, UIAlertController"])
        projects.append(["Project 3: Social Media", "UIBarButtonItem, UIActivityViewController, the Social framework, NSURL"])
        projects.append(["Project 4: Easy Browser", "loadView(), WKWebView, delegation, classes and structs, NSURLRequest, UIToolbar, UIProgressView., key-value observing"])
        projects.append(["Project 5: Word Scramble", "NSString, closures, method return values, booleans, NSRange"])
        projects.append(["Project 6: Auto Layout", "Get to grips with Auto Layout using practical examples and code"])
        projects.append(["Project 7: Whitehouse Petitions", "JSON, NSData, UITabBarController"])
        projects.append(["Project 8: 7 Swifty Words", "addTarget(), enumerate(), countElements(), find(), join(), property observers, range operators."])
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let savedFavorites = defaults.objectForKey("favorites") as? [Int]{
            favorites = savedFavorites

        }
    
    }

    override func viewWillAppear(animated: Bool) {
          }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let project = projects[indexPath.row]
        cell.textLabel?.attributedText = makeAttributedString(title: project[0], subtitle: project[1])
        
        if favorites.contains(indexPath.row){
        
            cell.editingAccessoryType = .Checkmark
            
        } else {
            cell.editingAccessoryType = .None
        }
        
        return cell
        
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        showTutorial(indexPath.row)
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        if favorites.contains(indexPath.row) {
            return UITableViewCellEditingStyle.Delete
        } else {
            return UITableViewCellEditingStyle.Insert
        }
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Insert {
            favorites.append(indexPath.row)
            indexItem(indexPath.row)
        } else {
            if let index = favorites.indexOf(indexPath.row){
                favorites.removeAtIndex(index)
                deindexItem(indexPath.row)
            }
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(favorites, forKey: "favorites")
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
       
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func makeAttributedString(title title: String, subtitle: String) -> NSAttributedString{
        let titleAttributes = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.purpleColor()]
        let subtitleAttributes = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)]
        
        let titleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
        let subtitleString = NSAttributedString(string: subtitle, attributes: subtitleAttributes)
        
        titleString.appendAttributedString(subtitleString)
        return titleString
    }
    
    //MARK: - SFSafariViewController
    
    func showTutorial(which: Int) {
        if let url = NSURL(string: "https://www.hackingwithswift.com/read/\(which + 1)"){
            let vc = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
            vc.delegate = self
            presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: - Core Spotlight
    
    func indexItem(which: Int) {
        let project = projects[which]
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = project[0]
        attributeSet.contentDescription = project[1]
        
        let item = CSSearchableItem(uniqueIdentifier: "\(which)", domainIdentifier: "com.mbellingrath", attributeSet: attributeSet)
        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([item]) { (error: NSError?) -> Void in
            if let error = error {
                print("Indexing Error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed")
            }
        }
        
    }
    
    func deindexItem(which: Int){
        CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithIdentifiers(["\(which)"]) { (error: NSError?) -> Void in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully removed")
            }
        }
        
    }

    

}

