//
//  AddNote.m
//  AccessLecture
//
//  Created by Angus on 1/15/14.
//
//

#import "AddNote.h"

@implementation AddNote

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{

    
    
    
    
    
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    //// Image Declarations
    UIImage* datapickersflagcanada =_img;
    if (datapickersflagcanada==nil) {
        datapickersflagcanada=[UIImage imageNamed: @"datapickersflagcanada.png"];
    }
    
    
    UIImage *data2=[UIImage imageNamed:@"datapickers-flag-australia.png"];


    
    self.collisionPath=[UIBezierPath bezierPath];
    UIBezierPath* rectanglePath =self.collisionPath;
    [rectanglePath moveToPoint: CGPointMake(34, 0)];
    [rectanglePath addLineToPoint: CGPointMake(34, 34)];
    [rectanglePath addLineToPoint: CGPointMake(0, 34)];
    [rectanglePath addLineToPoint: CGPointMake(0, 0)];
    [rectanglePath addLineToPoint: CGPointMake(34, 0)];
    [rectanglePath closePath];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawTiledImage(context, CGRectMake(0, 0, datapickersflagcanada.size.width, datapickersflagcanada.size.height), datapickersflagcanada.CGImage);
    CGContextRestoreGState(context);

    
    
    

    
}

@end
