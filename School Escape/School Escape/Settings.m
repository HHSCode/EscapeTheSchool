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
    
    CCButton *menuButton = [CCButton buttonWithTitle:@"< Back"];
    [menuButton setTarget:self selector:@selector(menuPressed)];
    
    CCLayoutBox *settingsLayoutBox = [[CCLayoutBox alloc]init];
    [settingsLayoutBox setAnchorPoint:ccp(0.5, 0.5)];
    [settingsLayoutBox addChild:menuButton];
    
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

@end
