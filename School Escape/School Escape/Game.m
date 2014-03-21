//
//  Game.m
//  School Escape
//
//  Created by Max Greenwald on 3/15/14.
//  Copyright 2014 Lordtechy. All rights reserved.
//

#import "Game.h"
#import "CCAnimation.h"

float scrollSpeed;
int gameTime;


@implementation Game{
    CCPhysicsNode *_physicsNode; //main physics node
    int score;
    int distance;
    int numberOfBooksDodged;
    CCNode *_hero; //the hero, or the main character, or the runner
    CCNode *_ground1;
    CCNode *_ground2;
    CCNode *_background1;
    CCNode *_background2;
    CCNode *_background3;
    CCNode *_background4;
    CCNode *_background5;


    NSArray *_grounds; //array that stores the two grounds so they can change positionand seem continuous
    NSArray *_backgrounds;
    NSMutableArray *_coins; //array that stores all the coins and checks them to see if they collided with the hero in the update method
    NSMutableArray *_coins2;
    NSMutableArray *_obstacles;
    NSMutableArray *_flyingObstacles;

    CCLabelTTF *_coinCounterLabel;
    CCLabelTTF *_distanceLabel;
    CCLabelTTF *_coinCounterLabelStatic;
    CCLabelTTF *_distanceLabelStatic;
    BOOL hasDoubleJumped;
    BOOL intersects;
}
+ (Game *)scene //DONT TOUCH THIS
{
    return [[self alloc] init];
}



-(void)updateCoinSpawnSpeed{
    float CoinInterval = (float)(arc4random() % 9)+1;
    NSLog(@"CoinInterval: %f",CoinInterval);
    [self unschedule:@selector(addCoin)];
    [self schedule:@selector(addCoin) interval:CoinInterval];//schedules addcoin method so a new coin is added at a random interval (this is the start interval for the schedule)
}

-(void)updateFlyingObstacleSpawnSpeed{
    float flyingObstacleInterval = ((float)(arc4random() % 9)+1)*2;
    NSLog(@"Flyinginterval: %f", flyingObstacleInterval);
    [self unschedule:@selector(addFlyingObstacle)];
    [self schedule:@selector(addFlyingObstacle) interval:flyingObstacleInterval];//schedules addFlyingObstacle method so a new flying obstacle is added at a random interval (this is the start interval for the schedule)
}

//Track GameTime
-(void)updateGameTime{
    gameTime ++;
}
//Change Scroll Speed over time
-(void)updateScrollSpeed{
    if (scrollSpeed < 2000) { //Stop at 2000
        scrollSpeed = scrollSpeed +5;
    }
}

- (id)init
{
    gameTime = 0;
    scrollSpeed = 150;
    numberOfBooksDodged = 0;
    
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    self.userInteractionEnabled = YES; //makes it so user can touch screen
    
    
    
    [self schedule:@selector(addCoin) interval:2];//schedules addcoin method so a new coin is added at a random interval (this is the start interval for the schedule)
    //[self schedule:@selector(updateCoinSpawnSpeed) interval:0.5];
    //float flyingObstacleInterval = (float)(arc4random() % 9)+1;
    #warning must fix the flying interval to be random
    
    [self schedule:@selector(addFlyingObstacle) interval:3];
    
    //[self schedule:@selector(updateFlyingObstacleSpawnSpeed) interval:0.5];
    [self schedule:@selector(updateGameTime) interval:1];
    [self schedule:@selector(updateScrollSpeed) interval:1];
    scrollSpeed=225; //scroll speed, change this to make it go faster or slower. this could possibly be dynamic
    gameTime=0;
    
    _coins = [[NSMutableArray alloc]init];//allocate coins array
    _obstacles = [[NSMutableArray alloc]init];
    _flyingObstacles = [[NSMutableArray alloc]init];
    
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
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache]; //initialize cache
    [cache addSpriteFramesWithFile:@"runningmansheet.plist"]; //add spritesheet to cache

    for(int i = 1; i <= 3; ++i) //forloop uses 3 frames
    {
        [runFrames addObject:[cache spriteFrameByName: [NSString stringWithFormat:@"runningman%i.png", i]]]; //adds sprite image to array based on i in loop
    }
    CCAnimation *runAnimation = [CCAnimation animationWithSpriteFrames:runFrames delay:0.1f]; //creates animation with runFrames with delay between of 0.1
    CCActionAnimate *animationAction = [CCActionAnimate actionWithAnimation:runAnimation]; //creates action with animation
    CCActionRepeatForever *repeatingAnimation = [CCActionRepeatForever actionWithAction:animationAction]; //repeats action forever
    _hero = [CCSprite spriteWithImageNamed:@"runningman1.png"]; //initializes hero with first image
    [_hero runAction:repeatingAnimation]; //assigns animation to hero
    [_hero setAnchorPoint:ccp(0, 0)];
    [_hero setPosition:ccp(60, 100)];
    [_hero setScaleX:.2];
    [_hero setScaleY:.2];
    
    
    //PHYSICS NODE
    _physicsNode = [CCPhysicsNode node];
    _physicsNode.gravity = ccp(0,-1500); //change this to increase or decrease gravity
    _physicsNode.debugDraw = NO; //YES to see phsyics bodies
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
    [_coinCounterLabel setColor:[CCColor blackColor]];
    [_coinCounterLabel setAnchorPoint:ccp(1, 1)];
    [self addChild:_coinCounterLabel z:1];
    _coinCounterLabelStatic = [CCLabelTTF labelWithString:@"Coins: " fontName:@"Marker Felt" fontSize:20];
    [_coinCounterLabelStatic setPosition:ccp(self.contentSize.width-60, self.contentSize.height-10)];
    [_coinCounterLabelStatic setColor:[CCColor blackColor]];
    [_coinCounterLabelStatic setAnchorPoint:ccp(1, 1)];
    [self addChild:_coinCounterLabelStatic z:1];
    
    //DISTANCE
    distance = 0;
    _distanceLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:20];
    [_distanceLabel setPosition:ccp(self.contentSize.width-10, self.contentSize.height-30)];
    [_distanceLabel setColor:[CCColor blackColor]];
    [_distanceLabel setAnchorPoint:ccp(1, 1)];
    [self addChild:_distanceLabel z:1];
    _distanceLabelStatic = [CCLabelTTF labelWithString:@"Distance: " fontName:@"Marker Felt" fontSize:20];
    [_distanceLabelStatic setPosition:ccp(self.contentSize.width-60, self.contentSize.height-30)];
    [_distanceLabelStatic setColor:[CCColor blackColor]];
    [_distanceLabelStatic setAnchorPoint:ccp(1, 1)];
    [self addChild:_distanceLabelStatic z:1];
    
    //PAUSE
    CCButton *pauseButton = [CCButton buttonWithTitle:@"Pause"]; //creates pause button
    [pauseButton setTarget:self selector:@selector(pausePressed)]; //if pressed, run pausePressed
    [pauseButton setPosition:ccp(30,self.contentSize.height-10)]; //set position
    [pauseButton setLabelColor:[CCColor blackColor] forState:CCControlStateNormal]; //set color for unpressed state
    [self addChild:pauseButton z:1]; //add button to scene

    
    //BACKGROUND
    _background1 = [CCSprite spriteWithImageNamed:@"hallway2.png"]; //change this to change the background, make sure the size is the same as the current background of the new file when changing
    [_background1 setPosition:ccp(0, _ground1.boundingBox.size.height)];
    [_background1 setAnchorPoint:ccp(0, 0)];
    [_background1 setScaleX:0.25];
    [_background1 setScaleY:0.25];
    [_background1 setZOrder:-1];
    [_physicsNode addChild:_background1];
    
    _background2 = [CCSprite spriteWithImageNamed:@"hallway3.png"]; //change this to change the background, make sure the size is the same as the current background of the new file when changing
    [_background2 setPosition:ccp(_background1.boundingBox.size.width, _ground1.boundingBox.size.height)];
    [_background2 setAnchorPoint:ccp(0, 0)];
    [_background2 setScaleX:0.25];
    [_background2 setScaleY:0.25];
    [_background2 setZOrder:-1];
    [_physicsNode addChild:_background2];
    
    _background3 = [CCSprite spriteWithImageNamed:@"hallway3.png"]; //change this to change the background, make sure the size is the same as the current background of the new file when changing
    [_background3 setPosition:ccp((_background1.boundingBox.size.width*2), _ground1.boundingBox.size.height)];
    [_background3 setAnchorPoint:ccp(0, 0)];
    [_background3 setScaleX:0.25];
    [_background3 setScaleY:0.25];
    [_background3 setZOrder:-1];
    [_physicsNode addChild:_background3];
    
    _background4 = [CCSprite spriteWithImageNamed:@"hallway5.png"]; //change this to change the background, make sure the size is the same as the current background of the new file when changing
    [_background4 setPosition:ccp((_background1.boundingBox.size.width*3), _ground1.boundingBox.size.height)];
    [_background4 setAnchorPoint:ccp(0, 0)];
    [_background4 setScaleX:0.25];
    [_background4 setScaleY:0.25];
    [_background4 setZOrder:-1];
    [_physicsNode addChild:_background4];
    
    _background5 = [CCSprite spriteWithImageNamed:@"hallway4.png"]; //change this to change the background, make sure the size is the same as the current background of the new file when changing
    [_background5 setPosition:ccp((_background1.boundingBox.size.width*4), _ground1.boundingBox.size.height)];
    [_background5 setAnchorPoint:ccp(0, 0)];
    [_background5 setScaleX:0.25];
    [_background5 setScaleY:0.25];
    [_background5 setZOrder:-1];
    [_physicsNode addChild:_background5];
    
    _backgrounds = [[NSArray alloc]initWithObjects:_background1, _background2, _background3,_background4,_background5, nil];
    

    
    _grounds = [[NSArray alloc]initWithObjects:_ground1, _ground2, nil ];//allocate grounds array
    
    [self addChild:_physicsNode]; //add physics node to the scene

	return self;
}

-(void)pausePressed{
    [[CCDirector sharedDirector]pushScene:[Pause scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionDown duration:.5]]; //pause current scene, go to pause scene
}

BOOL intersects=NO; //initializes no intersection

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (_hero.position.y<30.0) { //checks if hero is on the ground before allowing it to jump. the hero is generally at 29.9 when on the ground, so hopefully this will always work
        [_hero.physicsBody applyImpulse:ccp(0, 600.f)]; //applies impulse to make the hero jump

    }else{
        if (hasDoubleJumped==NO && !(_hero.position.y>90 && intersects)) { //if player hasn't double jumped and is not on a table
            [_hero.physicsBody setVelocity:ccp(0, 0)]; //sets velocity to zero so impulse is accurately applied
            [_hero.physicsBody applyImpulse:ccp(0, 500.f)]; //applies impulse to make the hero jump
            hasDoubleJumped=YES; //broadcasts player has double jumped
        }
    }
    if (_hero.position.y>90 && intersects) { //if player is on table (above 90 and collisions cgrects overlap)
        [_hero.physicsBody applyImpulse:ccp(0, 600.f)]; //applies impulse to make the hero jump
        hasDoubleJumped=YES; //broadcasts player has double jumped
        intersects=NO; //resets intersection until changed by collision handler
    }
}

-(void)addFlyingObstacle{
    CCNode *_flyingObstacle = [[CCSprite alloc]initWithImageNamed:@"white-closed-book.png"]; //change this to change how the coin looks
    numberOfBooksDodged++;
    
    
    [_flyingObstacle setScaleY:.015];
    [_flyingObstacle setScaleX:.015];
    [_flyingObstacle setAnchorPoint:ccp(.5, .5)];
    
    _flyingObstacle.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:_flyingObstacle.contentSize.width/2-40 andCenter:ccp(_flyingObstacle.contentSize.width/2, _flyingObstacle.contentSize.height/2)];
    _flyingObstacle.physicsBody.collisionGroup = @"heroGroup";
    _flyingObstacle.physicsBody.collisionType = @"flyingObstacleType";
    _flyingObstacle.physicsBody.type=CCPhysicsBodyTypeStatic; //coins are static
    int minY = _ground1.boundingBox.size.height+30; //min is above the ground slightly
    int maxY = self.contentSize.height-_flyingObstacle.boundingBox.size.height-10;//max is below the top but in reach ofthe character jumping
    int rangeY = maxY - minY;
    int randomY = (arc4random() % rangeY) + minY;
    
    _flyingObstacle.position = CGPointMake(-1*_physicsNode.position.x+self.contentSize.width, randomY); //sets coin position off to the right at a random y location
    CCActionRotateBy *rotate = [[CCActionRotateBy alloc]initWithDuration:5 angle:360];
    CCActionRepeatForever *repeatingRotation = [CCActionRepeatForever actionWithAction:rotate];

    [_flyingObstacle runAction:repeatingRotation];

    [_flyingObstacles addObject:_flyingObstacle]; //adds coin to _coins so it can check for collisions
    if ([_flyingObstacles count]>30) { //if more than 30 coins
        [_flyingObstacles removeObjectAtIndex:0]; //delete from array
    }
    [_physicsNode addChild:_flyingObstacle]; //adds coin to physics node
    
}

-(void)addCoin{
    CCNode *_coin = [[CCSprite alloc]initWithImageNamed:@"coin2.png"]; //change this to change how the coin looks
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
    
    float coinNumber = (float)(arc4random() % 4)+3;
    for (int i=1; i<=coinNumber; i++) {
        CCNode *_coin;
        if (i == 1) {
            _coin = [[CCSprite alloc]initWithImageNamed:@"coin2.png"]; //change this to change how the coin looks
        } else {
            _coin = [[CCSprite alloc]initWithImageNamed:@"coin3.png"]; //change this to change how the coin looks
        }
        [_coin setScaleY:.040];
        [_coin setScaleX:.040];
        //float coinSize = 10; //this is uesed to calculate the coin position, or basically where it is placed on the screen, max and min
        [_coin setAnchorPoint:ccp(0, 0)];
        
        
        _coin.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:_coin.contentSize.width/2-40 andCenter:ccp(_coin.contentSize.width/2, _coin.contentSize.height/2)];
        _coin.physicsBody.collisionGroup = @"heroGroup";
        _coin.physicsBody.collisionType = @"coinType";
        
        _coin.physicsBody.type=CCPhysicsBodyTypeStatic; //coins are static
        
        _coin.position = CGPointMake(-1*_physicsNode.position.x+self.contentSize.width+i*_coin.contentSize.width*.04, randomY); //sets coin position off to the right at a random y location
        [_coins addObject:_coin]; //adds coin to _coins so it can check for collisions
        if ([_coins count]>30) { //if more than 30 coins
            [_coins removeObjectAtIndex:0]; //delete from array
        }
        [_physicsNode addChild:_coin]; //adds coin to physics node

    }
}


-(void)lost{
    NSString* path = [(NSString *) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"scoreSaves.plist"];
    NSMutableArray* Scores;
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NO]) {
        Scores = [NSMutableArray arrayWithContentsOfFile:path];
    }else{
        Scores = [NSMutableArray array];
    }
    
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    
    NSMutableDictionary* thisRun = [NSMutableDictionary dictionary];
    [thisRun setValue:[NSNumber numberWithInt:distance] forKey:@"distance"];
    [thisRun setValue:[NSNumber numberWithInt:score] forKey:@"coins"];
    [thisRun setValue:[NSDate date] forKey:@"time"];
    [thisRun setValue:[NSNumber numberWithInt:gameTime] forKeyPath:@"duration"];
    [thisRun setValue:[NSNumber numberWithInt:numberOfBooksDodged] forKeyPath:@"booksDodged"];
    
    
    NSArray* allKeys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
    BOOL totalCoinsExists = false;
    for (NSString* key in allKeys) {
        if ([key isEqualToString:@"totalCoins"]) {
            totalCoinsExists = true;
            break;
        }
    }
    if (!totalCoinsExists) {
        [defaults setValue:[NSNumber numberWithInt:score] forKey:@"totalCoins"];
    }else{
        [defaults setValue:[NSNumber numberWithInt:([[defaults objectForKey:@"totalCoins"] intValue]+score)] forKey:@"totalCoins"];
    }
    
    [Scores addObject:thisRun];
    NSMutableArray* defaultScores = [NSMutableArray arrayWithArray:[defaults objectForKey:@"saves"]];
    [defaultScores addObject:thisRun];
    [defaults setValue:defaultScores forKey:@"saves"];
    
    [defaults synchronize];
    [Scores writeToFile:path atomically:YES];
    
    [[CCDirector sharedDirector]presentScene:[Lose scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:.5]]; //go to lose scene
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
        [self lost];
    }
    if (_hero.position.y<30) {
        hasDoubleJumped=NO;
        intersects=NO;
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
    for (CCSprite *background in _backgrounds) {
        // get the world position of the ground
        CGPoint backgroundWorldPosition = [_physicsNode convertToWorldSpace:background.position];
        // get the screen position of the ground
        CGPoint backgroundScreenPosition = [self convertToNodeSpace:backgroundWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        
        if (backgroundScreenPosition.x <= (-1 * background.boundingBox.size.width)) { //DOES NOT WORK, NOT SURE WHY
            background.position = ccp(background.position.x + [_backgrounds count] * background.boundingBox.size.width, background.position.y);
            /*int from = 2;
            int to = 5;
            [background setSpriteFrame:[CCSpriteFrame frameWithImageNamed: [NSString stringWithFormat:@"hallway%i.png", (int)from + arc4random() % (to-from+1)]]];*/
            
        }
    }
    
    _coins2 = [_coins mutableCopy]; //makes copy of coins array
    
    for (CCNode *coin in _coins2) { //run everything below for each coin in array
        
        BOOL shouldRemove = NO; //will not remove coin unless changed below
        CGPoint coinWorldPosition = [_physicsNode convertToWorldSpace:coin.position];
        // get the screen position of the ground
        CGPoint coinScreenPosition = [self convertToNodeSpace:coinWorldPosition];
        
        if (coinScreenPosition.x<=(-1*coin.contentSize.width/2)) { //if coin is too far to the left
            shouldRemove=YES; //tells program to remove coin below
            
        }

        CGRect heroTempBoundingBox = CGRectInset(_hero.boundingBox, _hero.boundingBox.size.width/8, _hero.boundingBox.size.height/8);
        CGRect coinTempBoundingBox = CGRectInset(coin.boundingBox, coin.boundingBox.size.width/4, coin.boundingBox.size.height/4);

        if (CGRectIntersectsRect(heroTempBoundingBox, coinTempBoundingBox)) { //check if hero and coin collides
            
            shouldRemove=YES; //tells program to remove coin below
            [[OALSimpleAudio sharedInstance]playEffect:@"coincollection.mp3"];
            
            score++; //adds one to score
            [_coinCounterLabel setString:[NSString stringWithFormat:@"%i", score]]; //sets the label to cuurent score
        }
        
       
        
        if (shouldRemove) { //if above has told to remove
            [coin removeFromParent]; //removes from physics node
            [_coins removeObject:coin]; //removes from original coins array

        }
        
        
        
        distance = (int)_hero.position.x/10; //distance takes the negative integer of physics node position and divides it by 10 (to make it slower)
        [_distanceLabel setString:[NSString stringWithFormat:@"%i", distance]]; //sets the label to the current distance
    }
    
    //Obstacle Collisions
    
    for (CCNode *flyingObstacle in _flyingObstacles) {
        flyingObstacle.position = ccp(flyingObstacle.position.x - delta * (scrollSpeed/6), flyingObstacle.position.y); //keeps hero in line with the moving physics node
        CGRect heroTempBoundingBox = CGRectInset(_hero.boundingBox, _hero.boundingBox.size.width/8, _hero.boundingBox.size.height/8);
        CGRect flyingObstacleTempBoundingBox = CGRectInset(flyingObstacle.boundingBox, flyingObstacle.boundingBox.size.width/4, flyingObstacle.boundingBox.size.height/4);

        if (CGRectIntersectsRect(heroTempBoundingBox, flyingObstacleTempBoundingBox)) { //check if hero and coin collides
            
            [self lost];
        }

    }
    
    
    
    
}



//COLLISIONS


-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair groundType:(CCNode *)nodeA heroType:(CCNode *)nodeB{
    return YES;
}

@end
