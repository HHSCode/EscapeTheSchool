//
//  MusicSettings.m
//  School Escape
//
//  Created by Kathleen Chaimberg on 3/20/14.
//  Copyright (c) 2014 Lordtechy. All rights reserved.
//

#import "MusicSettings.h"

@implementation  MusicSettings

+ (MusicSettings *)scene
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
    
    CCLayoutBox *musicSettingsLayoutBox = [[CCLayoutBox alloc]init];
    [musicSettingsLayoutBox setAnchorPoint:ccp(0.5, 0.5)];
    
    CCButton *settingsButton = [CCButton buttonWithTitle:@"< Back"];
    [settingsButton setTarget:self selector:@selector(settingsPressed)];
    [musicSettingsLayoutBox addChild:settingsButton];
    
    if ([[OALSimpleAudio sharedInstance]bgPlaying]) {
        CCButton *pauseButton = [CCButton buttonWithTitle:@"Pause Music"];
        [pauseButton setTarget:self selector:@selector(pausePressed)];
        [musicSettingsLayoutBox addChild:pauseButton];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSMutableString *song = [[NSMutableString alloc]initWithString:@"Play "];
        if ([[defaults valueForKey:@"music"]  isEqual: @"backgroundMusic1.mp3"]) {
            [song appendString:@"\"You\'re Time\""];
            CCButton *youretimeButton = [CCButton buttonWithTitle:song];
            [youretimeButton setTarget:self selector:@selector(youretimePressed)];
            [musicSettingsLayoutBox addChild:youretimeButton];
        } else {
            [song appendString:@"Background Music"];
            CCButton *backgroundButton = [CCButton buttonWithTitle:song];
            [backgroundButton setTarget:self selector:@selector(backgroundPressed)];
            [musicSettingsLayoutBox addChild:backgroundButton];
        }
    } else {
        CCButton *youretimeButton = [CCButton buttonWithTitle:@"Play \"You\'re Time\""];
        [youretimeButton setTarget:self selector:@selector(youretimePressed)];
        [musicSettingsLayoutBox addChild:youretimeButton];
        CCButton *backgroundButton = [CCButton buttonWithTitle:@"Play Background Music"];
        [backgroundButton setTarget:self selector:@selector(backgroundPressed)];
        [musicSettingsLayoutBox addChild:backgroundButton];
    }

    
    [musicSettingsLayoutBox setSpacing:10.f];
    [musicSettingsLayoutBox setDirection:CCLayoutBoxDirectionVertical];
    [musicSettingsLayoutBox setPosition:ccp(self.contentSize.width/2, self.contentSize.height/2)];
    [self addChild:musicSettingsLayoutBox];
    
    
    // done
	return self;
}

-(void)settingsPressed{
    [[CCDirector sharedDirector]presentScene:[Settings scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:.5]];
}

-(void)pausePressed{
    [[OALSimpleAudio sharedInstance]stopBg]; //Background music
    [[CCDirector sharedDirector]presentScene:[MusicSettings scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:.5]];
}

-(void)youretimePressed{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@"you'retime.mp3" forKey:@"music"];
    [[OALSimpleAudio sharedInstance]playBg:[defaults valueForKey:@"music"] loop:YES]; //Background music
    [[CCDirector sharedDirector]presentScene:[MusicSettings scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:.5]];
    [defaults synchronize];
}

-(void)backgroundPressed{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@"backgroundMusic1.mp3" forKey:@"music"];
    [[OALSimpleAudio sharedInstance]playBg:[defaults valueForKey:@"music"] loop:YES]; //Background music
    [[CCDirector sharedDirector]presentScene:[MusicSettings scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:.5]];
    [defaults synchronize];
}

@end