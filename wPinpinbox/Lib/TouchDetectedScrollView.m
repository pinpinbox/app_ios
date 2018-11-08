//
//  TouchDetectedScrollView.m
//  wPinpinbox
//
//  Created by David on 6/22/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "TouchDetectedScrollView.h"

@implementation TouchDetectedScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // If not dragging, send event to next responder
    if (!self.dragging){
        [self.nextResponder touchesBegan: touches withEvent:event];
        
        if ([self.detectedDelegate respondsToSelector: @selector(didTouchBegin:touches:withEvent:)]) {
            [self.detectedDelegate didTouchBegin: self touches: touches withEvent: event];
        }
    }
    else{
        [super touchesBegan: touches withEvent: event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // If not dragging, send event to next responder
    if (!self.dragging){
        [self.nextResponder touchesMoved: touches withEvent:event];
    }
    else{
        [super touchesMoved: touches withEvent: event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // If not dragging, send event to next responder
    if (!self.dragging){
        [self.nextResponder touchesEnded: touches withEvent:event];
        if ([self.detectedDelegate respondsToSelector: @selector(didTouchEnd:touches:withEvent:)]) {
            [self.detectedDelegate didTouchEnd: self touches: touches withEvent: event];
        }
    }
    else{
        [super touchesEnded: touches withEvent: event];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // If not dragging, send event to next responder
    if (!self.dragging) {
        [self.nextResponder touchesCancelled: touches withEvent: event];
        
        if ([self.detectedDelegate respondsToSelector: @selector(didTouchCancel:touches:withEvent:)]) {
            [self.detectedDelegate didTouchCancel: self touches: touches withEvent: event];
        }
    }
    else {
        [super touchesCancelled: touches withEvent: event];
    }
}

@end
