//
//  Game.h
//  School Escape
//
//  Created by Max Greenwald on 3/15/14.
//  Copyright 2014 Lordtechy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "chipmunk.h"

@interface Game : CCScene <CCPhysicsCollisionDelegate> {

}

+ (Game *)scene;
- (id)init;

@end
