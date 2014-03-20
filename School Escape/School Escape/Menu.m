//
//  Menu.m
//  School Escape
//
//  Created by Max Greenwald on 3/15/14.
//  Copyright 2014 Lordtechy. All rights reserved.
//

#import "Menu.h"



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
    //[[OALSimpleAudio sharedInstance]playBg:@"backgroundMusic1.mp3" loop:YES];
    [[OALSimpleAudio sharedInstance]playBg:@"you'retime.mp3" loop:YES];

    CCButton *playButton = [CCButton buttonWithTitle:@"Play"];
    [playButton setTarget:self selector:@selector(playPressed)];
    
    CCButton *settingsButton = [CCButton buttonWithTitle:@"Settings"];
    [settingsButton setTarget:self selector:@selector(settingsPressed)];

    CCButton *storeButton = [CCButton buttonWithTitle:@"Store"];
    [storeButton setTarget:self selector:@selector(storePressed)];

    CCButton *aboutButton = [CCButton buttonWithTitle:@"About"];
    [aboutButton setTarget:self selector:@selector(aboutPressed)];

    CCLayoutBox *menuLayoutBox = [[CCLayoutBox alloc]init];
    [menuLayoutBox setAnchorPoint:ccp(0.5, 0.5)];
    [menuLayoutBox addChild:aboutButton];
    [menuLayoutBox addChild:settingsButton];
    [menuLayoutBox addChild:storeButton];
    [menuLayoutBox addChild:playButton];
    
    [menuLayoutBox setSpacing:10.f];
    [menuLayoutBox setDirection:CCLayoutBoxDirectionVertical];
    [menuLayoutBox setPosition:ccp(self.contentSize.width/2, self.contentSize.height/2)];
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
@end
