//
//  ShareItem.swift
//  PinpinboxShareExtension
//
//  Created by Antelis on 2019/3/19.
//  Copyright © 2019 Angus. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import AVFoundation

extension URL {
    
    func queryParam(_ param : String) -> String {
        if let components = URLComponents(url: self, resolvingAgainstBaseURL: false), let items = components.queryItems {
            let result = items.filter { (item) -> Bool in
                return item.name == param
            }
            if let item = result.first, let value = item.value {
                return value
            }
        }
        return ""
    }
    
    func containsString(_ str: String) -> Bool {
        return self.path.contains(str)
        
    }
}

class ShareItem : NSObject {
    open var url : URL? {
        didSet {
            if let url = self.url, let objtype = self.objType, objtype == kUTTypeMovie as String {
                let sourceasset = AVURLAsset(url: url)
                let duration = sourceasset.duration
                self.vidDuration = Int(duration.seconds)
                
                if let d = self.itemDelegate, vidDuration > 31 {
                    d.processInvalidItem(self)
                    return;
                }
                let generator = AVAssetImageGenerator(asset: sourceasset)
                do {
                    let c = try generator.copyCGImage(at: CMTimeMake(value: 1, timescale: 1000), actualTime: nil)
                    self.thumbnail = UIImage(cgImage: c)
                    guard let img = self.thumbnail else {return}
                    self.inspectThumbnailTone(img)
                } catch let error {
                    print("Error in load asset image : \(error.localizedDescription)")
                }
            }

        }
        
    }
    var thumbURL : URL?
    var thumbnail: UIImage? {
        didSet {
            guard let img = self.thumbnail else {return}
            self.inspectThumbnailTone(img)
        }
    }
    var objType : String?
    var shareItem : NSItemProvider?
    var hasVideo : Bool = false
    var thumbIsDark : Bool = false
    var vidDuration: Int = 0
    var taskId: String?
    
    private var itemDelegate: ItemContentDelegate?
    
    convenience init(_ item: NSItemProvider?,_ type: String,_ delegate: ItemContentDelegate? ) {
        self.init()
        self.shareItem = item
        self.itemDelegate = delegate
    
        self.hasVideo = false
        self.thumbIsDark = false
        self.vidDuration = 0
        self.objType = type
        self.shareItem = item
        self.taskId = UUID.init().uuidString
        
        postLoadShareItem()
    }
    
    private func inspectThumbnailTone(_ image : UIImage) {
        
    }
    
    private func loadThumbnailWithPostload(_ postload: ItemPostLoadDelegate?) {
        guard let load = postload,  let otype = self.objType else {return }
        if let thumbnail = thumbnail {
            DispatchQueue.main.async {
                load.loadCompletedWith(thumbnail, otype, self.hasVideo, isDark: self.thumbIsDark)
            }
        } else if let thumbURL = self.thumbURL {
            DispatchQueue.global(qos: .default).async {
                do {
                    let data = try Data(contentsOf: thumbURL)
                    DispatchQueue.main.async {
                        if let img = UIImage(data: data) {
                            self.thumbnail = img
                            load.loadCompletedWith(img, otype, self.hasVideo, isDark: self.thumbIsDark)
                        }
                    }
                    
                } catch {
                    
                }
            }
        } else {
            self.postLoadShareItem()
            //[self performSelector:@selector(loadThumbnailWithPostload:) withObject:postload afterDelay:3];
        }
        
    }
    
    private func tryLoadThumbnail() {
        if let objtype = self.objType, let url = self.url {
            if objtype == kUTTypeURL as String || objtype == kUTTypeText as String {
                var videoID : String?
                if url.containsString("youtu") {
                    if let host = url.host, host.contains("youtube.com") {
                        videoID = url .queryParam("v")
                    } else if let host = url.host, host.contains("youtu.be") {
                        videoID = url.lastPathComponent
                    }
                    if let videoID = videoID {
                        let th = String(format:"http://img.youtube.com/vi/%@/hqdefault.jpg" , videoID)
                        self.thumbURL = URL(string: th)
                    } else {
                        self.thumbnail = UIImage(named:"videobase.jpg")
                    }
                    self.hasVideo = true
                    
                } else if url.containsString("vimeo") {
                    self.hasVideo = true
                    let videoPath = url.lastPathComponent
                    let realLink = String(format:"https://vimeo.com/api/oembed.json?url=https://vimeo.com/%@&width=960", videoPath)
                    if let encoded = realLink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let vurl = URL(string: encoded) {
                        do {
                            let data = try Data(contentsOf: vurl)
                        
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            
                            if let json = json, let p = json["thumbnail_url"], let p1 = p as? String {
                                self.thumbURL = URL(string: p1)
                                return
                            }
                            
                        } catch {
                            
                        }
                    }
                    
                    //  nothing found
                    self.thumbnail = UIImage(named:"videobase.jpg")
                    
                } else if url.containsString("facebook") {
                    self.thumbnail = UIImage(named:"videobase.jpg")
                    self.hasVideo = true
                } else {
                    self.hasVideo = false
                    if let item = self.shareItem {
                        if item.hasItemConformingToTypeIdentifier("public.file-url") && item.hasItemConformingToTypeIdentifier("public.image") {
                            self.objType = kUTTypeImage as String
                            self.thumbnail = UIImage(contentsOfFile: url.path)
                        } else if let delegate = self.itemDelegate{
                            delegate.processInvalidItem(self)
                        }
                    }
                }
            } else if objtype == kUTTypeMovie as String, let item = self.shareItem {
                self.hasVideo = true
                item.loadPreviewImage(options: [:]) { (coding, error) in
                    if let img = coding as? UIImage {
                        self.thumbnail = img
                    }
                }
                
            } else if objtype == kUTTypeImage as String {
                self.hasVideo = false
                self.thumbnail = UIImage(contentsOfFile: url.path)
            } else if objtype == kUTTypePDF as String {
                self.hasVideo = false;
                loadThumbnailOtherway()
            }
            
        }
    }
    
    private func loadThumbnailOtherway() {
        if let item = shareItem {
            item.loadPreviewImage(options: [:]) { (coding, error) in
                if let _ = coding, let image = coding as? UIImage {
                    self.thumbnail = image
                } else if let url = self.url {
                    if url.startAccessingSecurityScopedResource() {
                        let cr = NSFileCoordinator()
                        cr.coordinate(readingItemAt: url, options: [.immediatelyAvailableMetadataOnly], error: nil, byAccessor: { (newurl) in
                            if let res = try? newurl.resourceValues(forKeys: [.thumbnailDictionaryKey]),
                                let dict = res.thumbnailDictionary {
                                
                                let image = dict[.NSThumbnail1024x1024SizeKey]
                                self.thumbnail = image
                                return
                            }
                            self.thumbnail = UIImage(named:"videobase.jpg")
                        })
                    }
                    url.stopAccessingSecurityScopedResource()
                }
            }
        }
    }
    
    private func postLoadShareItem() {
        guard let item = self.shareItem, let objtype = self.objType else { return }
        item.loadItem(forTypeIdentifier:objtype , options: nil) { (coding, error) in
            if error == nil {
                if objtype == kUTTypeText as String {
                    if let text = coding as? String {
                        if !text.hasPrefix("file://") {
                            if let u = URL(string: text) {
                                self.url = u
                            }
                        }
                    } else if let url = coding as? URL {
                        self.url = url
                    }
                    
                    
                }
                self.tryLoadThumbnail()
            }
            
        }
    }
        
}
