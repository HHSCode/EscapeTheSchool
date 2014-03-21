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
#define k500Plays @"play500"
#define k1000Plays @"play1000"
#define k1kDistance @"run100"
#define k5kDistance @"run500"
#define k10kDistance @"run1000"
#define k100kDistance @"run10000"
#define kcaught50fast @"caught50fast"
#define kbook100 @"book100"
#define kbook500 @"book500"
#define kcoin500 @"coin500"
#define kcoin1000 @"coin1000"
#define kcoin10000 @"coin10000"
#define kmarathon @"marathon"
#define kplutophobia @"plutophobia"
#define kdanger3 @"danger3"
#define kdanger5 @"danger5"
#define k42coins @"42coins"
#define k365coins @"365coins"
#define kgolden @"golden"

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
