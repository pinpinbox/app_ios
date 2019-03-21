//
//  UIHelper.swift
//  PinpinboxShareExtension
//
//  Created by Antelis on 2019/3/21.
//  Copyright © 2019 Angus. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import UserNotifications
import AVFoundation
import QuartzCore


class  ThumbnailCollectionViewCell : UICollectionViewCell,CAAnimationDelegate {
    @IBOutlet weak var thumbnailView: UIImageView?
    @IBOutlet weak var typeView: UIImageView?
    @IBOutlet weak var comment: UITextView?
    @IBOutlet weak var loading: UIActivityIndicatorView?
    @IBOutlet weak var progressMask : UIView?
    var  taskProgress: CGFloat = 0.0 {
        didSet {
            self.updateProgress()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        taskProgress = 0.0
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 3
        self.layer.shadowOffset = CGSize(width: 2, height: 3)
        self.layer.shadowColor = UIColor.gray.cgColor
    }
    func updateProgress() {
        guard let mask0 = self.progressMask else { return }
        mask0.isHidden = false
        let progressLayer = CAShapeLayer()
        
        let w = self.frame.width;
        let h = self.frame.height;
        progressLayer.frame = CGRect(x: 0, y: 0, width: w, height: h)
        let rads = self.taskProgress * CGFloat.pi*1.5;
        let p = UIBezierPath(arcCenter: CGPoint(x: w/2, y: h/2), radius: w*0.625, startAngle:CGFloat.pi*1.5 , endAngle: rads, clockwise: true)
        p.addLine(to: CGPoint(x: w/2, y: h/2))
        progressLayer.fillColor = UIColor.black.cgColor
        progressLayer.path = p.cgPath
        mask0.layer.mask = progressLayer
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
    }
    func animatePieEffectWithInterval(_ interval: CGFloat)  {
        
        guard let mask0 = self.progressMask else { return }
        
        mask0.isHidden = true
        mask0.layer.mask = nil;
        mask0.isHidden = false;
        mask0.backgroundColor = UIColor.clear
        
        let progressLayer = CAShapeLayer()
        let w = self.frame.width;
        let h = self.frame.height;
        progressLayer.frame = CGRect(x: 0, y: 0, width: w, height: h)
        progressLayer.fillColor = UIColor.gray.cgColor
        
        let anim = CAKeyframeAnimation(keyPath: "path")
        anim.duration = Double(interval)
        anim.autoreverses = false
        anim.isRemovedOnCompletion = true
        anim.speed = 1
        var vals : Array<CGPath> = []
        let u = CGFloat(1.0/30.0)
        for i in 0..<30 {
            let rads = u*CGFloat(i)*(CGFloat.pi*2.0) - CGFloat.pi*0.5
            let p = UIBezierPath(arcCenter: CGPoint(x: w/2, y: h/2), radius: w*0.625, startAngle:CGFloat.pi*1.5 , endAngle: rads, clockwise: true)
            p.addLine(to: CGPoint(x: w/2, y: h/2))
            progressLayer.fillColor = UIColor.black.cgColor
            progressLayer.path = p.cgPath
            mask0.layer.mask = progressLayer
            vals.append(p.cgPath)
        }
        anim.values = vals
        anim.delegate = self
        
        progressMask?.layer.addSublayer(progressLayer)
        progressLayer.opacity = 0.35
        progressLayer.masksToBounds = true
        
        progressLayer.add(anim, forKey: "pieAnim")
        
    }
    func loadCompleted(_ thumbnail: UIImage?, _ type : String?,_ hasVideo:Bool, _ isDark:Bool) {
        guard let type = type else { return }
        self.thumbnailView?.image = thumbnail
        self.typeView?.isHidden = !hasVideo
        let cf : CFString = type as CFString
        switch cf {
        case kUTTypeURL,
             kUTTypeText,
             kUTTypeMovie:
            if hasVideo {
                self.comment?.text = "影片"
            } else {
                self.comment?.text = "其他"
            }
            break
        case kUTTypeImage:
            self.comment?.text = "圖片"
            break
        case kUTTypePDF:
            self.comment?.text = "PDF"
            break
        default:
            self.comment?.text = "其他"
        }
        
        self.comment?.textColor = UIColor.darkGray
        self.loading?.stopAnimating()
        
    }
    
}

class AlbumCellView : UITableViewCell {
    @IBOutlet weak var album: UIImageView?
    @IBOutlet weak var albumName: UILabel?
    @IBOutlet weak var albumOwner: UILabel?
    @IBOutlet weak var albumDate: UILabel?
    @IBOutlet weak var albumStatus: UIImageView?
    @IBOutlet weak var accessCover: UIView?
    
    func loadAlbumWith(_ data: [String: Any]) {
        guard let albumInfo = data["album"] as? [String: Any],
            let name = albumInfo["name"] as? String,
            let insertdate = albumInfo["insertdate"] as? String,
            let act = albumInfo["act"] as? String else {
                self.album?.image = UIImage(named: "Icon.png")
                self.album?.alpha = 0.5
                return
        }
        
        albumName?.text = name
        albumDate?.text = insertdate
        
        if act == "open" {
            let image = UIImage(named: "ic200_act_open_white.png")
            albumStatus?.image = image?.withRenderingMode(.alwaysTemplate)
        } else {
            let image = UIImage(named: "ic200_act_close_white.png")
            albumStatus?.image = image?.withRenderingMode(.alwaysTemplate)
        }
        albumStatus?.tintColor = UIColor.orange
        albumOwner?.text = ""
        
        if let cover = albumInfo["cover"] as? String {
            self.album?.alpha = 1.0
            if let url = URL(string: cover) {
                do {
                    let data = try Data(contentsOf: url)
                    if let image = UIImage(data: data) {
                        self.album?.image = image
                        return
                    }
                } catch {
                    
                }
                
            }
        }
        
        self.album?.image = UIImage(named: "Icon.png")
        self.album?.alpha = 0.5
        
        self.albumOwner?.text = "";
        self.accessCover?.isHidden = true;
        self.isUserInteractionEnabled = true;
        guard let cdict = data["cooperation"] as? [String : Any] else {
            return
        }
        if let i = cdict["identity"] as? String {
            if i == "viewer" {
                self.albumOwner?.text = "無上傳權限"
                self.accessCover?.isHidden = false;
                self.isUserInteractionEnabled = false;
                
            }
        }
        
        
    }
}

class UIListButton : UIButton {
    var border: CAShapeLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createBorder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        createBorder()
    }
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.alpha = 1.0
                self.border?.backgroundColor = UIColor.gray.cgColor
            } else {
                self.alpha = 0.25
                self.border?.backgroundColor = UIColor.clear.cgColor
            }
        }
    }
    private func createBorder() {
        self.border = CAShapeLayer()
        if let b = self.border {
            b.frame = CGRect(x: 0, y: self.frame.height-3, width: self.frame.width, height: 3)
            self.layer.addSublayer(b)
        }
    }
    
}
