//
//  GameCenterUpdater.m
//  School Escape
//
//  Created by Sudikoff Lab iMac on 3/18/14.
//  Copyright (c) 2014 Lordtechy. All rights reserved.
//

#import "GameCenterUpdater.h"
#import "AppSpecificValues.h"
#import "GameCenterManager.h"

@implementation GameCenterUpdater
@synthesize currentLeaderBoard,currentScore,gameCenterManager;

-(id)init{
    if (self = [super init]) {
        self.currentLeaderBoard = kLeaderboardID;
        self.currentScore = 0;
        
        if ([GameCenterManager isGameCenterAvailable]) {
            
            self.gameCenterManager = [[GameCenterManager alloc] init];
            //[self.gameCenterManager setDelegate:self];
            [self.gameCenterManager authenticateLocalUser];
            
        }else{
            
            // The current device does not support GameCenter
        }
    }
    return self;
}

-(void)sendScore:(NSDictionary *)score andScores:(NSArray *)Scores{
    self.currentScore = [score objectForKey:@"distance"];
    [self checkAchievements:Scores];
    [self.gameCenterManager reportScore: self.currentScore forCategory: self.currentLeaderBoard];
}

-(void)checkAchievements:(NSArray *)Scores{
    int numberOfScores = (int)[Scores count];
    // 10 plays:
    double parcent10 = (numberOfScores/10.0)*100.0;
    [self.gameCenterManager submitAchievement:kAchievement10Plays percentComplete:parcent10];
    // 20 plays:
    double parcent20 = (numberOfScores/20.0)*100.0;
    [self.gameCenterManager submitAchievement:kAchievement20Plays percentComplete:parcent20];
    // 50 plays:
    double parcent50 = (numberOfScores/50.0)*100.0;
    [self.gameCenterManager submitAchievement:kAchievement50Plays percentComplete:parcent50];
}

-(void)dealloc{
    gameCenterManager = nil;
    currentScore = nil;
    currentLeaderBoard = nil;
}

@end
