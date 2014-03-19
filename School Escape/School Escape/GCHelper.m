//
//  GCHelper.m
//  School Escape
//
//  Created by Sudikoff Lab iMac on 3/18/14.
//  Copyright (c) 2014 Lordtechy. All rights reserved.
//

#import "GCHelper.h"

@implementation GCHelper
@synthesize gameCenterAvailable;
static GCHelper *sharedHelper=nil;

-(BOOL) isGameCenterAvailable {
    // Check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // Check of the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

-(id)init{
    if (self == [super init]) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
        }
    }
    return self;
}
-(void)authenticationChanged {
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        NSLog(@"Authenication changed: player authenticated.");
    }else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated){
        NSLog(@"Authenication changed: player not authenicated");
        userAuthenticated = false;
    }
}

- (void)showLeaderboardOnViewController:(UIViewController*)viewController //creates view controller
{
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init]; //creates gamecenter controller
    if (gameCenterController != nil) {
        gameCenterController.gameCenterDelegate = self;
        gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards; //state is leaderboards
        gameCenterController.leaderboardIdentifier = kLeaderboardID;
        
        [viewController presentViewController: gameCenterController animated: YES completion:nil]; //adds gamecenter controller to view controller
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController //when finished
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:^{ //dismiss all the controllers
        
    }];

}

#pragma mark User Functions

-(void)authenticateLocalUser{
    if (!gameCenterAvailable) return;
    
    NSLog(@"Authenicating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
    }else{
        NSLog(@"Already authenicated");
    }
}




# pragma mark Initialization
+ (GCHelper*)defaultHelper {
    // dispatch_once will ensure that the method is only called once (thread-safe)
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        sharedHelper = [[GCHelper alloc] init];
    });
    return sharedHelper;
}

@end
