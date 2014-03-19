//
//  GCHelper.h
//  School Escape
//
//  Created by Sudikoff Lab iMac on 3/18/14.
//  Copyright (c) 2014 Lordtechy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameKit/GameKit.h"
#import "GameCenterUpdater.h"
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "Pause.h"

@interface GCHelper : NSObject<GKGameCenterControllerDelegate>{
    // This class is the implementation of the Game Center Helper
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
}

@property (assign, readonly) BOOL gameCenterAvailable;

+ (GCHelper*)defaultHelper;
- (void)authenticateLocalUser;
- (void)showLeaderboardOnViewController:(UIViewController*)viewController;
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController;

@end
