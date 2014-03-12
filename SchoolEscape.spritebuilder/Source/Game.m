//
//  Game.m
//  SchoolEscape
//
//  Created by Max Greenwald on 3/12/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Game.h"
static const CGFloat scrollSpeed = 200.f; //CHANGE SPEED HERE

@implementation Game{
    CCSprite *_hero;
    CCPhysicsNode *_physicsNode;
    CCNode *_ground1;
    CCNode *_ground2;
    CCLabelTTF *_coins;
    CCLabelTTF *_distance;
    NSArray *_grounds;
}


- (void)didLoadFromCCB {
    _grounds = @[_ground1, _ground2];
    self.userInteractionEnabled = TRUE;

}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"Hero: %@", NSStringFromCGPoint(_hero.position));
    if (_hero.position.y<70) { //Y position is not constant but remains at about 66 when on ground, so this makes the hero only jump or duck when on the ground
        
    if (touch.locationInWorld.x<=[[UIScreen mainScreen] bounds].size.height/2) {
        [_hero.physicsBody applyImpulse:ccp(0, 40.f)];  //JUMP HEIGHT

    }else{ //ADD DUCKING HERE
        
    }
    }
}

- (void)update:(CCTime)delta {
    [_distance setString:[NSString stringWithFormat:@"%f", _hero.position.x]];
    _hero.position = ccp(_hero.position.x + delta * scrollSpeed, _hero.position.y);
    float yVelocity = clampf(_hero.physicsBody.velocity.y, -1 * MAXFLOAT, 200.f);
    _hero.physicsBody.velocity = ccp(0, yVelocity);
    _physicsNode.position = ccp(_physicsNode.position.x - (scrollSpeed *delta), _physicsNode.position.y);
    for (CCNode *ground in _grounds) {
        // get the world position of the ground
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width)) {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
        }
    }
}

@end
