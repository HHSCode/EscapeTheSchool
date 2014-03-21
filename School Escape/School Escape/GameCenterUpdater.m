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

@interface GameCenterUpdater () <GameCenterManagerDelegate>{
    int64_t submitedDistance;
    int64_t submitedCoins;
}

@end

@implementation GameCenterUpdater
@synthesize currentLeaderBoard,currentScore,gameCenterManager;

bool useDistanceSubmittedScore = false;

-(id)init{
    if (self = [super init]) {
        submitedCoins = nil;
        submitedDistance = nil;
        self.currentLeaderBoard = gDistanceLeaderboard;
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

-(void)reportedScore:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (error == NULL) {
        } else {
            NSLog(@"Score Failed, %@",[error localizedDescription]);
        }
    });
}

-(void)sendScore:(NSDictionary *)score andScores:(NSArray *)Scores{
    // Pull high scores
    if ([GameCenterManager isGameCenterAvailable]) {
        GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
        leaderboardRequest.identifier = gDistanceLeaderboard;
        if (leaderboardRequest != nil) {
            [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
                if (error != nil) {
                    NSLog(@"Error pulling distance score");
                }else{
                    submitedDistance = leaderboardRequest.localPlayerScore.value;
                }
                leaderboardRequest.identifier = gBestCoinLeaderboard;
                if (leaderboardRequest != nil) {
                    [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
                        if (error !=nil) {
                            NSLog(@"Error pulling coin score");
                        }else{
                            submitedCoins = leaderboardRequest.localPlayerScore.value;
                        }
                        [self finishScoreSend:score andScores:Scores];
                        return;
                    }];
                }else{
                    [self finishScoreSend:score andScores:Scores];
                    return;
                }
            }];
        }else{
            [self finishScoreSend:score andScores:Scores];
            return;
        }
    }
}

-(void)finishScoreSend:(NSDictionary *)score andScores:(NSArray *)Scores{
    
    NSString* path = [(NSString *) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"scoreSaves.plist"];
    NSArray* Scores2 =[Scores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO], nil]];
    
    
    // Get best score
    Scores2 = [Scores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:NO], nil]];
    int64_t distanceScore = [[[Scores2 objectAtIndex:0] objectForKey:@"distance"] intValue];
    
    Scores2 = [Scores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"coins" ascending:NO], nil]];
    int64_t coinsScore = [[[Scores2 objectAtIndex:0] objectForKey:@"coins"] intValue];
    
    
    /*
     Calculate total distance
     - This runs through all the distance scores from the past and adds them up
     Average distance is calculated off of this
     */
    int64_t totalDistance = 0;
    int numOfRuns = 0;
    for (NSDictionary *score in Scores) {
        totalDistance = totalDistance + [[score objectForKey:@"distance"] intValue];
        numOfRuns++;
    }
    int64_t averageDistance = totalDistance / numOfRuns;
    
    // Init scores
    GKScore * GCscore = [[GKScore alloc] initWithCategory:gDistanceLeaderboard];
    if (distanceScore < submitedDistance) {
        GCscore.value = submitedDistance;
    }else{
        GCscore.value = distanceScore;
    }
    
    GKScore * coinsScore2 = [[GKScore alloc] initWithCategory:gBestCoinLeaderboard];
    if (coinsScore < submitedCoins) {
        coinsScore2.value = submitedCoins;
    }else{
        coinsScore2.value = coinsScore;
    }
    
    GKScore * totalDistanceScore = [[GKScore alloc] initWithCategory:gTotalDistanceLeaderboard];
    totalDistanceScore.value = totalDistance;
    
    GKScore * averageDistanceScore = [[GKScore alloc] initWithCategory:gAverageDistanceLeaderboard];
    averageDistanceScore.value = averageDistance;
        
    // Submit scores
    [GCscore reportScoreWithCompletionHandler:^(NSError *error) {[self reportedScore:error];}];
    [coinsScore2 reportScoreWithCompletionHandler:^(NSError *error) {[self reportedScore:error];}];
    [totalDistanceScore reportScoreWithCompletionHandler:^(NSError *error) {[self reportedScore:error];}];
    [averageDistanceScore reportScoreWithCompletionHandler:^(NSError *error) {[self reportedScore:error];}];
    
    [self checkAchievements:Scores];
    [Scores writeToFile:path atomically:YES];
}

-(void)error:(NSError*)error{
    if (error!=nil) {
        NSLog(@"Error submitting acheivment: %@",error.localizedFailureReason);
    }
}

-(void)checkAchievements:(NSArray *)Scores{
    int numberOfScores = (int)[Scores count];
    if (numberOfScores<=1) {
        [self.gameCenterManager resetAchievements];
    }
    // 10 plays:
    double parcent10 = (numberOfScores/10.0)*100.0;
    GKAchievement* runs10 = [[GKAchievement alloc]initWithIdentifier:kAchievement10Plays];
    runs10.showsCompletionBanner = YES;
    runs10.percentComplete = parcent10;
    [runs10 reportAchievementWithCompletionHandler:^(NSError *error) {[self error:error];}];
    
    // 20 plays:
    double parcent20 = (numberOfScores/20.0)*100.0;
    GKAchievement* runs20 = [[GKAchievement alloc]initWithIdentifier:kAchievement20Plays];
    runs20.showsCompletionBanner = YES;
    runs20.percentComplete = parcent20;
    [runs20 reportAchievementWithCompletionHandler:^(NSError *error) {[self error:error];}];
    
    // 50 plays:
    double parcent50 = (numberOfScores/50.0)*100.0;
    GKAchievement* runs50 = [[GKAchievement alloc]initWithIdentifier:kAchievement50Plays];
    runs50.showsCompletionBanner = YES;
    runs50.percentComplete = parcent50;
    [runs50 reportAchievementWithCompletionHandler:^(NSError *error) {[self error:error];}];
}

@end
