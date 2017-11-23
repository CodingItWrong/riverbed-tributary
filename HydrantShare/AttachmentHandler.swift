//
//  AttachmentHandler.swift
//  HydrantShare
//
//  Created by Josh Justice on 11/23/17.
//  Copyright © 2017 NeedBee. All rights reserved.
//

import Foundation
import MobileCoreServices

struct AttachmentHandler {
    func getURL(attachments: [NSItemProvider], completion: @escaping (Result<URL>) -> Void)
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
}
