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
        anim.duration = interval
        anim.autoreverses = false
        anim.isRemovedOnCompletion = true
        anim.speed = 1
        var vals = Array<CGPath>[]
        /*
        let rads = self.taskProgress * CGFloat.pi*1.5;
        let p = UIBezierPath(arcCenter: CGPoint(x: w/2, y: h/2), radius: w*0.625, startAngle:CGFloat.pi*1.5 , endAngle: rads, clockwise: true)
        p.addLine(to: CGPoint(x: w/2, y: h/2))
        progressLayer.fillColor = UIColor.black.cgColor
        progressLayer.path = p.cgPath
        mask0.layer.mask = progressLayer
        
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    anim.duration = interval;
    anim.autoreverses = NO;
    anim.removedOnCompletion = YES;
    anim.speed = 1;
    NSMutableArray *vals = [NSMutableArray array];
    CGFloat u = 1.0/30.0;
    
    for (int i = 0; i< 30 ;i++) {
    CGFloat rads =  (u*i)* (M_PI*2)-M_PI*0.5;
    
    UIBezierPath *p = [UIBezierPath bezierPathWithArcCenter:CGPointMake(w/2, h/2) radius:(w*1.25)/2 startAngle:-M_PI*0.5 endAngle:rads clockwise:YES];
    [p addLineToPoint:CGPointMake(w/2, h/2)];
    [vals addObject:(__bridge id)p.CGPath];
    }
    anim.values  = vals;
    anim.delegate = self;
    
    [self.progressMask.layer addSublayer:progressLayer];
    progressLayer.opacity = 0.35;
    progressLayer.masksToBounds = YES;
    
    [progressLayer addAnimation:anim forKey:@"pieAnim"];
    
    }
    /*
    - (void)updateProgress {
    self.progressMask.hidden = NO;
    
    CAShapeLayer *progressLayer = [[CAShapeLayer alloc] init];
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    progressLayer.frame = CGRectMake(0, 0, w, h);
    CGFloat rads = self.taskProgress * (M_PI*2)-M_PI*0.5;
    
    UIBezierPath *p = [UIBezierPath bezierPathWithArcCenter:CGPointMake(w/2, h/2) radius:(w*1.25)/2 startAngle:M_PI*1.5 endAngle:rads clockwise:YES];
    [p addLineToPoint:CGPointMake(w/2, h/2)];
    [progressLayer setFillColor:[UIColor blackColor].CGColor];
    [progressLayer setPath:p.CGPath];
    self.progressMask.layer.mask = progressLayer;
    }
    - (void)loadCompleted:(UIImage *)thumbnail type:(NSString *)type hasVideo:(BOOL)hasVideo isDark:(BOOL)isDark {
    self.thumbnailView.image = thumbnail;
    self.typeView.hidden = !hasVideo;
    if ([type isEqualToString:(__bridge NSString *)kUTTypeURL] ||
    [type isEqualToString:(__bridge NSString *)kUTTypeText] ||
    [type isEqualToString:(__bridge NSString *)kUTTypeMovie] ) {
    self.comment.text = hasVideo? @"影片": @"其他";
    
    } else if ([type isEqualToString:(__bridge NSString *)kUTTypeImage]){
    self.comment.text = @"圖片";
    } else if ([type isEqualToString:(__bridge NSString *)kUTTypePDF]){
    self.comment.text = @"PDF";
    }
    self.comment.textColor = isDark? [UIColor whiteColor]:[UIColor darkGrayColor];
    [self.loading stopAnimating];
    
    }

     */
}

class AlbumCellView : UITableViewCell {
    @IBOutlet weak var album: UIImageView?
    @IBOutlet weak var albumName: UILabel?
    @IBOutlet weak var albumOwner: UILabel?
    @IBOutlet weak var albumDate: UILabel?
    @IBOutlet weak var albumStatus: UIImageView?
    @IBOutlet weak var accessCover: UIView?
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
