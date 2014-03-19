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
            //[self.gameCenterManager setDelegate:self];
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
    NSLog(@"%@",error);
}

-(void)sendScore:(NSDictionary *)score andScores:(NSArray *)Scores{
    NSString* path = [(NSString *) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"scoreSaves.plist"];
    Scores=[Scores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO], nil]];
    
    score = [Scores objectAtIndex:0];
    
    int64_t currentScore = [[score objectForKey:@"distance"] intValue];
    NSLog(@"Scores being sent...");
    [self checkAchievements:Scores];
    int64_t totalDistance = 0;
    int num = 0;
    for (NSDictionary* score2 in Scores) {
        totalDistance = totalDistance+[[score2 valueForKey:@"distance"] intValue];
        num++;
    }
    NSLog(@"Distance: %lld",currentScore);
    NSLog(@"Total distance: %lld",totalDistance);
    NSLog(@"Coins: %i",[[score valueForKey:@"coins"]intValue]);
    NSLog(@"Average distance: %lld",totalDistance/num);
    [self.gameCenterManager reportScore: currentScore forCategory: @"bestdistance"];
    [self.gameCenterManager reportScore: totalDistance forCategory: @"totaldistance"];
    [self.gameCenterManager reportScore: ((int64_t)([[score valueForKey:@"coins"]intValue])) forCategory: @"bestcoin"];
    [self.gameCenterManager reportScore:((int64_t)(totalDistance/num)) forCategory:@"averagedistance"];
    NSLog(@"Sent!");
    [Scores writeToFile:path atomically:YES];
}

-(void)checkAchievements:(NSArray *)Scores{
    int numberOfScores = (int)[Scores count];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Achievement Get!" message:@"" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    if (numberOfScores<=1) {
        [self.gameCenterManager resetAchievements];
    }
    // 10 plays:
    double parcent10 = (numberOfScores/10.0)*100.0;
    [self.gameCenterManager submitAchievement:kAchievement10Plays percentComplete:parcent10];
    if (parcent10==100) {
        [alert setMessage:@"You completed 10 Games!"];
        [alert show];
    }
    // 20 plays:
    double parcent20 = (numberOfScores/20.0)*100.0;
    [self.gameCenterManager submitAchievement:kAchievement20Plays percentComplete:parcent20];
    if (parcent20==100) {
        [alert setMessage:@"You completed 20 Games!"];
        [alert show];
    }
    // 50 plays:
    double parcent50 = (numberOfScores/50.0)*100.0;
    [self.gameCenterManager submitAchievement:kAchievement50Plays percentComplete:parcent50];
    if (parcent50==100) {
        [alert setMessage:@"You completed 50 Games!"];
        [alert show];
    }
}

- (void) achievementSubmitted: (GKAchievement*) ach error:(NSError*) error;
{
    NSLog(@"Achievement Submitted");
    return;
}

-(void)dealloc{
    gameCenterManager = nil;
    currentScore = nil;
    currentLeaderBoard = nil;
}

@end
