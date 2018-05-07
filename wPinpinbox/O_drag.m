//
//  O_drag.m
//  wPinpinbox
//
//  Created by Angus on 2015/8/12.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "O_drag.h"
#import "UIImage+Rotation.h"
@implementation O_drag

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        scale=1.0;
        _imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:_imageView];
         self.clipsToBounds=YES;
        
        
        //選轉
        UIRotationGestureRecognizer *doRotate=[[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(doRotate:)];
        doRotate.delegate=self;
        [self addGestureRecognizer:doRotate];
        
        //拖曳手勢
        UIPanGestureRecognizer *doMovement =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(doMovement:)];
        doMovement.minimumNumberOfTouches=1;
        doMovement.maximumNumberOfTouches=1;
        [self addGestureRecognizer:doMovement];
        
        //單擊動作
//        UITapGestureRecognizer *doBegan=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doBegan:)];
//        [self addGestureRecognizer:doBegan];
        
        
//        UILongPressGestureRecognizer *doBegan=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(doBegan:)];
//        doBegan.minimumPressDuration=0.1;
//        doBegan.allowableMovement=1.0;
//        [self addGestureRecognizer:doBegan];
        //放大縮小
        UIPinchGestureRecognizer *doScale=[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(doScale:)];
        [self addGestureRecognizer:doScale];
        
        
    }
    return self;
}
-(void)setImage:(UIImage *)image{
    
    
    _image=image;
    _imageView.image=_image;
    
    float _imageScale = self.frame.size.width / image.size.width;
    self.imageView.frame = CGRectMake(0, 0, image.size.width*_imageScale, image.size.height*_imageScale);
    _originalImageViewSize = CGSizeMake(image.size.width*_imageScale, image.size.height*_imageScale);

    _imageView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    if (_image.size.width==1336 && _image.size.height==2004) {
        _imageView.frame=CGRectMake(0, 0, _imageView.frame.size.width, _imageView.frame.size.height);
    }
    
}
//旋轉手勢
- (IBAction)doRotate:(UIRotationGestureRecognizer *)sender {
    
    
    if([sender state] == UIGestureRecognizerStateBegan) {
        rotate = sender.rotation;
    }
    
    
    UIView *pinchView = _imageView;
    CGRect bounds = pinchView.bounds;
    CGPoint pinchCenter = [sender locationInView:pinchView];
    pinchCenter.x -= CGRectGetMidX(bounds);
    pinchCenter.y -= CGRectGetMidY(bounds);
    
    CGAffineTransform transform =pinchView.transform;
    transform = CGAffineTransformTranslate(transform, pinchCenter.x, pinchCenter.y);
    rotate = (sender.rotation - rotate);
    transform = CGAffineTransformRotate(transform, rotate);
    transform = CGAffineTransformTranslate(transform, -pinchCenter.x, -pinchCenter.y);
    [_imageView setTransform:transform];
    
    rotate = sender.rotation;
    
    
    /*
    if([sender state] == UIGestureRecognizerStateBegan) {
        rotate = sender.rotation;
    }
    UIView *pinchView = _imageView;
    CGRect bounds = pinchView.bounds;
    CGPoint pinchCenter = [sender locationInView:pinchView];
    pinchCenter.x -= CGRectGetMidX(bounds);
    pinchCenter.y -= CGRectGetMidY(bounds);
    CGAffineTransform transform = pinchView.transform;
    transform = CGAffineTransformTranslate(transform, pinchCenter.x, pinchCenter.y);
    CGFloat scale2 = sender.rotation;
    transform = CGAffineTransformScale(transform, scale2, scale2);
    transform = CGAffineTransformTranslate(transform, -pinchCenter.x, -pinchCenter.y);
    pinchView.transform = transform;

    */
    
    
    
    
    NSLog(@"旋轉中");
}
//拖曳手勢
-(IBAction)doBegan:(UITapGestureRecognizer *)sender{
    CGPoint point =[sender locationInView:self];
    location=point;
   
}
- (IBAction)doMovement:(UIPanGestureRecognizer *)sender {

   
    switch ([sender state]) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint point1 =[sender locationInView:self];
            location=point1;
            NSLog(@"拖曳開始");
        }
            break;
         case UIGestureRecognizerStateChanged:
        {
            
            
            CGPoint point =[sender locationInView:self];
            
            CGPoint center=_imageView.center;
            center.x += (point.x - location.x)/1;
            center.y += (point.y - location.y)/1;
            _imageView.center=center;
            location=point;
            
            NSLog(@"拖曳中");

        }
            break;
        default:
            break;
    }
      // [_imageView setCenter:[sender locationInView:self]];
}
//縮放手勢
- (IBAction)doScale:(UIPinchGestureRecognizer *)sender {
    if([sender state] == UIGestureRecognizerStateBegan) {
        scale = sender.scale;
    }

    UIView *pinchView = _imageView;
    CGRect bounds = pinchView.bounds;
    CGPoint pinchCenter = [sender locationInView:pinchView];
    pinchCenter.x -= CGRectGetMidX(bounds);
    pinchCenter.y -= CGRectGetMidY(bounds);
    CGAffineTransform transform = pinchView.transform;
    transform = CGAffineTransformTranslate(transform, pinchCenter.x, pinchCenter.y);
    scale = 1 + (sender.scale - scale);
    transform = CGAffineTransformScale(transform, scale, scale);
    transform = CGAffineTransformTranslate(transform, -pinchCenter.x, -pinchCenter.y);
    [_imageView setTransform:transform];
    
    scale = [sender scale];
//    CGFloat scale2 = sender.scale;
//    transform = CGAffineTransformScale(transform, scale2, scale2);
//    transform = CGAffineTransformTranslate(transform, -pinchCenter.x, -pinchCenter.y);
//    pinchView.transform = transform;
//    sender.scale = 1.0;

/*
    if([sender state] == UIGestureRecognizerStateBegan) {
        scale = sender.scale;
    }
    NSLog(@"%f",scale);
    scale = 1 + (sender.scale - scale);
    CGAffineTransform transform = CGAffineTransformScale(_imageView.transform, scale, scale);
    [_imageView setTransform:transform];
    
    scale = [sender scale];
  */
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

//旋轉角度
-(CGFloat)imagerotate{
    return rotate;
}

//放大倍率
-(CGFloat)imagescale{
    return _imageView.frame.size.width/_imageView.image.size.width;
}

//取得原始圖片旋轉
-(UIImage *)imageRotateCTM{
    
    return nil;
    
}


- (UIImage *)finishCropping {
    float zoomScale = [[self.imageView.layer valueForKeyPath:@"transform.scale.x"] floatValue];
    float wrotate = [[self.imageView.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
    
    float _imageScale = _image.size.width/_originalImageViewSize.width;
    
    CGSize cropSize = CGSizeMake(self.frame.size.width/zoomScale, self.frame.size.height/zoomScale);
    CGPoint cropperViewOrigin = CGPointMake((0.0 - self.imageView.frame.origin.x)/zoomScale,
                                            (0.0 - self.imageView.frame.origin.y)/zoomScale);
    if (cropSize.width!=cropSize.height) {
        
    }
    if((NSInteger)cropSize.width % 2 == 1 )
    {
        cropSize.width = ceil(cropSize.width);
    }
    if((NSInteger)cropSize.height % 2 == 1)
    {
        cropSize.height = ceil(cropSize.height);
    }
    
    CGRect CropRectinImage = CGRectMake((NSInteger)(cropperViewOrigin.x*_imageScale) ,(NSInteger)( cropperViewOrigin.y*_imageScale), (NSInteger)(cropSize.width*_imageScale),(NSInteger)(cropSize.height*_imageScale));
    UIImage *rotInputImage =[_image imageByNormalizingOrientation];
    //if (wrotate!=0) {
        rotInputImage = [rotInputImage imageRotatedByRadians:wrotate];
    //}
       CGImageRef tmp = CGImageCreateWithImageInRect([rotInputImage CGImage], CropRectinImage);
    UIImage *newimg = [UIImage imageWithCGImage:tmp scale:self.image.scale orientation:UIImageOrientationUp];
    CGImageRelease(tmp);
    
    return newimg;
}

@end
