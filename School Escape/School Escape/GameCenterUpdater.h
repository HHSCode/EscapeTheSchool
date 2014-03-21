//
//  GameCenterUpdater.h
//  School Escape
//
//  Created by Sudikoff Lab iMac on 3/18/14.
//  Copyright (c) 2014 Lordtechy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameKit/GameKit.h"
#define gDistanceLeaderboard @"bestdistance"
#define gTotalDistanceLeaderboard @"totaldistance"
#define gBestCoinLeaderboard @"bestcoin"
#define gAverageDistanceLeaderboard @"averagedistance"
#define kAchievement10Plays @"play10"
#define kAchievement20Plays @"play20"
#define kAchievement50Plays @"play50"
#define k100Plays @"play100"
#define k1000Plays @"play1000"
#define k1kDistance @"run100"
#define k5kDistance @"run500"
#define k10kDistance @"run1000"

@class GameCenterManager;

@interface GameCenterUpdater : NSObject <GKAchievementViewControllerDelegate>{
    GameCenterManager* gameCenterManager;
    int64_t currentScore;
    //NSString* currentLeaderBoard;
}

@property (nonatomic, retain) GameCenterManager* gameCenterManager;
@property (nonatomic, assign) int64_t currentScore;
@property (nonatomic, assign) NSString* currentLeaderBoard;

-(void) achievementSubmitted: (GKAchievement*) ach error:(NSError*) error;
-(void)scoreReported:(NSError *)error;
-(void)sendScore:(NSDictionary*)score andScores:(NSArray *)Scores;
-(void)checkAchievements:(NSArray *)Scores;

@end
