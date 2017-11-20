//
//  ShareViewController.swift
//  HydrantShare
//
//  Created by Josh Justice on 11/20/17.
//  Copyright © 2017 NeedBee. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    private func getURLAttachment(completion: @escaping (URL) -> Void) {
        let item: NSExtensionItem = extensionContext!.inputItems[0] as! NSExtensionItem
        let attachment = item.attachments![0] as! NSItemProvider
        attachment.loadItem(forTypeIdentifier: kUTTypeURL as String) { (data, error) in
            switch data {
            case let url as URL:
                // todo: figure out how to pass IUO error
                completion(url)
            default:
                NSLog("no url found")
            }
        }
    }

    private func postWebhook(bodyDict: [String: String?]) {
        let webhookURLString = "http://localhost:3000/webhooks/hydrant"
        let webhookURL = URL(string: webhookURLString)!
        let session = URLSession.shared
        var request = URLRequest(url: webhookURL)
        let bodyData = try! JSONSerialization.data(withJSONObject: bodyDict, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST";
        request.httpBody = bodyData;
        
        task.resume()
    }
    
    override func didSelectPost() {
        getURLAttachment() { sharedURL in
            let bodyDict = [
                "url": sharedURL.absoluteString,
                "title": self.contentText,
                ]
            self.postWebhook(bodyDict: bodyDict)
            
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)

        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
