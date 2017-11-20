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

    override func didSelectPost() {
        getURLAttachment() { sharedURL in
            // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
            let webhookURLString = "http://localhost:3000/webhooks/hydrant"
            let webhookURL = URL(string: webhookURLString)!
            let session = URLSession.shared
            var request = URLRequest(url: webhookURL)
            let bodyDict = [
                "url": sharedURL.absoluteString,
                "message": self.contentText,
                ]
            let bodyData = try! JSONSerialization.data(withJSONObject: bodyDict, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST";
            request.httpBody = bodyData;
            
            let task = session.dataTask(with: request)
            task.resume()
            
            // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
