//
//  Game.m
//  School Escape
//
//  Created by Max Greenwald on 3/15/14.
//  Copyright 2014 Lordtechy. All rights reserved.
//

#import "Game.h"
static const CGFloat scrollSpeed = 160.f; //scroll speed, change this to make it go faster or slower. this could possibly be dynamic


@implementation Game{
    CCPhysicsNode *_physicsNode; //main physics node
    
    CCNode *_hero; //the hero, or the main character, or the runner
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds; //array that stores the two grounds so they can change positionand seem continuous
    NSMutableArray *_coins; //array that stores all the coins and checks them to see if they collided with the hero in the update method
}
+ (Game *)scene //DONT TOUCH THIS
{
    return [[self alloc] init];
}


- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    self.userInteractionEnabled = YES; //makes it so user can touch screen
    
    [self schedule:@selector(addCoin) interval:4];//schedules addcoin method so a new coin is added every 4 seconds. Decrease this to make coins less frequent
    
    _coins = [[NSMutableArray alloc]init];//allocate coins array

    //BACKGROUND
    CCSprite *_background = [CCSprite spriteWithImageNamed:@"background1.png"]; //change this to change the background, make sure the size is the same as the current background of the new file when changing
    [_background setPosition:ccp(0, 0)];
    [_background setAnchorPoint:ccp(0, 0)];
    [_background setScaleX:.5];
    [_background setScaleY:.5];
    [self addChild:_background];
    
    //GROUND 1
    _ground1 = [CCSprite spriteWithImageNamed:@"ground2.png"];
    [_ground1 setAnchorPoint:ccp(0, 0)];
    [_ground1 setScaleX:.5];
    [_ground1 setScaleY:.5];
    [_ground1 setPosition:ccp(0, 0)];
    
    //GROUND 2 SPRITE
    _ground2 = [CCSprite spriteWithImageNamed:@"ground2.png"];
    [_ground2 setAnchorPoint:ccp(0, 0)];
    [_ground2 setPosition:ccp(568, 0)];
    [_ground2 setScaleX:.5];
    [_ground2 setScaleY:.5];
    
    //HERO
    _hero = [CCSprite spriteWithImageNamed:@"walking-man-black.png" ];
    [_hero setAnchorPoint:ccp(0, 0)];
    [_hero setPosition:ccp(40, 100)];
    [_hero setScaleX:.075];
    [_hero setScaleY:.075];

    
    //PHYSICS NODE
    _physicsNode = [CCPhysicsNode node];
    _physicsNode.gravity = ccp(0,-600); //change this to increase or decrease gravity
    _physicsNode.debugDraw = YES; //change this to see phsyics bodies
    _physicsNode.collisionDelegate = self;
    
    //GROUND 1 PHYSICS
    _ground1.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _ground1.contentSize} cornerRadius:0];
    _ground1.physicsBody.collisionGroup = @"groundGroup";
    _ground1.physicsBody.collisionType = @"groundType";
    _ground1.physicsBody.type=CCPhysicsBodyTypeStatic;
    [_physicsNode addChild:_ground1];
    
    //GROUND 2 PHYSICS
    _ground2.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _ground2.contentSize} cornerRadius:0];
    _ground2.physicsBody.collisionGroup = @"groundGroup";
    _ground2.physicsBody.collisionType = @"groundType";
    _ground2.physicsBody.type=CCPhysicsBodyTypeStatic;
    [_physicsNode addChild:_ground2];
    
    //HERO PHYSICS
    _hero.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _hero.contentSize} cornerRadius:0];
    _hero.physicsBody.collisionGroup = @"heroGroup";
    _hero.physicsBody.collisionType = @"heroType";
    _hero.physicsBody.allowsRotation=NO;
    [_physicsNode addChild:_hero];

    _grounds = [[NSArray alloc]initWithObjects:_ground1, _ground2, nil ];//allocate grounds array

    [self addChild:_physicsNode]; //add physics node to the scene

	return self;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (_hero.position.y<30.0) { //checks if hero is on the ground before allowing it to jump. the hero is generally at 29.9 when on the ground, so hopefully this will always work
        [_hero.physicsBody applyImpulse:ccp(0, 375.f)]; //applies impulse to make the hero jump

    }
}

-(void)addCoin{
    CCNode *_coin = [[CCSprite alloc]initWithImageNamed:@"coin1.png"]; //change this to change how the coin looks
    [_coin setScaleY:.075];
    [_coin setScaleX:.075];
    float coinSize = 50; //this is uesed to calculate the coin position, or basically where it is placed on the screen, max and min
    [_coin setAnchorPoint:ccp(0, 0)];

    _coin.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:_coin.contentSize.width/2 andCenter:ccp(_coin.contentSize.width/2, _coin.contentSize.height/2)];
    _coin.physicsBody.collisionGroup = @"heroGroup";
    _coin.physicsBody.collisionType = @"coinType";
    
    _coin.physicsBody.type=CCPhysicsBodyTypeStatic; //coins are static
    int minY = _ground1.contentSize.height+(coinSize/2)+10; //min is above the ground slightly
    int maxY = self.contentSize.height-(coinSize/2)-50;//max is below the top but in reach ofthe character jumping
    int rangeY = maxY - minY;
    int randomY = (arc4random() % rangeY) + minY;
    
    _coin.position = CGPointMake(-1*_physicsNode.position.x+self.contentSize.width, randomY); //sets coin position off to the right at a random y location
    [_coins addObject:_coin]; //adds coin to _coins so it can check for collisions
    [_physicsNode addChild:_coin]; //adds coin to physics node
}

- (void)update:(CCTime)delta {
    _hero.position = ccp(_hero.position.x + delta * scrollSpeed, _hero.position.y); //keeps hero in line with the moving physics node
    _physicsNode.position = ccp(_physicsNode.position.x - (scrollSpeed *delta), _physicsNode.position.y); //moves the physics node to the left
    // loop the ground
    
    for (CCNode *ground in _grounds) {
        // get the world position of the ground
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width/2)) {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width/2, ground.position.y);
        }
    }
    for (CCNode *coin in _coins) {
        if (CGRectIntersectsRect([_hero boundingBox], [coin boundingBox])) { //check if hero and coin collides, if so remove coin from screen. need to add a counter
            
            [coin removeFromParent];
            [_coins removeObject:coin];
        }
        
        
    }
    
}

//COLLISIONS


-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair groundType:(CCNode *)nodeA heroType:(CCNode *)nodeB{
    return YES;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair coinType:(CCNode *)coin heroType:(CCNode *)hero{
    [coin removeFromParent];
    return YES;
}
@end
