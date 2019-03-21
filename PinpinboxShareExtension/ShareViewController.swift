//
//  ShareViewController.swift
//  PinpinboxShareExtension
//
//  Created by Antelis on 2019/3/19.
//  Copyright © 2019 Angus. All rights reserved.
//

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
    
    func loadAlbumWith(_ dictionary: [String: Any]) {
        
    }
    /*
     array(
     obj(
     album (相本) => obj(
     act (string, 動作, close: 關閉 / open: 開啟),
     album_id (int, id),
     count_photo (int, 相片數量),
     cover (string, 封面, 200x200),
     cover_width (int, 封面寬度),
     cover_height (int, 封面高度),
     description (string, 描述),
     insertdate (string, 建立日期, YYYY-mm-dd),
     location (string, 地點),
     name (string, 名稱),
     usefor => obj(
     audio (boolean, 是否有音頻),
     exchange (boolean, 是否有兌換),
     image (boolean, 是否有圖像),
     slot (boolean, 是否有拉霸),
     video (boolean, 是否有影片),
     ),
     zipped (int, 是否壓製, 1:是 / 0:否),
     ),
     cooperation (共用) => obj(
     identity (string, 身分, admin<管理者> / approver<副管理者> / editor<共用者> / viewer<瀏覽者>)
     ),
     cooperationstatistics (共用統計) => obj(
     count (int, 人數)
     ),
     event (活動) => array(
     obj(
     event_id (int, id),
     name (string, 名稱),
     contributionstatus (boolean, 投稿狀態 => false: 未投稿, true: 已投稿)
     )
     [, obj(...)]
     ),
     template (版型) => obj(
     template_id (int, id),
     ),
     user (作者) => obj(
     user_id (int, id),
     name (string, 名稱),
     picture (string, 大頭照, 160x160)
     ),
     usergrade => obj(
     photo_limit_of_album (int, 相本的相片數量上限)
     )
     )
     [, obj(...)]
     )
     */
    /*
    - (void)loadAlbum:(NSDictionary *)data {
    NSDictionary *album = data[@"album"];
    self.album.image = nil;
    if (![album isKindOfClass:[NSNull class]]) {
    self.albumName.text = album[@"name"];
    self.albumDate.text = album[@"insertdate"];
    NSString *act = album[@"act"];
    
    if ([act isEqualToString: @"open"]) {
    UIImage *i = [UIImage imageNamed:@"ic200_act_open_white.png"];
    self.albumStatus.image = [i imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    } else {
    UIImage *i = [UIImage imageNamed:@"ic200_act_close_white.png"];
    self.albumStatus.image = [i imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    self.albumStatus.tintColor = [UIColor firstPink];
    self.albumOwner.text = @"";
    
    if (album[@"cover"] && ![album[@"cover"] isKindOfClass:[NSNull class]]) {
    NSString *c = album[@"cover"];
    self.album.alpha = 1.0;
    __block typeof(self) wself = self;
    NSURL *u = [NSURL URLWithString:c];
    
    [UserAPI loadImageWithURL:u completionBlock:^(UIImage * _Nullable image) {
    if (image) {
    dispatch_async(dispatch_get_main_queue(), ^{
    wself.album.image = image;
    });
    }
    }];
    
    } else {
    self.album.image = [UIImage imageNamed:@"Icon.png"];
    self.album.alpha = 0.5;
    }
    }
    
    NSDictionary *c = data[@"cooperation"];
    if (c && ![c[@"identity"] isKindOfClass:[NSNull class]]) {
    NSString *i = c[@"identity"];
    if (i.length && [i isEqualToString:@"viewer"]) {
    self.albumOwner.text = @"無上傳權限";
    self.accessCover.hidden = NO;
    self.userInteractionEnabled = NO;
    } else {
    self.albumOwner.text = @"";
    self.accessCover.hidden = YES;
    self.userInteractionEnabled = YES;
    }
    } else {
    self.albumOwner.text = @"";
    self.accessCover.hidden = YES;
    self.userInteractionEnabled = YES;
    }
    
    }
    */
}

class UIListButton : UIButton {
    var border: CAShapeLayer?
}

class ShareViewController: UIViewController, UINavigationControllerDelegate {

     @IBOutlet weak var userName: UILabel?
     @IBOutlet weak var albumList: UITableView?
     @IBOutlet weak var groupAlbumList: UITableView?
     @IBOutlet weak var photoList: UICollectionView?
     @IBOutlet weak var textArea : UITextView?
     @IBOutlet weak var notLoginCover : UIView?
     @IBOutlet weak var coverNotice: UITextView?
     var albumlist: Array<[NSString: Any]> = []
     var groupalbumlist: Array<[NSString: Any]> = []
     var shareItems : Array<ShareItem> = []
     var selectedAlbum : String?
     var albumNames: String?
    
     @IBOutlet weak var progressView: UIView?
     @IBOutlet weak var postProgress: UIProgressView?
     @IBOutlet weak var postProgressStatus: UITextView?
     var isLoading : Bool = false
     var successCount: Int = 0
     var failCount: Int = 0
    
     @IBOutlet weak var retryBtn: UIButton?
    
     @IBOutlet weak var mylist: UIListButton?
     @IBOutlet weak var grouplist: UIListButton?
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}

extension ShareViewController : UITableViewDelegate{

}
extension ShareViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    }
    
    
}
extension ShareViewController : UICollectionViewDelegateFlowLayout {
    
}
extension ShareViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
    }
    
    
}
extension ShareViewController : UploadProgressDelegate {
    
}
extension ShareViewController : PDFUploaderDelegate {
    
}

extension ShareViewController : ItemContentDelegate {
    
}
extension ShareViewController : AlbumSettingsDelegate {
    
}
