//
//  Lose.m
//  School Escape
//
//  Created by Kathleen Chaimberg on 3/17/14.
//  Copyright (c) 2014 Lordtechy. All rights reserved.
//

#import "Lose.h"
#import "GameCenterUpdater.h"

@implementation Lose
+ (Lose *)scene
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
    
    NSString* path = [(NSString *) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"scoreSaves.plist"];
    
    NSArray* Scores;
    if ([[NSFileManager defaultManager]fileExistsAtPath:path isDirectory:NO]) {
        Scores = [NSArray arrayWithContentsOfFile:path];
    }else{
        NSLog(@"No access to file! Using default score");
        Scores = [NSArray arrayWithObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:0,0,[NSDate date], nil] forKeys:[NSArray arrayWithObjects:@"distance",@"coins",@"time", nil]]];
    }
    
    Scores=[Scores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO], nil]];
    
    NSArray* HighScores = [Scores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:NO], nil]];
    NSDictionary* highScore = [HighScores objectAtIndex:0];
    
    GameCenterUpdater* gameCenterUpdater = [[GameCenterUpdater alloc] init];
    [gameCenterUpdater sendScore:[Scores objectAtIndex:0] andScores:Scores];
    
    CCButton *restartButton = [CCButton buttonWithTitle:@"Restart"]; //creates restart button
    [restartButton setTarget:self selector:@selector(restartPressed)]; //if pressed run restartPressed
    CCButton *menuButton = [CCButton buttonWithTitle:@"Menu"]; //creates menu button
    [menuButton setTarget:self selector:@selector(menuPressed)]; //if pressed run menuPressed
    CCLabelTTF *spacingLabel = [CCLabelTTF labelWithString:@" " fontName:@"Marker Felt" fontSize:20];
    CCLabelTTF *highScoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"High Score: %@",[highScore valueForKey:@"distance"]] fontName:@"Marker Felt" fontSize:10];
    CCLabelTTF *coinLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Coins: %@",[[Scores objectAtIndex:0] objectForKey:@"coins"]] fontName:@"Marker Felt" fontSize:20];
    CCLabelTTF *distanceLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Distance: %@",[[Scores objectAtIndex:0] objectForKey:@"distance"]] fontName:@"Marker Felt" fontSize:20];
    
    [Scores writeToFile:path atomically:YES];
    
    CCLayoutBox *loseLayoutBox = [[CCLayoutBox alloc]init]; //create layout box
    [loseLayoutBox setAnchorPoint:ccp(0.5, 0.5)];
    [loseLayoutBox addChild:menuButton]; //add menu to layout box
    [loseLayoutBox addChild:restartButton]; //add restart to layout box
    [loseLayoutBox addChild:spacingLabel]; //add spacing to layout box
    [loseLayoutBox addChild:coinLabel]; //add coin score to layout box
    [loseLayoutBox addChild:distanceLabel]; //add distance score to layout box
    [loseLayoutBox addChild:highScoreLabel]; //add high score label to layout box
    
    [loseLayoutBox setSpacing:10.f];
    [loseLayoutBox setDirection:CCLayoutBoxDirectionVertical];
    [loseLayoutBox setPosition:ccp(self.contentSize.width/2, self.contentSize.height/2)];
    [self addChild:loseLayoutBox]; //add layout box to scene
    
    
    // done
	return self;
}

-(void)restartPressed{
    [[CCDirector sharedDirector]presentScene:[Game scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionDown duration:.5]]; //restarts game scene
}

-(void)menuPressed{
    [[CCDirector sharedDirector]presentScene:[Menu scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:.5]]; //goes to menu scene
}
@end
