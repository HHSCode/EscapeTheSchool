//
//  Menu.h
//  School Escape
//
//  Created by Max Greenwald on 3/15/14.
//  Copyright 2014 Lordtechy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"
#import "Store.h"
#import "Settings.h"
#import "About.h"
#import "cocos2d.h"
#import "cocos2d-ui.h"

// -----------------------------------------------------------------------

/**
 *  The main scene
 */
@interface Menu : CCScene

// -----------------------------------------------------------------------

+ (Menu *)scene;
- (id)init;

// -----------------------------------------------------------------------
@end