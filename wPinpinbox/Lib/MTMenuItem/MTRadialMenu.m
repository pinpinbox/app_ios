//
//  MTRadialMenu
//
//  Created by Angus on 1/13/14.
//

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

#import <objc/runtime.h>
#import "MTRadialMenu.h"
#import "MTMenuItem.h"

CGPoint CGRectCenterPoint(CGRect rect) {
    return CGPointMake(rect.size.width / 2.0,
                       rect.size.height / 2.0);
}

CGAffineTransform CGAffineTransformOrientOnAngle(CGFloat angle, CGFloat radius){
    CGAffineTransform newTransform = CGAffineTransformRotate(CGAffineTransformIdentity, angle);
    
    // CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
    newTransform = CGAffineTransformTranslate(newTransform, 0.0, -(radius >= 50 ? radius : 50));
    return newTransform;
}
BOOL CGAffineTransformEqualToTransformWithAccuracy (CGAffineTransform firstTransform, CGAffineTransform secondTransform, CGFloat epsilon) {
    return (fabs(firstTransform.a - secondTransform.a) <= epsilon) &&
    (fabs(firstTransform.b - secondTransform.b) <= epsilon) &&
    (fabs(firstTransform.c - secondTransform.c) <= epsilon) &&
    (fabs(firstTransform.d - secondTransform.d) <= epsilon) &&
    (fabs(firstTransform.tx - secondTransform.tx) <= epsilon) &&
    (fabs(firstTransform.ty - secondTransform.ty) <= epsilon);
}

@implementation MTRadialMenu
{
    CGFloat currentAngle;
    NSArray *menuItems;
    
    NSMutableArray *itempoint;
    MTMenuItem *selectitem;
    CGPoint selefpoint;
    
    
    NSMutableArray *twodata;
    NSMutableArray *threedata;
    NSMutableArray *fourdata;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        menuItems = @[];
        self.backgroundColor = [UIColor clearColor];
        itempoint=[NSMutableArray new];
        
        
        threedata=[NSMutableArray new];
        [threedata addObject:[NSValue valueWithCGPoint:CGPointMake(-40, -0)]];
        [threedata addObject:[NSValue valueWithCGPoint:CGPointMake(0, -30)]];
        [threedata addObject:[NSValue valueWithCGPoint:CGPointMake(40, -0)]];

      
        
        fourdata=[NSMutableArray new];
        [fourdata addObject:[NSValue valueWithCGPoint:CGPointMake(-40, -0)]];
        [fourdata addObject:[NSValue valueWithCGPoint:CGPointMake(-20, -40)]];
        [fourdata addObject:[NSValue valueWithCGPoint:CGPointMake(20,  -40)]];
        [fourdata addObject:[NSValue valueWithCGPoint:CGPointMake(40, -00)]];
        
        twodata=[NSMutableArray new];
        [twodata addObject:[NSValue valueWithCGPoint:CGPointMake(-40, -0)]];
     //   [threedata addObject:[NSValue valueWithCGPoint:CGPointMake(0, -30)]];
        [twodata addObject:[NSValue valueWithCGPoint:CGPointMake(40, -0)]];
    }
    return self;
}

- (void)didMoveToSuperview
{
    // Add menu activation gesture
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    [self.superview addGestureRecognizer:longPress];
}
- (void)setCurrentAngle:(CGFloat)angle {
    currentAngle = angle;
}
- (void)addMenuItem:(MTMenuItem *)item
{
    __block typeof(self) wself = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         //currentAngle = _startingAngle ?: 10.0;
        [wself setCurrentAngle:wself.startingAngle?:10.0];
    });
    if (currentAngle == 0) {
        currentAngle = _startingAngle ?: 10.0;
    }
    objc_setAssociatedObject(item, "display_angle", [NSNumber numberWithFloat:currentAngle], OBJC_ASSOCIATION_RETAIN);
    currentAngle += (_incrementAngle ?: 55.0);
   // NSLog(@"%f",currentAngle);
    menuItems = [menuItems arrayByAddingObject:item];
}

- (void)showMenuAnimated:(BOOL)animated
{
    
    [itempoint removeAllObjects];
    
    
    
    
    
//    CGPoint touchpoint=self.center;
//    CGPoint superpoin=[self superview].frame.origin;
    

    
    
    // Animate them
    //CGAffineTransform start = CGAffineTransformMakeScale(0.0, 0.0);
    for (MTMenuItem *item in menuItems) {
        item.transform = CGAffineTransformIdentity;
        item.isSelected = NO;
        [item setNeedsDisplay];
    
        [item setFrame:({
            CGRect frame = CGRectZero;
            frame.origin = CGRectCenterPoint(self.frame);
            frame = CGRectInset(frame, -17.5, -17.5);
            frame;
        })];
         
        [self addSubview:item];
        //item.transform=start;
        //item.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
    }
   // NSLog(@"%f,%f",_startingAngle,_radius);
    // Animate self
    //self.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
    __block typeof(self) wself = self;
    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:0.4 initialSpringVelocity:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        int sun=0;
        for (MTMenuItem *item in self.subviews) {
            if ([item isKindOfClass:[MTMenuItem class]]) {
                
            
                    item.center=[self itempoin:sun center:item.center];
               
                sun++;
             
                
                [wself->itempoint addObject: [ NSValue valueWithCGPoint :item.center]];
                //item.transform = CGAffineTransformOrientOnAngle(DEGREES_TO_RADIANS([objc_getAssociatedObject(item, "display_angle") floatValue]), _radius ?: 60.0);
            }
        }
        
       self.transform = CGAffineTransformIdentity;
    } completion:nil];
}
-(CGPoint)itempoin:(int)tag center:(CGPoint)center{
    int i = 0;
    CGPoint datapoint;
    if (self.subviews.count==3) {
        datapoint=[threedata[i+tag]CGPointValue];
    }else if(self.subviews.count==4){
        datapoint=[fourdata[i+tag]CGPointValue ];
    }else{
        datapoint=[twodata[i+tag]CGPointValue];
    }
    
  
    return CGPointMake(center.x+datapoint.x, center.y+datapoint.y);
    
    
    
    
}


- (void)hideMenuAnimated:(BOOL)animated completed:(void(^)(BOOL finished))competion
{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.alpha = 1.0;
        self.transform = CGAffineTransformIdentity;
        competion(finished);
    }];
}

- (void)prepareMenuAtPoint:(CGPoint)point
{
    
    [self sendActionsForControlEvents:UIControlEventTouchDown];
    self.frame = CGRectMake(point.x, point.y, 0.0, 0.0);
    
    
   // NSLog(@"%f,%f",point.x,point.y);
    self.frame=CGRectMake(self.superview.frame.size.width/2, self.superview.frame.size.height/2, 0, 0);
    //self.frame = CGRectInset(self.frame, -125, -125);
    [self setNeedsDisplayInRect:self.frame];
}

- (void)resetMenu
{
    self.frame = CGRectZero;
    for (UIView *sub in self.subviews) {
        [sub removeFromSuperview];
    }
}

- (void)notifyObserversOfSelection
{
    for (MTMenuItem *view in self.subviews) {
        if ([view isKindOfClass:[MTMenuItem class]]) {
            if (view.isSelected) {
                _selectedIdentifier = view.identifier;
                _location = self.center;
                [self sendActionsForControlEvents:UIControlEventTouchUpInside];
                break;
            }
        }
    }
}
//移動
- (void)handleTouch:(UIGestureRecognizer *)reg
{
    if (!CGAffineTransformIsIdentity(self.transform)) {
        return;
    }
    
    int sun=0;
    __block typeof(self) wself = self;
    for (MTMenuItem *view in self.subviews) {
        if ([view isKindOfClass:[MTMenuItem class]]) {
            CGPoint touch = [reg locationInView:view];
            view.isSelected = [view.collisionPath containsPoint:touch];
            if (view.isSelected) {
               // NSLog(@"%f,%f",view.frame.size.width,view.frame.size.height);
                //NSLog(@"%f",[objc_getAssociatedObject(view, "display_angle") floatValue]);
                CGAffineTransform bigTrans = CGAffineTransformScale(CGAffineTransformOrientOnAngle(DEGREES_TO_RADIANS([objc_getAssociatedObject(view, "display_angle") floatValue]), _radius ?: 0.0), 1.1, 1.1);
                //view.transform=CGAffineTransformIdentity;
                
                
                
                if (selectitem==view) {
                    bigTrans=view.transform;
                }else{
                    selectitem=view;
                    bigTrans=CGAffineTransformScale(view.transform, 1.2, 1.2);
                     //bigTrans = CGAffineTransformTranslate(bigTrans, 0.0, -13.0);
                }
                [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    //CGPoint center=[itempoint[sun] CGPointValue];
                    //view.center=center;
                    view.transform = bigTrans;
                } completion:nil];

                
                 } else {
                   
                [UIView animateWithDuration:0.2 animations:^{
                    CGPoint center=[wself->itempoint[sun] CGPointValue];
                    view.center=center;
                    view.transform=CGAffineTransformIdentity;
                    if (view == wself->selectitem) {
                        wself->selectitem=nil;
                    }
                    //view.transform = CGAffineTransformOrientOnAngle(DEGREES_TO_RADIANS([objc_getAssociatedObject(view, "display_angle") floatValue]), _radius ?: 60.0);
                    
                }];
                     
            }
            sun++;
            [view setNeedsDisplay];
        }
    }
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)reg
{
    switch (reg.state) {
        case UIGestureRecognizerStateBegan:
            //對準最下view;
            selefpoint=[reg locationInView:self.superview.superview];
            [self prepareMenuAtPoint:[reg locationInView:self.superview]];
            [self showMenuAnimated:YES];
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded: {
            [self notifyObserversOfSelection];
            [self hideMenuAnimated:YES completed:^(BOOL finished) {
                [self resetMenu];
            }];
        }
        case UIGestureRecognizerStateChanged:
            [self handleTouch:reg];
            break;
        default:
            break;
    }
}

@end
