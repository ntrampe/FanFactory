/*
 * Copyright (c) 2014 Nicholas Trampe
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

#import "ParallaxBackground.h"
#import "GameLayer.h"

@interface ParallaxBackground (Private)

- (float)randomValueBetween:(float)low andValue:(float)high;

@end

@implementation ParallaxBackground

- (id)init
{
  self = [super init];
  if (self) 
  { 
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    CCSprite * box1 = [[CCSprite alloc] initWithFile:@"boxes_front.png"];
		CCSprite * box2 = [[CCSprite alloc] initWithFile:@"boxes_front.png"];
    CCSprite * box3 = [[CCSprite alloc] initWithFile:@"boxes_front.png"];
    CCSprite * box4 = [[CCSprite alloc] initWithFile:@"boxes_front.png"];
    CCSprite * box5 = [[CCSprite alloc] initWithFile:@"boxes_front.png"];
		
    CCSprite * light1 = [[CCSprite alloc] initWithFile:@"light.png"];
		CCSprite * light2 = [[CCSprite alloc] initWithFile:@"light.png"];
    CCSprite * light3 = [[CCSprite alloc] initWithFile:@"light.png"];
    CCSprite * light4 = [[CCSprite alloc] initWithFile:@"light.png"];
		
		CCSprite * box6 = [[CCSprite alloc] initWithFile:@"boxes_back.png"];
		CCSprite * box7 = [[CCSprite alloc] initWithFile:@"boxes_back.png"];
    CCSprite * box8 = [[CCSprite alloc] initWithFile:@"boxes_back.png"];
    CCSprite * box9 = [[CCSprite alloc] initWithFile:@"boxes_back.png"];
    CCSprite * box10 = [[CCSprite alloc] initWithFile:@"boxes_back.png"];
    
    CCSprite * wind1 = [[CCSprite alloc] initWithFile:@"window.png"];
    CCSprite * wind2 = [[CCSprite alloc] initWithFile:@"window.png"];
    CCSprite * wind3 = [[CCSprite alloc] initWithFile:@"window.png"];
    CCSprite * wind4 = [[CCSprite alloc] initWithFile:@"window.png"];
    CCSprite * wind5 = [[CCSprite alloc] initWithFile:@"window.png"];
    CCSprite * wind6 = [[CCSprite alloc] initWithFile:@"window.png"];
    
    BOOL isPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    
    [self addInfiniteScrollXWithZ:0   Ratio:ccp(0.5,0.25)   Pos:ccp(-box1.contentSize.width, 0)                                       Objects:box1, box2, box3, box4, box5, nil];
    [self addInfiniteScrollXWithZ:-1  Ratio:ccp(0.15,0.1)   Pos:ccp(0, size.height - light1.contentSize.height/(isPad ? 2.0f : 4.0f)) Objects:light1, light2, light3, light4, nil];
    [self addInfiniteScrollXWithZ:-2  Ratio:ccp(0.1,0.02)   Pos:ccp(0,60)                                                             Objects:box6, box7, box8, box9, box10, nil];
    [self addInfiniteScrollXWithZ:-3  Ratio:ccp(0.08,0.02)  Pos:ccp(20, size.height/2.0f - (isPad ? wind1.contentSize.height : 0))    Objects:wind1, wind2, wind3, wind4, wind5, wind6, nil];
    
    [box1 release];
    [box2 release];
    [box3 release];
    [box4 release];
    [box5 release];
    [light1 release];
    [light2 release];
    [light3 release];
    [light4 release];
    [box6 release];
    [box7 release];
    [box8 release];
    [box9 release];
    [box10 release];
    [wind1 release];
    [wind2 release];
    [wind3 release];
    [wind4 release];
    [wind5 release];
    [wind6 release];
    
    self.range = CGSizeMake(size.width*2, size.height*2);
  }
  return self;
}


- (void)dealloc
{
  
  [super dealloc];
}


- (void)updateWithGameLayer:(GameLayer *)aGameLayer delta:(ccTime)aDelta
{
  [self updateWithVelocity:CGPointMake(aGameLayer.velocity.x, 0) AndDelta:aDelta];
  [self updateWithYPosition:(aGameLayer.scale-1)*200 AndDelta:aDelta];
}


- (void)addGameObjects
{
  //NSArray * names = [NSArray arrayWithObjects:@"block_long_small.png", @"block_long_large.png", @"block_square_small.png", @"block_square_large.png", @"block_triangle_hole.png", @"block_triangle_whole.png", @"block_circle.png", @"coin.png", nil];
  CGSize size = self.range;
  CGPoint ratio = ccp(0.6,0.25);
  CGPoint scrollOffset = ccp(size.width + 200, 0);
  float width = 0;
  
  for (int x = 0; x < 4; x++)
  {
    CCSprite * square = [CCSprite spriteWithSpriteFrameName:@"block_square_large.png"];
    
    [self addChild:square z:1 Ratio:ratio Pos:ccp(100, 30 + square.contentSize.height*x) ScrollOffset:scrollOffset];
  }
  
  for (int x = 0; x < 2; x++)
  {
    CCSprite * square = [CCSprite spriteWithSpriteFrameName:@"block_square_large.png"];
    
    [self addChild:square z:1 Ratio:ratio Pos:ccp(700 + square.contentSize.width*x, 30) ScrollOffset:scrollOffset];
  }
  
  CCSprite * topSquare = [CCSprite spriteWithSpriteFrameName:@"block_square_large.png"];
  [self addChild:topSquare z:1 Ratio:ratio Pos:ccp(700 + topSquare.contentSize.width/2.0f, 30 + topSquare.contentSize.height) ScrollOffset:scrollOffset];
  
  CCSprite * coin = [CCSprite spriteWithSpriteFrameName:@"coin.png"];
  [self addChild:coin z:1 Ratio:ratio Pos:ccp(700 + topSquare.contentSize.width/2.0f, 30 + topSquare.contentSize.height*4) ScrollOffset:scrollOffset];
  
//  CCSprite * fan1 = [CCSprite spriteWithSpriteFrameName:@"fan_1.png"];
//  [self addChild:fan1 z:1 Ratio:ratio Pos:ccp(350, 30) ScrollOffset:scrollOffset];
//  
//  CCSprite * fan2 = [CCSprite spriteWithSpriteFrameName:@"fan_1.png"];
//  [self addChild:fan2 z:1 Ratio:ratio Pos:ccp(950, 30) ScrollOffset:scrollOffset];
  
  while (width < scrollOffset.x)
  {
    CCSprite * large = [CCSprite spriteWithSpriteFrameName:@"block_long_large.png"];
    
    [self addChild:large z:1 Ratio:ratio Pos:ccp(width, 20) ScrollOffset:scrollOffset];
    width += large.contentSize.width;
  }
}


- (float)randomValueBetween:(float)low andValue:(float)high
{
  return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}


@end
