//
//  About.m
//  School Escape
//
//  Created by Max Greenwald on 3/15/14.
//  Copyright 2014 Lordtechy. All rights reserved.
//

#import "About.h"


@implementation About
+ (About *)scene
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
    
    CCButton *menuButton = [CCButton buttonWithTitle:@"< Back" fontName:@"Marker Felt" fontSize:14];
    [menuButton setTarget:self selector:@selector(menuPressed)];
    
    CCLayoutBox *aboutLayoutBox = [[CCLayoutBox alloc]init];
    [aboutLayoutBox setAnchorPoint:ccp(0.5, 0.5)];
    [aboutLayoutBox addChild:menuButton];
    
    [aboutLayoutBox setSpacing:10.f];
    [aboutLayoutBox setDirection:CCLayoutBoxDirectionVertical];
    [aboutLayoutBox setPosition:ccp(self.contentSize.width/2, self.contentSize.height/2)];
    [self addChild:aboutLayoutBox];
    
    
    // done
	return self;
}

-(void)menuPressed{
    [[CCDirector sharedDirector]presentScene:[Menu scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:.5]];
    
}

@end
