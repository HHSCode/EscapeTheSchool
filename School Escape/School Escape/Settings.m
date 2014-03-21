//
//  Settings.m
//  School Escape
//
//  Created by Max Greenwald on 3/15/14.
//  Copyright 2014 Lordtechy. All rights reserved.
//

#import "Settings.h"


@implementation Settings

+ (Settings *)scene
{
    return [[self alloc] init];
}

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    CCLayoutBox *settingsLayoutBox = [[CCLayoutBox alloc]init];
    [settingsLayoutBox setAnchorPoint:ccp(0.5, 0.5)];
    
    CCButton *menuButton = [CCButton buttonWithTitle:@"< Back"];
    [menuButton setTarget:self selector:@selector(menuPressed)];
    [settingsLayoutBox addChild:menuButton];
    CCButton *resetButton = [CCButton buttonWithTitle:@"Reset Game"];
    [resetButton setTarget:self selector:@selector(resetPressed)];
    [settingsLayoutBox addChild:resetButton];
    CCButton *musicButton = [CCButton buttonWithTitle:@"Music Settings"];
    [musicButton setTarget:self selector:@selector(musicPressed)];
    [settingsLayoutBox addChild:musicButton];
    
    [settingsLayoutBox setSpacing:10.f];
    [settingsLayoutBox setDirection:CCLayoutBoxDirectionVertical];
    [settingsLayoutBox setPosition:ccp(self.contentSize.width/2, self.contentSize.height/2)];
    [self addChild:settingsLayoutBox];
    
    
    // done
	return self;
}

-(void)menuPressed{
    [[CCDirector sharedDirector]presentScene:[Menu scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:.5]];
}

-(void)resetPressed{
    UIAlertView *confirm = [[UIAlertView alloc]initWithTitle:@"Are you sure?" message:@"This action will reset your total distance, coins, and achievements!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
    [confirm show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSString* path = [(NSString *) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"scoreSaves.plist"];
        NSMutableArray* Scores;
        Scores = [NSMutableArray arrayWithObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSDate date],[NSNumber numberWithInt:0], nil] forKeys:[NSArray arrayWithObjects:@"distance",@"coins",@"time",@"totalcoins", nil]]];
        [Scores writeToFile:path atomically:YES];
        [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error){if (error != nil){NSLog(@"failure");}}]; //Clear all progress saved on Game Center.
        GameCenterUpdater* gameCenterUpdater = [[GameCenterUpdater alloc] init];
        [gameCenterUpdater sendScore:[Scores objectAtIndex:0] andScores:Scores];
        [[CCDirector sharedDirector]presentScene:[Settings scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:.5]];
    }
}

-(void)musicPressed{
    [[CCDirector sharedDirector]presentScene:[MusicSettings scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:.5]];
}

@end
