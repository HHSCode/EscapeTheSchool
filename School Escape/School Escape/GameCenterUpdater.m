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
        
    }
    return self;
}

-(void)dealloc{
    gameCenterManager = nil;
    currentScore = nil;
    currentLeaderBoard = nil;
}

@end
