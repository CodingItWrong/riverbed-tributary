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

enum ShareError: LocalizedError {
    case urlNotFound
    
    var errorDescription: String? {
        switch self {
        case .urlNotFound: return "URL not found"
        }
    }
}

class ShareViewController: SLComposeServiceViewController {

    private let webhookURL = Config.webhookURL
    private let apiKey = Config.apiKey
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    private func getURLAttachment(completion: @escaping (Result<URL>) -> Void) {
        let item: NSExtensionItem = extensionContext!.inputItems[0] as! NSExtensionItem
        let attachments = item.attachments!.map({untypedAttachment in
            return untypedAttachment as! NSItemProvider
        })
        getURLAttachment(attachments: attachments, completion: completion)
    }
    
    private func getURLAttachment(attachments: [NSItemProvider], completion: @escaping (Result<URL>) -> Void)
    {
        // log all attachment types
        for attachment in attachments {
            NSLog("Attachment of type \(attachment.registeredTypeIdentifiers.joined(separator: ", "))")
        }
        
        // first, look for URL
        let urlType = kUTTypeURL as String
        for attachment in attachments {
            if attachment.hasItemConformingToTypeIdentifier(urlType) {
                attachment.loadItem(forTypeIdentifier: urlType) { (data, error) in
                    switch data {
                    case let url as URL:
                        // todo: figure out how to pass IUO error
                        NSLog("Found attached URL \(url.absoluteString)")
                        completion(.success(url))
                    default:
                        NSLog("Attachment said it was a URL, but did not return one")
                        completion(.failure(ShareError.urlNotFound))
                    }
                }
                return
            }
        }

        // if no URL found, look for text
        let plainTextType = kUTTypePlainText as String
        for attachment in attachments {
            if attachment.hasItemConformingToTypeIdentifier(plainTextType) {
                attachment.loadItem(forTypeIdentifier: plainTextType) { (data, error) in
                    switch data {
                    case let urlString as String:
                        NSLog("Found attached string \(urlString)")
                        if let url = URL(string: urlString) {
                            completion(.success(url))
                        } else {
                            NSLog("There was a text attachment, but it was not a valid URL")
                        }
                    default:
                        NSLog("Attachment said it was plain text, but did not return a String")
                    }
                }
                return
            }
        }
        
        // if no URL or text found, fail
        NSLog("No URL or plain text attachments found")
        completion(.failure(ShareError.urlNotFound))
    }

    private func postWebhook(bodyDict: [String: String?], completion: @escaping () -> Void) {
        let session = URLSession.shared
        var request = URLRequest(url: webhookURL)
        let bodyData = try! JSONSerialization.data(withJSONObject: bodyDict, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST";
        request.httpBody = bodyData;
        
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                self.alert(message: error!.localizedDescription, completion: completion)
                return
            }
            
            guard let response = response,
                  let httpResponse = response as? HTTPURLResponse else {
                self.alert(message: "Unexpected response type received", completion: completion)
                return
            }
            
            guard httpResponse.statusCode == 201 else {
                self.alert(message: "Unexpected response: \(httpResponse.statusCode)", completion: completion)
                return
            }
            
            self.alert(message: "Saved to Firehose.", completion: completion)
        }
        task.resume()
    }
    
    private func alert(message: String, completion: (() -> Void)?) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?();
        }
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
    private func done() {
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func didSelectPost() {
        getURLAttachment() { result in
            switch result {
            case .success(let sharedURL):
                let bodyDict = [
                    "url": sharedURL.absoluteString,
                    "title": self.contentText,
                    ]
                self.postWebhook(bodyDict: bodyDict, completion: self.done)
            case .failure(let error):
                self.alert(message: "An error occurred: \(error.localizedDescription)", completion: self.done)
            }
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}

