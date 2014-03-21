//
//  AppDelegate.m
//  School Escape
//
//  Created by Max Greenwald on 3/15/14.
//  Copyright Lordtechy 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "AppDelegate.h"
#import "Menu.h"
#import "chipmunk.h"
#import "GCHelper.h"
#import "MKiCloudSync.h"

@implementation AppDelegate{
}



-(void)applicationWillEnterForeground:(UIApplication *)application{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* path = [(NSString *) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"scoreSaves.plist"];
        NSMutableArray* saves = [NSMutableArray arrayWithContentsOfFile:path];
        saves = [NSMutableArray arrayWithArray:[saves sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO], nil]]];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSArray* allKeys = [[defaults dictionaryRepresentation] allKeys];
        BOOL savesExists = false;
        for (NSString* key in allKeys) {
            if ([key isEqualToString:@"saves"]) {
                savesExists = true;
                break;
            }
        }
        if (!savesExists) {
            [defaults setValue:saves forKey:@"saves"];
        }else{
            NSArray* icloudScores = [NSArray arrayWithArray:[defaults objectForKey:@"saves"]];
            icloudScores = [icloudScores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO], nil]];
            
            NSMutableArray* combinedArray = [NSMutableArray arrayWithArray:saves];
            [combinedArray addObjectsFromArray:icloudScores];
            combinedArray = [NSMutableArray arrayWithArray:[combinedArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]]]];
            int i = 1;
            while (i<([combinedArray count])) {
                NSDate* targetDate = [[combinedArray objectAtIndex:i] objectForKey:@"time"];
                BOOL isEqualToPrevious = ([targetDate compare:[[combinedArray objectAtIndex:(i-1)] objectForKey:@"time"]]==NSOrderedSame);
                BOOL isEqualToNext = NO;
                if (i+1<[combinedArray count]) {
                    isEqualToNext = ([targetDate compare:[[combinedArray objectAtIndex:i+1] objectForKey:@"time"]]==NSOrderedSame);
                }
                if (isEqualToNext || isEqualToPrevious) {
                    [combinedArray removeObjectAtIndex:i];
                    i = i - 1;
                }
                i++;
            }
            saves = [NSMutableArray arrayWithArray:combinedArray];
            [saves writeToFile:path atomically:YES];
            saves = nil;
            icloudScores = [NSArray arrayWithArray:combinedArray];
            [defaults setValue:icloudScores forKey:@"saves"];
        }
        [defaults synchronize];
    });
}

// 
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// This is the only app delegate method you need to implement when inheriting from CCAppDelegate.
	// This method is a good place to add one time setup code that only runs when your app is first launched.
	
	// Setup Cocos2D with reasonable defaults for everything.
	// There are a number of simple options you can change.
	// If you want more flexibility, you can configure Cocos2D yourself instead of calling setupCocos2dWithOptions:.]
    //cpInitChipmunk();
    
    NSString* path2 = [(NSString *) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"hasOpened.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path2]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"iCloud?" message:@"Can School Escape use iCloud to sync your scores and coins?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
    }
    

    
    
    NSString* path = [(NSString *) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"scoreSaves.plist"];
    NSMutableArray* saves = [NSMutableArray arrayWithContentsOfFile:path];
    saves = [NSMutableArray arrayWithArray:[saves sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO], nil]]];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* allKeys = [[defaults dictionaryRepresentation] allKeys];
    BOOL savesExists = false;
    NSLog(@"AllKeys: %@", allKeys);
    for (NSString* key in allKeys) {
        if ([key isEqualToString:@"saves"]) {
            savesExists = YES;
            break;
        }
    }
    if (!savesExists) {
        [defaults setValue:saves forKey:@"saves"];
    }else{
        NSArray* icloudScores = [NSArray arrayWithArray:[defaults objectForKey:@"saves"]];
        icloudScores = [icloudScores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO], nil]];
        
        NSMutableArray* combinedArray = [NSMutableArray arrayWithArray:saves];
        [combinedArray addObjectsFromArray:icloudScores];
        combinedArray = [NSMutableArray arrayWithArray:[combinedArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]]]];
        int i = 1;
        while (i<([combinedArray count])) {
            NSDate* targetDate = [[combinedArray objectAtIndex:i] objectForKey:@"time"];
            BOOL isEqualToPrevious = ([targetDate compare:[[combinedArray objectAtIndex:(i-1)] objectForKey:@"time"]]==NSOrderedSame);
            BOOL isEqualToNext = NO;
            if (i+1<[combinedArray count]) {
                isEqualToNext = ([targetDate compare:[[combinedArray objectAtIndex:i+1] objectForKey:@"time"]]==NSOrderedSame);
            }
            if (isEqualToNext || isEqualToPrevious) {
                [combinedArray removeObjectAtIndex:i];
                i = i - 1;
            }
            i++;
        }
        saves = [NSMutableArray arrayWithArray:combinedArray];
        [saves writeToFile:path atomically:YES];
        saves = nil;
        icloudScores = [NSArray arrayWithArray:combinedArray];
        [defaults setValue:icloudScores forKey:@"saves"];
    }
    [defaults synchronize];
    
    NSURL* ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    if ([[NSDictionary dictionaryWithContentsOfFile:path2] objectForKey:@"canUseiCloud"]==[NSNumber numberWithBool:YES]) {
        [MKiCloudSync start];
    }
    if (ubiq) {
        NSLog(@"iCloud access at %@",ubiq);
    }else{
        NSLog(@"No iCloud access");
    }

	[self setupCocos2dWithOptions:@{
		// Show the FPS and draw call label.
		CCSetupShowDebugStats: @(YES),
		// More examples of options you might want to fiddle with:
		// (See CCAppDelegate.h for more information)
		
		// Use a 16 bit color buffer: 
//		CCSetupPixelFormat: kEAGLColorFormatRGB565,
		// Use a simplified coordinate system that is shared across devices.
//		CCSetupScreenMode: CCScreenModeFixed,
		// Run in portrait mode.
//		CCSetupScreenOrientation: CCScreenOrientationPortrait,
		// Run at a reduced framerate.
//		CCSetupAnimationInterval: @(1.0/30.0),
		// Run the fixed timestep extra fast.
//		CCSetupFixedUpdateInterval: @(1.0/180.0),
		// Make iPad's act like they run at a 2x content scale. (iPad retina 4x)
//		CCSetupTabletScale2X: @(YES),
	}];
	[[GCHelper defaultHelper] authenticateLocalUser];

    //[defaults setValue:@"backgroundMusic1.mp3" forKey:@"music"];
    [[OALSimpleAudio sharedInstance]playBg:[defaults valueForKey:@"music"] loop:YES];
    
	return YES;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSString* path2 = [(NSString *) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"hasOpened.plist"];
    NSMutableDictionary* hasOpened =[NSMutableDictionary dictionary];
    if (buttonIndex==1) {
        [hasOpened setValue:[NSNumber numberWithBool:YES] forKey:@"canUseiCloud"];
    }
    [hasOpened writeToFile:path2 atomically:YES];
    //[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

-(CCScene *)startScene
{
	// This method should return the very first scene to be run when your app starts.
    //cpInitChipmunk();

	return [Menu scene];
}

@end
