//
//  ActionViewController.swift
//  Extension
//
//  Created by Tamim Khan on 17/3/23.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController, UITableViewDelegate {
    @IBOutlet var script: UITextView!
    
   
    
    var pageTitle = ""
    var pageUrl = ""
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: pageUrl) {
                    let defaults = UserDefaults.standard
                    if let savedScript = defaults.string(forKey: url.host ?? "") {
                        script.text = savedScript
                    }
                }
        
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Examples", style: .plain, target: self, action: #selector(showExamples))
        
        
        let notifitionCenter = NotificationCenter.default
        notifitionCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notifitionCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem{
            if let itemProvider = inputItem.attachments?.first{
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String){
                    [weak self] (dict, error) in
                    
                    guard let iteamDictonary = dict as? NSDictionary else {return}
                    guard let javaScriptValues = iteamDictonary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else {return}
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageUrl = javaScriptValues["URL"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                        
                        

                      
                    }
                }
            }
        }
    }
    @IBAction func done() {
       
        
        
       let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text]
        let webDictonary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictonary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        
        
        if let url = URL(string: pageUrl) {
                   let defaults = UserDefaults.standard
                   defaults.set(script.text, forKey: url.host ?? "")
               }
        
        extensionContext?.completeRequest(returningItems: [item])
        
        
       
       

        
    }
    
    @objc func adjustForKeyboard(notification: Notification){
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, to: view.window)
        
        
        if notification.name == UIResponder.keyboardWillHideNotification{
            script.contentInset = .zero
        }else{
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
    
    @objc func showExamples() {
            let alertController = UIAlertController(title: "Choose Example", message: nil, preferredStyle: .actionSheet)

            let example1Action = UIAlertAction(title: "Alert Document Title", style: .default) { [weak self] _ in
                self?.script.text = "alert(document.title);"
            }
//
//            let example2Action = UIAlertAction(title: "Console Log Page URL", style: .default) { [weak self] _ in
//                self?.script.text = "console.log(location.href);"
//            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

            alertController.addAction(example1Action)
//            alertController.addAction(example2Action)
            alertController.addAction(cancelAction)

            present(alertController, animated: true)
        
        
        }
    
    



}
