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

@implementation GameCenterUpdater{
    NSMutableArray* achievments;
}
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

-(void)reportAchievement:(NSString*)identifyer withPercent:(double)percent{
    if (![achievments containsObject:identifyer]) {
        GKAchievement* ach = [[GKAchievement alloc]initWithIdentifier:identifyer];
        if (percent>=100.0) {
            [achievments addObject:identifyer];
        }
        ach.showsCompletionBanner = YES;
        ach.percentComplete = percent;
        [ach reportAchievementWithCompletionHandler:^(NSError *error) {[self error:error];}];
    }
}

-(void)checkAchievements:(NSArray *)Scores{
    int numberOfScores = (int)[Scores count];
    if (numberOfScores<=1) {
        [self.gameCenterManager resetAchievements];
    }
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* allkeys = [[defaults dictionaryRepresentation] allKeys];
    BOOL keyExists= NO;
    for (NSString* key in allkeys) {
        if ([key isEqualToString:@"achievments"]) {
            keyExists = YES;
            break;
        }
    }
    achievments = [NSMutableArray array];
    if (keyExists) {
        achievments = [NSMutableArray arrayWithArray:[defaults objectForKey:@"achievments"]];
    }
    keyExists = nil;
    allkeys = nil;
    
    /*
     ---------------Number of Plays----------------
     */
    
    // 10 plays:
    double percent = ((double)numberOfScores/10.0)*100.0;
    [self reportAchievement:kAchievement10Plays withPercent:percent];
    
    // 20 plays:
    percent = ((double)numberOfScores/20.0)*100.0;
    [self reportAchievement:kAchievement20Plays withPercent:percent];
    
    // 50 plays:
    percent = ((double)numberOfScores/50.0)*100.0;
    [self reportAchievement:kAchievement50Plays withPercent:percent];
    
    //Cinturion (100 plays)
    percent = ((double)numberOfScores/100.0)*100.0;
    [self reportAchievement:k100Plays withPercent:percent];
    
    //Half a Millennium (500 plays)
    percent = ((double)numberOfScores/500.0)*100.0;
    [self reportAchievement:k500Plays withPercent:percent];
    
    //Millenium (1000 plays)
    percent = ((double)numberOfScores/1000.0)*100.0;
    [self reportAchievement:k1000Plays withPercent:percent];
    
    /*
     ---------------Distance----------------
     */
    Scores = [Scores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO], nil]];
    NSDictionary* mostRecentScore = [Scores objectAtIndex:0];
    int gameTime = 60;
    allkeys = [NSArray arrayWithArray:[mostRecentScore allKeys]];
    if ([allkeys containsObject:@"duration"]) {
        gameTime = [mostRecentScore objectForKey:@"duration"];
    }
    
    //1k (1000 meters)
    percent = ([[mostRecentScore objectForKey:@"distance"] doubleValue]/1000.0)*100.0;
    [self reportAchievement:k1kDistance withPercent:percent];
    
    //5k (5000 meters)
    percent = ([[mostRecentScore objectForKey:@"distance"] doubleValue]/5000.0)*100.0;
    [self reportAchievement:k5kDistance withPercent:percent];
    
    //10k (10000 meters)
    percent = ([[mostRecentScore objectForKey:@"distance"] doubleValue]/10000.0)*100.0;
    [self reportAchievement:k10kDistance withPercent:percent];
    
    //100k (100000 meters)
    percent = ([[mostRecentScore objectForKey:@"distance"] doubleValue]/100000.0)*100.0;
    [self reportAchievement:k100kDistance withPercent:percent];
    
    //Plutophobia
    percent = 0.0;
    if ([[mostRecentScore objectForKey:@"plutophobia"] boolValue]) {
        percent = 100.0;
    }
    [self reportAchievement:kplutophobia withPercent:percent];
    
    /*
     ------------------Time before death------------
     */
    
    int numberOfFastDeaths = 0;
    for (NSDictionary* score in Scores) {
        allkeys = [score allKeys];
        int duration = 60;
        if ([allkeys containsObject:@"duration"]) {
            duration = [[score objectForKey:@"duration"] intValue];
        }
        if (duration<=30) {
            numberOfFastDeaths++;
        }
    }
    
    //Growing Potential (Die within the first 30 secs 50 time.)
    percent = ((double)numberOfFastDeaths/50.0)*100.0;
    [self reportAchievement:kcaught50fast withPercent:percent];
    
    
    /*
     -------------Books----------
     */
    
    int booksDodged = 0;
    NSDictionary* bestScore = [[Scores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"booksDodged" ascending:NO], nil]] objectAtIndex:0];
    allkeys = [bestScore allKeys];
    if ([allkeys containsObject:@"booksDodged"]) {
        booksDodged = [[bestScore objectForKey:@"booksDodged"] intValue]-1;
    }
    
    //Book Dodger (dodge 100 books)
    percent = ((double)booksDodged/100.0)*100.0;
    [self reportAchievement:kbook100 withPercent:percent];
    
    //Master Book Dodger (500 books)
    percent = ((double)booksDodged/500.0)*100.0;
    [self reportAchievement:kbook500 withPercent:percent];
    
    /*
     ------------Coins-----------
     */
    
    bestScore = [[Scores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"coins" ascending:NO], nil]] objectAtIndex:0];
    
    int numOfCoins = [[bestScore objectForKey:@"coins"] intValue];
    
    //Copper master (500)
    percent = ((double)numOfCoins/500.0)*100.0;
    [self reportAchievement:kcoin500 withPercent:percent];
    
    //Silver master (1000)
    percent = ((double)numOfCoins/1000.0)*100.0;
    [self reportAchievement:kcoin1000 withPercent:percent];
    
    //Gold master (10000)
    percent = ((double)numOfCoins/10000.0)*100.0;
    [self reportAchievement:kcoin10000 withPercent:percent];
    
    //Answer to the Universe, Life and Everything
    percent = 0.0;
    if ([[mostRecentScore objectForKey:@"coins"] intValue]==42) {
        percent = 100.0;
    }
    [self reportAchievement:k42coins withPercent:percent];
    
    //365
    percent = 0.0;
    if ([[mostRecentScore objectForKey:@"coins"] intValue]==365) {
        percent = 100.0;
    }
    [self reportAchievement:k365coins withPercent:percent];
    
    /*
     -------------Total Distance------------
     */
    
    int totalDistance = 0;
    for (NSDictionary* score in Scores) {
        totalDistance = totalDistance + [[score objectForKey:@"distance"] intValue];
    }
    
    //Marathon (50,000)
    percent = ((double)totalDistance/50000.0)*100.0;
    [self reportAchievement:kmarathon withPercent:percent];
    
    //Golden (161,803,398)
    percent = ((double)totalDistance/161803398.0)*100.0;
    [self reportAchievement:kgolden withPercent:percent];
    
    
    [defaults setValue:achievments forKey:@"achievments"];
    [defaults synchronize];
}

@end
