/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "MyScene.h"

@implementation MyScene

-(id) initWithSize:(CGSize)size
{
	self = [super initWithSize:size];
	if (self)
	{
		/* Setup your scene here */
		NSString* tmxFile = @"tile.tmx";
        KKTilemapNode* tilemapNode = [KKTilemapNode tilemapWithContentsOfFile:tmxFile];
        [self addChild:tilemapNode];
        NSLog(@"tilemap Loaded");
		
	}
	return self;
}




#if TARGET_OS_IPHONE // iOS
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	/* Called when a touch begins */
	
	for (UITouch* touch in touches)
	{
		//CGPoint location = [touch locationInNode:self];
			}
	
	// (optional) call super implementation to allow KKScene to dispatch touch events
	[super touchesBegan:touches withEvent:event];
}
#else // Mac OS X
-(void) mouseDown:(NSEvent *)event
{
	/* Called when a mouse click occurs */
	
	CGPoint location = [event locationInNode:self];
	

	// (optional) call super implementation to allow KKScene to dispatch mouse events
	[super mouseDown:event];
}
#endif

-(void) update:(CFTimeInterval)currentTime
{
	/* Called before each frame is rendered */
	
	// (optional) call super implementation to allow KKScene to dispatch update events
	[super update:currentTime];
}

@end
