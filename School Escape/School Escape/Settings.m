//
//  Settings.m
//  School Escape
//
//  Created by Max Greenwald on 3/15/14.
//  Copyright 2014 Lordtechy. All rights reserved.
//

#import "Settings.h"


@implementation Settings{
    BOOL stopMusic;
}
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
    
    if ([[OALSimpleAudio sharedInstance]bgPlaying]) {
        CCButton *pauseButton = [CCButton buttonWithTitle:@"Pause Music"];
        [pauseButton setTarget:self selector:@selector(pausePressed)];
        [settingsLayoutBox addChild:pauseButton];
    } else {
        CCButton *playButton = [CCButton buttonWithTitle:@"Play Music"];
        [playButton setTarget:self selector:@selector(playPressed)];
        [settingsLayoutBox addChild:playButton];
    }
    
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

-(void)pausePressed{
    [[OALSimpleAudio sharedInstance]stopBg]; //Background music
    [[CCDirector sharedDirector]presentScene:[Settings scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:.5]];
    stopMusic = TRUE;
}

-(void)playPressed{
    [[OALSimpleAudio sharedInstance]playBg:@"backgroundMusic1.mp3" loop:YES]; //Background music
    [[CCDirector sharedDirector]presentScene:[Settings scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:.5]];
}

@end
