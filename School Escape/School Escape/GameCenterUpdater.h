//
//  GameCenterUpdater.h
//  School Escape
//
//  Created by Sudikoff Lab iMac on 3/18/14.
//  Copyright (c) 2014 Lordtechy. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kLeaderboardID @"1"
#define kAchievement10Plays @"play10"
#define kAchievement20Plays @"play20"
#define kAchievement50Plays @"play50"

@class GameCenterManager;

@interface GameCenterUpdater : NSObject{
    GameCenterManager* gameCenterManager;
    int64_t currentScore;
    //NSString* currentLeaderBoard;
}

@property (nonatomic, retain) GameCenterManager* gameCenterManager;
@property (nonatomic, assign) int64_t currentScore;
@property (nonatomic, assign) NSString* currentLeaderBoard;

-(void)sendScore:(NSDictionary*)score;
-(void)checkAchievements;

@end
