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

@interface GameCenterUpdater () <GameCenterManagerDelegate>

@end

@implementation GameCenterUpdater
@synthesize currentLeaderBoard,currentScore,gameCenterManager;

-(id)init{
    if (self = [super init]) {
        self.currentLeaderBoard = kLeaderboardID;
        self.currentScore = 0;
        
        if ([GameCenterManager isGameCenterAvailable]) {
            
            self.gameCenterManager = [[GameCenterManager alloc] init];
            self.gameCenterManager.delegate = self;
            //NSLog(@"%@",[self respondsToSelector:@selector(sendScore:andScores:)]);
            [self.gameCenterManager authenticateLocalUser];
            
        }else{
            
            // The current device does not support GameCenter
        }
    }
    return self;
}
-(void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController{
    return;
}

-(void)scoreReported:(NSError *)error{
    if (error==nil) {
        //NSLog(@"No problems reporting scores");
    }else{
        NSLog(@"Had trouble reporting score: %@",error);
    }
}

-(void)sendScore:(NSDictionary *)score andScores:(NSArray *)Scores{
    NSString* path = [(NSString *) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"scoreSaves.plist"];
    Scores=[Scores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO], nil]];
    
    Scores = [Scores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:NO], nil]];
    
    int64_t currentScore = [[[Scores objectAtIndex:0] objectForKey:@"distance"] intValue];
    
    Scores = [Scores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"coins" ascending:NO], nil]];
    
    int64_t coinsScore = [[[Scores objectAtIndex:0] objectForKey:@"coins"] intValue];
    
    
    
    [self checkAchievements:Scores];
    NSLog(@"Best distance: %lld",currentScore);
    NSLog(@"Best coins: %lld",coinsScore);
    [self.gameCenterManager reportScore: currentScore forCategory: @"bestdistance"];
    [self.gameCenterManager reportScore: ((int64_t)([[score valueForKey:@"coins"]intValue])) forCategory: @"bestcoin"];
    [Scores writeToFile:path atomically:YES];
}

-(void)checkAchievements:(NSArray *)Scores{
    int numberOfScores = (int)[Scores count];
    if (numberOfScores<=1) {
        [self.gameCenterManager resetAchievements];
    }
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

- (void) achievementSubmitted: (GKAchievement*) ach error:(NSError*) error;
{
    
    if (error==nil && ach != NULL) {
        NSLog(@"Achievement (%@) Submitted",ach.identifier);
        if (ach.percentComplete==100.0) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Achievement Get!" message:[NSString stringWithFormat:@"%@",ach.identifier] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert show];
        }
    }else{
        NSLog(@"Achievement submission failed!");
    }
    return;
}

@end
