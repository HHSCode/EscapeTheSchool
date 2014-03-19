//
//  Pause.m
//  School Escape
//
//  Created by Kathleen Chaimberg on 3/17/14.
//  Copyright (c) 2014 Lordtechy. All rights reserved.
//

#import "Pause.h"

@implementation Pause

+ (Pause *)scene
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
    
    CCButton *gameButton = [CCButton buttonWithTitle:@"Resume"]; //creates resume button
    [gameButton setTarget:self selector:@selector(gamePressed)]; //if pressed run gamePressed
    CCButton *restartButton = [CCButton buttonWithTitle:@"Restart"]; //creates restart button
    [restartButton setTarget:self selector:@selector(restartPressed)]; //if pressed run restartPressed
    CCButton *gamecenterButton = [CCButton buttonWithTitle:@"Game Center"]; //creates Game Center button
    [gamecenterButton setTarget:self selector:@selector(gamecenterPressed)]; //if pressed run gamecenterPressed
    CCButton *menuButton = [CCButton buttonWithTitle:@"Menu"]; //creates menu button
    [menuButton setTarget:self selector:@selector(menuPressed)]; //if pressed run menuPressed
    
    CCLayoutBox *pauseLayoutBox = [[CCLayoutBox alloc]init]; //create layout box
    [pauseLayoutBox setAnchorPoint:ccp(0.5, 0.5)];
    [pauseLayoutBox addChild:menuButton]; //add menu to layout box
    [pauseLayoutBox addChild:restartButton]; //add restart to layout box
    [pauseLayoutBox addChild:gamecenterButton]; //add game center to layout box
    [pauseLayoutBox addChild:gameButton]; //add resume to layout box
    
    [pauseLayoutBox setSpacing:10.f];
    [pauseLayoutBox setDirection:CCLayoutBoxDirectionVertical];
    [pauseLayoutBox setPosition:ccp(self.contentSize.width/2, self.contentSize.height/2)];
    [self addChild:pauseLayoutBox]; //add layout box to scene
    
    
    // done
	return self;
}

-(void)gamePressed{
    [[CCDirector sharedDirector]popSceneWithTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionUp duration:.5]]; //resume game scene
    
}

-(void)restartPressed{
    [[CCDirector sharedDirector]popScene]; //discards current game
    [[CCDirector sharedDirector]replaceScene:[Game scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionDown duration:.5]]; //restarts game scene
}

-(void)menuPressed{
    [[CCDirector sharedDirector]popScene]; //discards current game
    [[CCDirector sharedDirector]replaceScene:[Menu scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:.5]]; //goes to menu scene
}

-(void)gamecenterPressed{
    [[GCHelper defaultHelper] showLeaderboardOnViewController:[CCDirector sharedDirector]]; //shows gamecenter on ccdirector through helper
}

@end
