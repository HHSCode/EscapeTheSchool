//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene

-(void)play{
    NSLog(@"Play");
    CCScene *gameScene = [CCBReader loadAsScene:@"Game"];
    [[CCDirector sharedDirector] replaceScene:gameScene];
}

-(void)about{
    NSLog(@"About");
    CCScene *aboutScene = [CCBReader loadAsScene:@"About"];
    [[CCDirector sharedDirector] replaceScene:aboutScene];
}

-(void)settings{
    NSLog(@"Settings");
    CCScene *settingsScene = [CCBReader loadAsScene:@"Settings"];
    [[CCDirector sharedDirector] replaceScene:settingsScene];
}

-(void)store{
    NSLog(@"Store");
    CCScene *storeScene = [CCBReader loadAsScene:@"Store"];
    [[CCDirector sharedDirector] replaceScene:storeScene];

    
}


@end
