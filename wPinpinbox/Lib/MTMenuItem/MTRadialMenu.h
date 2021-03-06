//
//  MTRadialMenu
//
//  Created by Angus on 1/13/14.
//

#import <UIKit/UIKit.h>
#import "MTMenuItem.h"

@interface MTRadialMenu : UIControl



@property(nonatomic,assign) NSString *menuid;
/**起始角度
 * The starting angle off vertical to start adding menu items. Angles are in radians,
 * a simple useful define might be:
 *
 *     #define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)
 * Negitive values go couter clockwise.
 */
@property CGFloat startingAngle;

/**增量角度
 * How far each item is separated by. Angles are in radians,
 * a simple useful define might be:
 *
 *     #define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)
 *
 * Negitive values go couter clockwise.
 */
@property CGFloat incrementAngle;

/**半徑  最小50
 * Radius of the menu items, min 50
 */
@property CGFloat radius;

/** 選擇的標誌
 * Used to itentify the menu item that was last selected, suggested to only use
 * inside the UIControlEventTouchUpInside call.
 */
@property NSString *selectedIdentifier;

/**
 * Used to itentify where this menu was last activated, suggested to only use
 * inside the UIControlEventTouchUpInside call.
 */
@property CGPoint location;

/**
 * Add a menu item to the radial menu, suggested that you subclass MTMenuItem and
 * implement your own drawing code.
 */
- (void)addMenuItem:(MTMenuItem *)item;

@end
