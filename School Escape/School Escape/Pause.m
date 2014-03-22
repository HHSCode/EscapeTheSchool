//
//  Pause.m
//  School Escape
//
//  Created by Kathleen Chaimberg on 3/17/14.
//  Copyright (c) 2014 Lordtechy. All rights reserved.
//

#import "Pause.h"
#import "ABGameKitHelper.h"

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
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* path = [(NSString *) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"scoreSaves.plist"];
    
    NSArray* Scores = [NSArray arrayWithContentsOfFile:path];
    Scores = [Scores sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:NO]]];
    int bestDistance = [[[Scores objectAtIndex:0] objectForKey:@"distance"] intValue];
    
    CCLabelTTF *totalDistanceLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Best Distance: %i",bestDistance] fontName:@"Marker Felt" fontSize:12];
    [totalDistanceLabel setAnchorPoint:ccp(0,1)];
    [totalDistanceLabel setPosition:ccp(0, self.contentSize.height)];
    [self addChild:totalDistanceLabel];
    
    CCLabelTTF *totalCoins = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Coins: %@",[defaults objectForKey:@"totalCoins"]] fontName:@"Marker Felt" fontSize:12];
    [totalCoins setAnchorPoint:ccp(1, 1)];
    [totalCoins setPosition:ccp(self.contentSize.width,self.contentSize.height)];
    [self addChild:totalCoins];
    
    CCButton *gameButton = [CCButton buttonWithTitle:@"Resume" fontName:@"Marker Felt" fontSize:24]; //creates resume button
    [gameButton setTarget:self selector:@selector(gamePressed)]; //if pressed run gamePressed
    CCButton *restartButton = [CCButton buttonWithTitle:@"Restart" fontName:@"Marker Felt" fontSize:18]; //creates restart button
    [restartButton setTarget:self selector:@selector(restartPressed)]; //if pressed run restartPressed
    CCButton *gamecenterButton = [CCButton buttonWithTitle:@"Game Center" fontName:@"Marker Felt" fontSize:18]; //creates Game Center button
    [gamecenterButton setTarget:self selector:@selector(gamecenterPressed)]; //if pressed run gamecenterPressed
    CCButton *menuButton = [CCButton buttonWithTitle:@"Menu" fontName:@"Marker Felt" fontSize:18]; //creates menu button
    [menuButton setTarget:self selector:@selector(menuPressed)]; //if pressed run menuPressed
    
    CCLayoutBox *pauseLayoutBox = [[CCLayoutBox alloc]init]; //create layout box
    [pauseLayoutBox setAnchorPoint:ccp(0.5, 0.5)];
    [pauseLayoutBox addChild:menuButton]; //add menu to layout box
    [pauseLayoutBox addChild:gamecenterButton]; //add game center to layout box
    
    if ([[OALSimpleAudio sharedInstance]bgPlaying]) {
        CCButton *pauseButton = [CCButton buttonWithTitle:@"Pause Music" fontName:@"Marker Felt" fontSize:18];
        [pauseButton setTarget:self selector:@selector(pausePressed)];
        [pauseLayoutBox addChild:pauseButton];
    } else {
        CCButton *playButton = [CCButton buttonWithTitle:@"Play Music" fontName:@"Marker Felt" fontSize:18];
        [playButton setTarget:self selector:@selector(playPressed)];
        [pauseLayoutBox addChild:playButton];
    }
    
    if (![[defaults objectForKey:@"soundeffects"] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        CCButton *soundOffButton = [CCButton buttonWithTitle:@"Mute Sound Effects" fontName:@"Marker Felt" fontSize:18];
        [soundOffButton setTarget:self selector:@selector(soundOffPressed)];
        [pauseLayoutBox addChild:soundOffButton];
    } else {
        CCButton *soundOnButton = [CCButton buttonWithTitle:@"Play Sound Effects" fontName:@"Marker Felt" fontSize:18];
        [soundOnButton setTarget:self selector:@selector(soundOnPressed)];
        [pauseLayoutBox addChild:soundOnButton];
    }
    
    [pauseLayoutBox addChild:restartButton]; //add restart to layout box

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
    ABGameKitHelper *helper = [[ABGameKitHelper alloc] init];
    [helper showAchievements];
}

-(void)pausePressed{
    [[OALSimpleAudio sharedInstance]stopBg]; //Background music
    [[CCDirector sharedDirector]presentScene:[Pause scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:.5]];
}

-(void)playPressed{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [[OALSimpleAudio sharedInstance]playBg:[defaults valueForKey:@"music"] loop:YES]; //Background music
    [[CCDirector sharedDirector]presentScene:[Pause scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:.5]];
}

-(void)soundOnPressed{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL *sound = NO;
    [defaults setObject:[NSNumber numberWithBool:sound] forKey:@"soundeffects"];
    [[CCDirector sharedDirector]presentScene:[Pause scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:.5]];
}

-(void)soundOffPressed{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL *sound = YES;
    [defaults setObject:[NSNumber numberWithBool:sound] forKey:@"soundeffects"];
    [[CCDirector sharedDirector]presentScene:[Pause scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:.5]];
}

@end
