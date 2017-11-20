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

    override func didSelectPost() {
        let item: NSExtensionItem = extensionContext!.inputItems[0] as! NSExtensionItem
        let attachment = item.attachments![0] as! NSItemProvider
        attachment.loadItem(forTypeIdentifier: kUTTypeURL as String) { data, error in
            switch data {
            case let sharedURL as URL:
                // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
                let webhookURLString = "http://localhost:3000/webhooks/hydrant"
                let webhookURL = URL(string: webhookURLString)!
                let session = URLSession.shared
                var request = URLRequest(url: webhookURL)
                let bodyDict = ["url": sharedURL.absoluteString]
                let bodyData = try! JSONSerialization.data(withJSONObject: bodyDict, options: [])
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST";
                request.httpBody = bodyData;
                
                let task = session.dataTask(with: request)
                task.resume()
                
                // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            default:
                NSLog("no url found")
            }
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
