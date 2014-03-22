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
    
    CCButton *menuButton = [CCButton buttonWithTitle:@"< Back" fontName:@"Marker Felt" fontSize:14];
    [menuButton setTarget:self selector:@selector(menuPressed)];
    [settingsLayoutBox addChild:menuButton];
    CCButton *resetButton = [CCButton buttonWithTitle:@"Reset Game" fontName:@"Marker Felt" fontSize:18];
    [resetButton setTarget:self selector:@selector(resetPressed)];
    [settingsLayoutBox addChild:resetButton];
    CCButton *soundButton = [CCButton buttonWithTitle:@"Sound Settings" fontName:@"Marker Felt" fontSize:18];
    [soundButton setTarget:self selector:@selector(soundPressed)];
    [settingsLayoutBox addChild:soundButton];
    
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
        NSString* docpath = (NSString *) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSLog(@"Path: %@", path);
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSError *error = nil;
        
        NSDirectoryEnumerator *fileEnumerator = [fileMgr enumeratorAtPath:docpath];
        
        for (NSString *filename in fileEnumerator) {
    
            NSLog(@"file: %@", filename);
        }
        BOOL success = [fileMgr removeItemAtPath:path error:&error];
        if (success) {
            //UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"Congratulation:" message:@"Successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
            //[removeSuccessFulAlert show];
        }
        else
        {
            NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
        }
        

        NSArray* resetScores = [[NSArray alloc]init];
        resetScores = [NSMutableArray arrayWithObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSDate date],[NSNumber numberWithInt:0], nil] forKeys:[NSArray arrayWithObjects:@"distance",@"coins",@"time",@"totalcoins", nil]]];
        resetScores=[resetScores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO], nil]];

        [resetScores writeToFile:path atomically:YES];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:resetScores forKey:@"saves"];
        [defaults synchronize];
        
        [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error){if (error != nil){NSLog(@"failure");}}]; //Clear all progress saved on Game Center.
        GameCenterUpdater* gameCenterUpdater = [[GameCenterUpdater alloc] init];
        [gameCenterUpdater sendScore:[resetScores objectAtIndex:0] andScores:resetScores];
        [defaults setValue:[NSNumber numberWithInt:0] forKey:@"totalCoins"];
        [[CCDirector sharedDirector]presentScene:[Settings scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:.5]];
    }
}

-(void)soundPressed{
    [[CCDirector sharedDirector]presentScene:[SoundSettings scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:.5]];
}

@end
