//
//  Store.m
//  School Escape
//
//  Created by Max Greenwald on 3/15/14.
//  Copyright 2014 Lordtechy. All rights reserved.
//

#import "Store.h"
#import "IAPHelper.h"

@implementation Store{
    IAPHelper* helper;
    NSArray* products;
}
+ (Store *)scene
{
    return [[self alloc] init];
}

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    products = nil;
    helper = [[IAPHelper alloc] init];
    [helper requestProductData];
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    NSString* path = [(NSString *) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"scoreSaves.plist"];
    
    NSArray* Scores;
    Scores = [NSArray arrayWithContentsOfFile:path];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    CCButton *menuButton = [CCButton buttonWithTitle:@"< Back" fontName:@"Marker Felt" fontSize:14];
    [menuButton setTarget:self selector:@selector(menuPressed)];
    CCButton *buy10Button = [CCButton buttonWithTitle:@"Buy nothing for 10 coins" fontName:@"Marker Felt" fontSize:18];
    [buy10Button setTarget:self selector:@selector(buy10Pressed)];
    CCButton *buy100Button = [CCButton buttonWithTitle:@"Buy \"You\'re Time\" for 100 coins" fontName:@"Marker Felt" fontSize:18];
    [buy100Button setTarget:self selector:@selector(buy100Pressed)];
    CCLabelTTF *spacingLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@""] fontName:@"Marker Felt" fontSize:18];
    CCLabelTTF *totalCoinLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Total Coins: %@",[defaults objectForKey:@"totalCoins"]] fontName:@"Marker Felt" fontSize:24];
    
    CCLayoutBox *storeLayoutBox = [[CCLayoutBox alloc]init];
    [storeLayoutBox setAnchorPoint:ccp(0.5, 0.5)];
    [storeLayoutBox addChild:menuButton];
    [storeLayoutBox addChild:buy100Button];
    [storeLayoutBox addChild:buy10Button];
    [storeLayoutBox addChild:spacingLabel];
    [storeLayoutBox addChild:totalCoinLabel];
    
    [storeLayoutBox setSpacing:10.f];
    [storeLayoutBox setDirection:CCLayoutBoxDirectionVertical];
    [storeLayoutBox setPosition:ccp(self.contentSize.width/2, self.contentSize.height/2)];
    [self addChild:storeLayoutBox];
    
    if ([helper getProductData]!=nil) {
        products = [helper getProductData];
    }else{
        [self schedule:@selector(checkProducts) interval:0.5];
    }
    
    // done
	return self;
}

-(void)checkProducts{
    if ([helper getProductData]!=nil) {
        products = [helper getProductData];
        [self unschedule:@selector(checkProducts)];
    }
}

-(void)menuPressed{
    [[CCDirector sharedDirector]presentScene:[Menu scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:.5]];
    
}

-(void)buy10Pressed{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults objectForKey:@"totalCoins"] intValue]>=10) {
        UIAlertView *buyAlert = [[UIAlertView alloc]initWithTitle:@"Success!" message:@"Bought nothing for 10 coins!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [buyAlert show];
        [defaults setValue:[NSNumber numberWithInt:([[defaults objectForKey:@"totalCoins"] intValue]-10)] forKey:@"totalCoins"];
        [[CCDirector sharedDirector]presentScene:[Store scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:.5]];
    } else {
        UIAlertView *failAlert = [[UIAlertView alloc]initWithTitle:@"Failure!" message:@"Not enough coins!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [failAlert show];
    }
    
}

-(void)buy100Pressed{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults objectForKey:@"totalCoins"] intValue]>=100) {
        UIAlertView *buyAlert = [[UIAlertView alloc]initWithTitle:@"Success!" message:@"Bought \"You\'re Time\" for 100 coins!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [buyAlert show];
        [defaults setValue:[NSNumber numberWithInt:([[defaults objectForKey:@"totalCoins"] intValue]-100)] forKey:@"totalCoins"];
        [[OALSimpleAudio sharedInstance]playBg:@"you'retime.mp3" loop:YES];
        [[CCDirector sharedDirector]presentScene:[Store scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:.5]];
        
    } else {
        UIAlertView *failAlert = [[UIAlertView alloc]initWithTitle:@"Failure!" message:@"Not enough coins!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [failAlert show];
    }
    
}

@end
