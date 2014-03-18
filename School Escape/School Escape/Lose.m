//
//  Lose.m
//  School Escape
//
//  Created by Kathleen Chaimberg on 3/17/14.
//  Copyright (c) 2014 Lordtechy. All rights reserved.
//

#import "Lose.h"

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
    
    CCButton *restartButton = [CCButton buttonWithTitle:@"Restart"]; //creates restart button
    [restartButton setTarget:self selector:@selector(restartPressed)]; //if pressed run restartPressed
    CCButton *menuButton = [CCButton buttonWithTitle:@"Menu"]; //creates menu button
    [menuButton setTarget:self selector:@selector(menuPressed)]; //if pressed run menuPressed
    
    CCLayoutBox *loseLayoutBox = [[CCLayoutBox alloc]init]; //create layout box
    [loseLayoutBox setAnchorPoint:ccp(0.5, 0.5)];
    [loseLayoutBox addChild:menuButton]; //add menu to layout box
    [loseLayoutBox addChild:restartButton]; //add restart to layout box
    
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
