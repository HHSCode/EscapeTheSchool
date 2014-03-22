//
//  Menu.m
//  School Escape
//
//  Created by Max Greenwald on 3/15/14.
//  Copyright 2014 Lordtechy. All rights reserved.
//

#import "Menu.h"
#import "ABGameKitHelper.h"
#import "CCAnimation.h"

@implementation Menu
+ (Menu *)scene
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
    
    NSMutableArray *runFrames = [NSMutableArray array]; //initialize runFrames array
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache]; //initialize cache
    [cache addSpriteFramesWithFile:@"runningmansheet.plist"]; //add spritesheet to cache
    
    for(int i = 1; i <= 3; ++i) //forloop uses 3 frames
    {
        [runFrames addObject:[cache spriteFrameByName: [NSString stringWithFormat:@"runningman%i.png", i]]]; //adds sprite image to array based on i in loop
    }
    CCAnimation *runAnimation = [CCAnimation animationWithSpriteFrames:runFrames delay:0.1f]; //creates animation with runFrames with delay between of 0.1
    CCActionAnimate *animationAction = [CCActionAnimate actionWithAnimation:runAnimation]; //creates action with animation
    CCActionAnimate *animationAction2 = [CCActionAnimate actionWithAnimation:runAnimation]; //creates action with animation
    CCActionRepeatForever *repeatingAnimation = [CCActionRepeatForever actionWithAction:animationAction]; //repeats action forever
    CCActionRepeatForever *repeatingAnimation2 = [CCActionRepeatForever actionWithAction:animationAction2]; //repeats action forever
    CCNode *_hero = [CCSprite spriteWithImageNamed:@"runningman1.png"]; //initializes hero with first image
    [_hero runAction:repeatingAnimation]; //assigns animation to hero
    [_hero setAnchorPoint:ccp(1, .5)];
    [_hero setPosition:ccp(self.contentSize.width/2, self.contentSize.height/2)];
    [_hero setScaleX:.75];
    [_hero setScaleY:.75];
    [self addChild:_hero];
    CCNode *_hero2 = [CCSprite spriteWithImageNamed:@"runningman1.png"]; //initializes hero with first image
    [_hero2 runAction:repeatingAnimation2]; //assigns animation to hero
    [_hero2 setAnchorPoint:ccp(0, .5)];
    [_hero2 setPosition:ccp(self.contentSize.width/2, self.contentSize.height/2)];
    [_hero2 setScaleX:.75];
    [_hero2 setScaleY:.75];
    [self addChild:_hero2];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* path = [(NSString *) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"scoreSaves.plist"];
    
    NSArray* Scores = [NSArray arrayWithContentsOfFile:path];
    Scores = [Scores sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:NO]]];
    int bestDistance = [[[Scores objectAtIndex:0] objectForKey:@"distance"] intValue];

    CCButton *playButton = [CCButton buttonWithTitle:@"Play" fontName:@"Marker Felt" fontSize:24];
    [playButton setTarget:self selector:@selector(playPressed)];
    
    CCButton *settingsButton = [CCButton buttonWithTitle:@"Settings" fontName:@"Marker Felt" fontSize:18];
    [settingsButton setTarget:self selector:@selector(settingsPressed)];

    CCButton *storeButton = [CCButton buttonWithTitle:@"Store" fontName:@"Marker Felt" fontSize:18];
    [storeButton setTarget:self selector:@selector(storePressed)];

    CCButton *aboutButton = [CCButton buttonWithTitle:@"About" fontName:@"Marker Felt" fontSize:18];
    [aboutButton setTarget:self selector:@selector(aboutPressed)];
    
    CCLabelTTF *totalDistanceLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Best Distance: %i",bestDistance] fontName:@"Marker Felt" fontSize:12];
    
    CCLabelTTF *totalCoins = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Coins: %@",[defaults objectForKey:@"totalCoins"]] fontName:@"Marker Felt" fontSize:12];

    CCButton *gamecenterButton = [CCButton buttonWithTitle:@"Game Center" fontName:@"Marker Felt" fontSize:18]; //creates Game Center button
    [gamecenterButton setTarget:self selector:@selector(gamecenterPressed)]; //if pressed run gamecenterPressed
    
    CCLayoutBox *menuLayoutBox = [[CCLayoutBox alloc]init];
    [menuLayoutBox setAnchorPoint:ccp(0.5, 0.5)];
    [menuLayoutBox addChild:aboutButton];
    [menuLayoutBox addChild:settingsButton];
    [menuLayoutBox addChild:gamecenterButton];
    [menuLayoutBox addChild:storeButton];
    [menuLayoutBox addChild:playButton];
    
    [menuLayoutBox setSpacing:10.f];
    [menuLayoutBox setDirection:CCLayoutBoxDirectionVertical];
    [menuLayoutBox setPosition:ccp(self.contentSize.width/2, self.contentSize.height/2)];
    
    
    [totalCoins setAnchorPoint:ccp(1, 1)];
    [totalCoins setPosition:ccp(self.contentSize.width,self.contentSize.height)];
    [self addChild:totalCoins];
    
    [totalDistanceLabel setAnchorPoint:ccp(0,1)];
    [totalDistanceLabel setPosition:ccp(0, self.contentSize.height)];
    [self addChild:totalDistanceLabel];
    
    
    [self addChild:menuLayoutBox];
    

    // done
	return self;
}

-(void)playPressed{
    [[CCDirector sharedDirector]presentScene:[Game scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:.5]];
}

-(void)settingsPressed{
    [[CCDirector sharedDirector]presentScene:[Settings scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:.5]];
}

-(void)aboutPressed{
    [[CCDirector sharedDirector]presentScene:[About scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:.5]];
}

-(void)storePressed{
    [[CCDirector sharedDirector]presentScene:[Store scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:.5]];
}

-(void)gamecenterPressed{
    ABGameKitHelper *helper = [[ABGameKitHelper alloc] init];
    [helper showAchievements];
}

@end
