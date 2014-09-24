//
//  CCParallaxScrollOffset.h v1.2
//
//  Created by Aram Kocharyan on 1/12/11
//  http://ak.net84.net/
//

#import "cocos2d.h"

@interface CCParallaxScrollOffset : NSObject {
	CGPoint scrollOffset, origPosition, relVelocity, ratio;
	CCNode *child;
	CGPoint buffer;
}
@property (nonatomic,assign) CGPoint scrollOffset, position, ratio;
@property (nonatomic,retain) CCNode *child;
@property (nonatomic,assign) CGPoint origPosition, currPosition, relVelocity;
@property (nonatomic,assign) CGPoint buffer;
+(id) scrollWithNode:(CCNode *)node Ratio:(CGPoint)r Pos:(CGPoint)p ScrollOffset:(CGPoint)s;
+(id) scrollWithNode:(CCNode *)node Ratio:(CGPoint)r Pos:(CGPoint)p ScrollOffset:(CGPoint)s RelVelocity:(CGPoint)v;
-(id) initWithNode:(CCNode *)node Ratio:(CGPoint)r Pos:(CGPoint)p ScrollOffset:(CGPoint)s RelVelocity:(CGPoint)v;
-(id) initWithNode:(CCNode *)node Ratio:(CGPoint)r Pos:(CGPoint)p ScrollOffset:(CGPoint)s;
@end
