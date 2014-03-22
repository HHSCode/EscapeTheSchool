//
//  MusicSettings.m
//  School Escape
//
//  Created by Kathleen Chaimberg on 3/20/14.
//  Copyright (c) 2014 Lordtechy. All rights reserved.
//

#import "SoundSettings.h"

@implementation  SoundSettings

+ (SoundSettings *)scene
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
    
    CCButton *settingsButton = [CCButton buttonWithTitle:@"< Back" fontName:@"Marker Felt" fontSize:14];
    [settingsButton setTarget:self selector:@selector(settingsPressed)];
    [musicSettingsLayoutBox addChild:settingsButton];
    
    if ([[OALSimpleAudio sharedInstance]bgPlaying]) {
        CCButton *pauseButton = [CCButton buttonWithTitle:@"Pause Music" fontName:@"Marker Felt" fontSize:18];
        [pauseButton setTarget:self selector:@selector(pausePressed)];
        [musicSettingsLayoutBox addChild:pauseButton];
    } else {
        CCButton *playButton = [CCButton buttonWithTitle:@"Play Music" fontName:@"Marker Felt" fontSize:18];
        [playButton setTarget:self selector:@selector(playPressed)];
        [musicSettingsLayoutBox addChild:playButton];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![[defaults objectForKey:@"soundeffects"] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        CCButton *soundOffButton = [CCButton buttonWithTitle:@"Mute Sound Effects" fontName:@"Marker Felt" fontSize:18];
        [soundOffButton setTarget:self selector:@selector(soundOffPressed)];
        [musicSettingsLayoutBox addChild:soundOffButton];
    } else {
        CCButton *soundOnButton = [CCButton buttonWithTitle:@"Play Sound Effects" fontName:@"Marker Felt" fontSize:18];
        [soundOnButton setTarget:self selector:@selector(soundOnPressed)];
        [musicSettingsLayoutBox addChild:soundOnButton];
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
    [[CCDirector sharedDirector]presentScene:[SoundSettings scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:.5]];
}

-(void)playPressed{
    [[OALSimpleAudio sharedInstance]playBg:@"backgroundMusic1.mp3" loop:YES]; //Background music
    [[CCDirector sharedDirector]presentScene:[SoundSettings scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:.5]];
}

-(void)soundOnPressed{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL *sound = NO;
    [defaults setObject:[NSNumber numberWithBool:sound] forKey:@"soundeffects"];
    [[CCDirector sharedDirector]presentScene:[SoundSettings scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:.5]];
}

-(void)soundOffPressed{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL *sound = YES;
    [defaults setObject:[NSNumber numberWithBool:sound] forKey:@"soundeffects"];
    [[CCDirector sharedDirector]presentScene:[SoundSettings scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:.5]];
}

@end