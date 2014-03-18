//
//  Game.m
//  School Escape
//
//  Created by Max Greenwald on 3/15/14.
//  Copyright 2014 Lordtechy. All rights reserved.
//

#import "Game.h"
#import "CCAnimation.h"
static const CGFloat scrollSpeed = 225.f; //scroll speed, change this to make it go faster or slower. this could possibly be dynamic


@implementation Game{
    CCPhysicsNode *_physicsNode; //main physics node
    int coinCounter;
    int score;
    CCNode *_hero; //the hero, or the main character, or the runner
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds; //array that stores the two grounds so they can change positionand seem continuous
    NSMutableArray *_coins; //array that stores all the coins and checks them to see if they collided with the hero in the update method
    NSMutableArray *_coins2;
    NSMutableArray *_obstacles;
    CCLabelTTF *_coinCounterLabel;
    BOOL hasDoubleJumped;
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
    
    [self schedule:@selector(addCoin) interval:1];//schedules addcoin method so a new coin is added every 4 seconds. Decrease this to make coins less frequent
    [self schedule:@selector(addObstacle) interval:5];
    
    _coins = [[NSMutableArray alloc]init];//allocate coins array
    _obstacles = [[NSMutableArray alloc]init];
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
    NSMutableArray *runFrames = [NSMutableArray array]; //initialize runFrames array
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache]; //initialize cahce
    [cache addSpriteFramesWithFile:@"runningmansheet.plist"]; //add spritesheet to cache

    for(int i = 1; i <= 3; ++i) //forloop uses 3 frames
    {
        [runFrames addObject:[cache spriteFrameByName: [NSString stringWithFormat:@"runningman%i.png", i]]]; //adds sprite image to array based on i in loop
    }
    CCAnimation *runAnimation = [CCAnimation animationWithSpriteFrames:runFrames delay:0.1f]; //creates animation with runFrames with delay between of 0.1
    CCActionAnimate *animationAction = [CCActionAnimate actionWithAnimation:runAnimation]; //creates action with animation
    CCActionRepeatForever *repeatingAnimation = [CCActionRepeatForever actionWithAction:animationAction]; //repeats action forever
    _hero = [CCSprite spriteWithImageNamed:@"runningman1.png" ]; //initializes hero with first image
    [_hero runAction:repeatingAnimation]; //assigns animation to hero
    [_hero setAnchorPoint:ccp(0, 0)];
    [_hero setPosition:ccp(60, 100)];
    [_hero setScaleX:.25];
    [_hero setScaleY:.25];

    
    //PHYSICS NODE
    _physicsNode = [CCPhysicsNode node];
    _physicsNode.gravity = ccp(0,-1500); //change this to increase or decrease gravity
    _physicsNode.debugDraw = YES; //YES to see phsyics bodies
    _physicsNode.collisionDelegate = self;
    
    //GROUND 1 PHYSICS
    _ground1.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _ground1.contentSize} cornerRadius:0];
    _ground1.physicsBody.collisionGroup = @"groundGroup";
    _ground1.physicsBody.collisionType = @"groundType";
    _ground1.physicsBody.type=CCPhysicsBodyTypeStatic;
    _ground1.physicsBody.elasticity=0;
    [_physicsNode addChild:_ground1];
    
    //GROUND 2 PHYSICS
    _ground2.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _ground2.contentSize} cornerRadius:0];
    _ground2.physicsBody.collisionGroup = @"groundGroup";
    _ground2.physicsBody.collisionType = @"groundType";
    _ground2.physicsBody.type=CCPhysicsBodyTypeStatic;
    _ground2.physicsBody.elasticity=0;
    [_physicsNode addChild:_ground2];
    
    //HERO PHYSICS
    _hero.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _hero.contentSize} cornerRadius:0];
    _hero.physicsBody.collisionGroup = @"heroGroup";
    _hero.physicsBody.collisionType = @"heroType";
    _hero.physicsBody.allowsRotation=NO;
    _hero.physicsBody.elasticity=0;
    [_physicsNode addChild:_hero];
    
    //COIN COUNTER
    score = 0;
    _coinCounterLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:20];
    [_coinCounterLabel setPosition:ccp(self.contentSize.width-10, self.contentSize.height-10)];
    [_coinCounterLabel setColor:(0,0,0)];
    [_coinCounterLabel setAnchorPoint:ccp(1, 1)];
    [self addChild:_coinCounterLabel z:1];

    _grounds = [[NSArray alloc]initWithObjects:_ground1, _ground2, nil ];//allocate grounds array

    [self addChild:_physicsNode]; //add physics node to the scene

	return self;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (_hero.position.y<30.0) { //checks if hero is on the ground before allowing it to jump. the hero is generally at 29.9 when on the ground, so hopefully this will always work
        [_hero.physicsBody applyImpulse:ccp(0, 600.f)]; //applies impulse to make the hero jump

    }else{
        if (hasDoubleJumped==NO) {
            [_hero.physicsBody setVelocity:ccp(0, 0)];
            [_hero.physicsBody applyImpulse:ccp(0, 500.f)]; //applies impulse to make the hero jump
            hasDoubleJumped=YES;
        }
    }
}

-(void)addCoin{
    CCNode *_coin = [[CCSprite alloc]initWithImageNamed:@"coin1.png"]; //change this to change how the coin looks
    [_coin setScaleY:.040];
    [_coin setScaleX:.040];
    float coinSize = 10; //this is uesed to calculate the coin position, or basically where it is placed on the screen, max and min
    [_coin setAnchorPoint:ccp(0, 0)];

    _coin.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:_coin.contentSize.width/2-40 andCenter:ccp(_coin.contentSize.width/2, _coin.contentSize.height/2)];
    _coin.physicsBody.collisionGroup = @"heroGroup";
    _coin.physicsBody.collisionType = @"coinType";
    
    _coin.physicsBody.type=CCPhysicsBodyTypeStatic; //coins are static
    int minY = 50; //min is above the ground slightly
    int maxY = self.contentSize.height-(coinSize/2)-50;//max is below the top but in reach ofthe character jumping
    int rangeY = maxY - minY;
    int randomY = (arc4random() % rangeY) + minY;
    
    _coin.position = CGPointMake(-1*_physicsNode.position.x+self.contentSize.width, randomY); //sets coin position off to the right at a random y location
    [_coins addObject:_coin]; //adds coin to _coins so it can check for collisions
    if ([_coins count]>30) {
        [_coins removeObjectAtIndex:0];
    }
    [_physicsNode addChild:_coin]; //adds coin to physics node
}

-(void)addObstacle{
    CCNode *_obstacle = [[CCSprite alloc]initWithImageNamed:@"desk.png"]; //change this to change how the coin looks
    [_obstacle setScaleY:.15];
    [_obstacle setScaleX:.15];
    float obstacleSize = 100; //this is uesed to calculate the coin position, or basically where it is placed on the screen, max and min
    [_obstacle setAnchorPoint:ccp(0, 0)];
    _obstacle.physicsBody.elasticity=0;
    _obstacle.physicsBody = [CCPhysicsBody bodyWithRect:CGRectMake(0, 0, _obstacle.contentSize.width, _obstacle.contentSize.height) cornerRadius:0];
    _obstacle.physicsBody.collisionGroup = @"obstacleGroup";
    _obstacle.physicsBody.collisionType = @"obstacleType";
    
    _obstacle.physicsBody.type=CCPhysicsBodyTypeStatic; //coins are static
    
    
    _obstacle.position = CGPointMake(-1*_physicsNode.position.x+self.contentSize.width, 29); //sets coin position off to the right at a random y location
    //[_coins addObject:_coin]; //adds coin to _coins so it can check for collisions
    [_obstacles addObject:_obstacle];
    if ([_coins count]>30) {
        [_coins removeObjectAtIndex:0];
        
    }
    [_physicsNode addChild:_obstacle]; //adds coin to physics node

}

- (void)update:(CCTime)delta {
    _hero.position = ccp(_hero.position.x + delta * scrollSpeed, _hero.position.y); //keeps hero in line with the moving physics node
    _physicsNode.position = ccp(_physicsNode.position.x - (scrollSpeed *delta), _physicsNode.position.y); //moves the physics node to the left
    // loop the ground
    
    //Check if hero is off screen
    CGPoint heroWorldPosition = [_physicsNode convertToWorldSpace:_hero.position];
    // get the screen position of the ground
    CGPoint heroScreenPosition = [self convertToNodeSpace:heroWorldPosition];
    
    if (heroScreenPosition.x <= 0) { //IF HERO IS OFFSCREEN - AKA YOU LOST
        [[CCDirector sharedDirector]presentScene:[Game scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1]]; //go back to game scene, just tempororary until YOU LOST screen
    
    }
    if (_hero.position.y<30) {
        hasDoubleJumped=NO;
    }
    
    for (CCNode *ground in _grounds) {
        // get the world position of the ground
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width/2)) { //DOES NOT WORK, NOT SURE WHY
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width/2, ground.position.y);
        }
    }
    
    NSMutableArray *_coins2 = [_coins mutableCopy];
    
    for (CCNode *coin in _coins2) {
        
        BOOL shouldRemove = NO;
        BOOL upScore = NO;
        CGPoint coinWorldPosition = [_physicsNode convertToWorldSpace:coin.position];
        // get the screen position of the ground
        CGPoint coinScreenPosition = [self convertToNodeSpace:coinWorldPosition];
        
        if (coinScreenPosition.x<=(-1*coin.contentSize.width/2)) {
            shouldRemove=YES;
            
        }

        if (CGRectIntersectsRect([_hero boundingBox], [coin boundingBox])) { //check if hero and coin collides, if so remove coin from screen. need to add a counter
            
            shouldRemove=YES;
            upScore=YES;
            coinCounter++;
        }
        
        if (shouldRemove) {
            [coin removeFromParent];
            [_coins removeObject:coin];

        }
        
        if (upScore) {
            score++;
            [_coinCounterLabel setString:[NSString stringWithFormat:@"%i", score]];
            upScore = NO;
        }
        
        
    }
    
    //Obstacle Collisions
    
    for (CCNode *obstacle in _obstacles) {
        BOOL shouldRemove = NO;
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        // get the screen position of the ground
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        
        if (obstacleScreenPosition.x<=(-1*obstacle.contentSize.width/2)) {
            shouldRemove=YES;
            
        }
        
        if (CGRectIntersectsRect([_hero boundingBox], [obstacle boundingBox])) { //check if hero and coin collides, if so remove coin from screen. need to add a counter
            NSLog(@"Hero r: %f", _hero.position.x+_hero.contentSize.width);
            NSLog(@"Obst l: %f", obstacle.position.x);
            NSLog(@"Hero b: %f", _hero.position.y);
            NSLog(@"Obst t: %f\n|", obstacle.position.y+obstacle.contentSize.height);

            //shouldRemove=YES;
        }
        
        if (shouldRemove) {
            [obstacle removeFromParent];
            
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
