//
//  Store.m
//  School Escape
//
//  Created by Max Greenwald on 3/15/14.
//  Copyright 2014 Lordtechy. All rights reserved.
//

#import "Store.h"


@implementation Store
+ (Store *)scene
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
    
    NSString* path = [(NSString *) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"scoreSaves.plist"];
    
    NSArray* Scores;
    Scores = [NSArray arrayWithContentsOfFile:path];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    CCButton *menuButton = [CCButton buttonWithTitle:@"< Back"];
    [menuButton setTarget:self selector:@selector(menuPressed)];
    CCButton *buyButton = [CCButton buttonWithTitle:@"Buy for 10 coins"];
    [buyButton setTarget:self selector:@selector(buyPressed)];
    CCLabelTTF *spacingLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@""] fontName:@"Marker Felt" fontSize:20];
    CCLabelTTF *totalCoinLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Total Coins: %@",[defaults objectForKey:@"totalCoins"]] fontName:@"Marker Felt" fontSize:20];
    
    CCLayoutBox *storeLayoutBox = [[CCLayoutBox alloc]init];
    [storeLayoutBox setAnchorPoint:ccp(0.5, 0.5)];
    [storeLayoutBox addChild:menuButton];
    [storeLayoutBox addChild:buyButton];
    [storeLayoutBox addChild:spacingLabel];
    [storeLayoutBox addChild:totalCoinLabel];
    
    [storeLayoutBox setSpacing:10.f];
    [storeLayoutBox setDirection:CCLayoutBoxDirectionVertical];
    [storeLayoutBox setPosition:ccp(self.contentSize.width/2, self.contentSize.height/2)];
    [self addChild:storeLayoutBox];
    
    
    // done
	return self;
}

-(void)menuPressed{
    [[CCDirector sharedDirector]presentScene:[Menu scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:.5]];
    
}

-(void)buyPressed{
    NSString* path = [(NSString *) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"scoreSaves.plist"];
    
    
    NSArray* theScore=[[NSArray arrayWithContentsOfFile:path] sortedArrayUsingDescriptors:[NSMutableArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO], nil]];
    
    NSMutableArray *scores = [theScore mutableCopy];
    
    if ([[[scores objectAtIndex:0] objectForKey:@"totalcoins"] intValue]>=10) {
        UIAlertView *buyAlert = [[UIAlertView alloc]initWithTitle:@"Success!" message:@"Bought nothing for 10 coins!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [buyAlert show];
        NSMutableDictionary* updateCoins = [NSMutableDictionary dictionary];
        [updateCoins setValue:[NSNumber numberWithInt:0] forKey:@"distance"];
        [updateCoins setValue:[NSNumber numberWithInt:0] forKey:@"coins"];
        [updateCoins setValue:[NSDate date] forKey:@"time"];
        [updateCoins setValue:[NSNumber numberWithInt:[[[scores objectAtIndex:0]objectForKey:@"totalcoins"]intValue] - 10] forKey:@"totalcoins"];
        [scores addObject:updateCoins];
        
        [scores writeToFile:path atomically:YES];
    } else {
        UIAlertView *failAlert = [[UIAlertView alloc]initWithTitle:@"Failure!" message:@"Not enough coins!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [failAlert show];
    }
    
}

@end
