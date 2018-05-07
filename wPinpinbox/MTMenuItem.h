//
//  MTRadialMenu
//
//  Created by Angus on 1/13/14.
//

#import <UIKit/UIKit.h>

@interface MTMenuItem : UIView

/**
 * The area in which your menu item should be set as selected.
 */
@property (strong) UIBezierPath *collisionPath;

/**
 * Used to later identify this menu item when something is selected
 */
@property (strong) NSString *identifier;

/**
 * Used by MTRadialMenu, don't assign yourself.
 */
@property BOOL isSelected;

@end
