//
//  CCParallaxScrollNode.m v1.2
//
//  Created by Aram Kocharyan on 1/12/11
//  http://ak.net84.net/
//

#import "CCParallaxScrollNode.h"

#ifndef PTM_RATIO
	#define PTM_RATIO 32
#endif

#ifndef SIGN
	#define SIGN(x) ((x < 0) ? -1 : (x > 0))
#endif

@implementation CCParallaxScrollNode

@synthesize scrollOffsets, batch, range;

-(id) init {
	if ( (self=[super init]) ) {
		scrollOffsets = ccArrayNew(5);
		CGSize screen = [CCDirector sharedDirector].winSize;
		range = CGSizeMake(screen.width, screen.height);
		self.anchorPoint = ccp(0,0);
	}
	return self;
}

// Uses a CCSpriteBatchNode for your parallax sprites
+(id) makeWithBatchFile:(NSString *)file {
	// todo Merge in with batch pool?
	CCParallaxScrollNode *parallax = [self node];
	parallax.batch = [CCSpriteBatchNode batchNodeWithFile: [NSString stringWithFormat:@"%@.png", file]];
	[parallax addChild:parallax.batch];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: [NSString stringWithFormat:@"%@.plist", file]];
	return parallax;
}

// Used with box2d style velocity (m/s where m = 32 pixels), but box2d is not required
-(void) updateWithVelocity:(CGPoint)vel AndDelta:(ccTime)dt {
	vel = ccpMult(vel, PTM_RATIO);
	
	for (int i=0; i < scrollOffsets->num; i++) {
		CCParallaxScrollOffset *scrollOffset = scrollOffsets->arr[i];
		CCNode *child = scrollOffset.child;
		
		CGPoint relVel = ccpMult(scrollOffset.relVelocity, PTM_RATIO);
		CGPoint totalVel = ccpAdd(vel, relVel);
		CGPoint offset = ccpCompMult(ccpMult(totalVel, dt), scrollOffset.ratio);

		child.position = ccpAdd(child.position, offset);
		
		if ( (offset.x < 0 && child.position.x + child.contentSize.width < 0) ||
			 (offset.x > 0 && child.position.x > range.width) ) {
			child.position = ccpAdd(child.position, ccp(-SIGN(offset.x) * fabs(scrollOffset.scrollOffset.x), 0));
		}
		
		// Positive y indicates upward movement in cocos2d
		if ( (offset.y < 0 && child.position.y + child.contentSize.height < 0) ||
			(offset.y > 0 && child.position.y > range.height) ) {
			child.position = ccpAdd(child.position, ccp(0, -SIGN(offset.y) * fabs(scrollOffset.scrollOffset.y)));
		}
	}
}

/* Independent function to move parallax sprites up and down without the use of Y velocity, which could
lead to divergence from an initial Y position for the parallax (eg. ground) if the object starts in free fall etc. */
-(void) updateWithYPosition:(float)y AndDelta:(ccTime)dt {	
	for (int i=scrollOffsets->num - 1; i >= 0; i--) {
		CCParallaxScrollOffset *scrollOffset = scrollOffsets->arr[i];
		CCNode *child = scrollOffset.child;
		float offset = y * scrollOffset.ratio.y;
		child.position = ccp(child.position.x, scrollOffset.origPosition.y + offset);
	}
}

-(void) addChild:(CCSprite *)node z:(NSInteger)z Ratio:(CGPoint)r Pos:(CGPoint)p ScrollOffset:(CGPoint)s RelVelocity:(CGPoint)v {
	node.anchorPoint = ccp(0,0);
	CCParallaxScrollOffset *obj = [CCParallaxScrollOffset scrollWithNode:node Ratio:r Pos:p ScrollOffset:s RelVelocity:v];
	ccArrayAppendObjectWithResize(scrollOffsets, obj);
	if (batch) {
		[batch addChild:node z:z];
	} else {
		[self addChild:node z:z];
	}
}

-(void) addChild:(CCSprite *)node z:(NSInteger)z Ratio:(CGPoint)r Pos:(CGPoint)p ScrollOffset:(CGPoint)s {
	[self addChild:node z:z Ratio:r Pos:p ScrollOffset:s RelVelocity:ccp(0,0)];
}

-(void) removeChild:(CCSprite*)node cleanup:(BOOL)cleanup {
	for (int i=0; i < scrollOffsets->num; i++) {
		CCParallaxScrollOffset *scrollOffset = scrollOffsets->arr[i];
		if( [scrollOffset.child isEqual:node] ) {
			ccArrayRemoveObjectAtIndex(scrollOffsets, i);
			break;
		}
	}
	if (batch) {
		[batch removeChild:node cleanup:cleanup];
	}
}

-(void) removeAllChildrenWithCleanup:(BOOL)cleanup {
	ccArrayRemoveAllObjects(scrollOffsets);
	if (batch) {
		[batch removeAllChildrenWithCleanup:cleanup];
	}
}

// This is the base helper method which prepares your sprites for infinite parallax (hence, infinite fun).
-(void) addInfiniteScrollWithObjects:(CCArray*)objects Z:(NSInteger)z Ratio:(CGPoint)ratio Pos:(CGPoint)pos Dir:(CGPoint)dir RelVelocity:(CGPoint)relVel Padding:(CGPoint)padding {
	// NOTE: corrects for 1 pixel at end of each sprite to avoid thin lines appearing
	
	// Calculate total width and height
	float totalWidth = 0;
	float totalHeight = 0;
	for (int i = 0; i < objects.count; i++) {
		CCSprite *object = (CCSprite *)[objects objectAtIndex:i];
		totalWidth += object.contentSize.width + dir.x * padding.x;
		totalHeight += object.contentSize.height + dir.y * padding.y;
	}

	// Position objects, add to parallax
	CGPoint currPos = pos;
	for (int i = 0; i < objects.count; i++) {
		CCSprite *object = (CCSprite *)[objects objectAtIndex:i];
		[self addChild:object z:z Ratio:ratio Pos:currPos ScrollOffset:ccp(totalWidth, totalHeight) RelVelocity:relVel];
		CGPoint nextPosOffset = ccp(dir.x * (object.contentSize.width + padding.x), dir.y * (object.contentSize.height + padding.y));
		currPos = ccpAdd(currPos, nextPosOffset);
	}
}

-(void) addInfiniteScrollWithObjects:(CCArray*)objects Z:(NSInteger)z Ratio:(CGPoint)ratio Pos:(CGPoint)pos Dir:(CGPoint)dir RelVelocity:(CGPoint)relVel {
	[self addInfiniteScrollWithObjects:objects Z:z Ratio:ratio Pos:pos Dir:dir RelVelocity:relVel Padding:ccp(-1,-1)];
}

-(void) addInfiniteScrollWithObjects:(CCArray*)objects Z:(NSInteger)z Ratio:(CGPoint)ratio Pos:(CGPoint)pos Dir:(CGPoint)dir {
	[self addInfiniteScrollWithObjects:objects Z:z Ratio:ratio Pos:pos Dir:dir RelVelocity:ccp(0,0)];
}

-(void) addInfiniteScrollWithZ:(NSInteger)z Ratio:(CGPoint)ratio Pos:(CGPoint)pos Dir:(CGPoint)dir Objects:(CCSprite*)firstObject, ... {
	va_list args;
    va_start(args, firstObject);
	
	CCArray* argArray = [CCArray arrayWithCapacity:2];
	for (CCSprite *arg = firstObject; arg != nil; arg = va_arg(args, CCSprite*)) {
		[argArray addObject:arg];
	}
	va_end(args);
	
	[self addInfiniteScrollWithObjects:argArray Z:z Ratio:ratio Pos:pos Dir:dir];
}

-(void) addInfiniteScrollXWithZ:(NSInteger)z Ratio:(CGPoint)ratio Pos:(CGPoint)pos Objects:(CCSprite*)firstObject, ... {
	va_list args;
    va_start(args, firstObject);
	
	CCArray* argArray = [CCArray arrayWithCapacity:2];
	for (CCSprite *arg = firstObject; arg != nil; arg = va_arg(args, CCSprite*)) {
		[argArray addObject:arg];
	}
	va_end(args);
	
	[self addInfiniteScrollWithObjects:argArray Z:z Ratio:ratio Pos:pos Dir:ccp(1,0)];
}

-(void) addInfiniteScrollYWithZ:(NSInteger)z Ratio:(CGPoint)ratio Pos:(CGPoint)pos Objects:(CCSprite*)firstObject, ... {
	va_list args;
    va_start(args, firstObject);
	
	CCArray* argArray = [CCArray arrayWithCapacity:2];
	for (CCSprite *arg = firstObject; arg != nil; arg = va_arg(args, CCSprite*)) {
		[argArray addObject:arg];
	}
	va_end(args);
	
	[self addInfiniteScrollWithObjects:argArray Z:z Ratio:ratio Pos:pos Dir:ccp(0,1)];
}

- (void) dealloc {
	if (scrollOffsets) {
		ccArrayFree(scrollOffsets);
		scrollOffsets = nil;
	}
	[super dealloc];
}

@end
