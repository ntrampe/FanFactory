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

#import "PackSelectionScene.h"
#import "PackController.h"
#import "PackCell.h"
#import "nt_button.h"
#import "nt_alertview_stretchable.h"

@implementation PackSelectionScene
@synthesize delegate = _delegate;

+ (CCScene *) scene
{
  CCScene *scene = [CCScene node];
	
	PackSelectionScene * layer = [PackSelectionScene node];
  
  [scene addChild:layer];
	
	return scene;
}

- (id)init
{
  self = [super init];
  if (self) 
  {
    sharedPC = [PackController sharedPackController];
    
    m_scrollLayer = [[nt_scrollSelectionLayer alloc] init];
    m_scrollLayer.selectionDelegate = self;
    m_scrollLayer.scrollY = NO;
    [self addChild:m_scrollLayer];
    [m_scrollLayer setBounds:CGSizeMake(self.screenSize.width, self.screenSize.height*4)];
    
    m_packNumber = -1;
    
    [self scheduleUpdate];
  }
  return self;
}


- (void)dealloc
{
  if (m_levels != nil)
  {
    [m_levels release];
    m_levels = nil;
  }
  [m_scrollLayer release];
  [super dealloc];
}


- (void)onEnterTransitionDidFinish
{
  [super onEnterTransitionDidFinish];
  
  if (m_packNumber != -1)
  {
    if (m_packNumber != sharedPC.currentPackNumber)
    {
      if (m_levels != nil)
      {
        [self callBlock:^{
          [m_levels updateWithPack:[sharedPC currentPack]];
        } afterDelay:0.5f];
      }
    }
  }
}


- (void)goToPack:(int)aPack
{
  if (sharedPC.highestAvailablePack < aPack)
    return;
  
  m_packNumber = aPack;
  [sharedPC setCurrentPack:aPack];
  
  if (m_levels != nil)
  {
    if (m_levels.parent != nil)
      [m_levels removeFromParentAndCleanup:YES];
    [m_levels release];
    m_levels = nil;
  }
  
  m_levels = [[LevelSelectionScene alloc] initWithPack:[sharedPC currentPack]];
  m_levels.position = CGPointMake(0, -m_levels.contentSize.height);
  [self addChild:m_levels];
  [m_levels runAction:[CCEaseBackOut actionWithAction:[CCMoveTo actionWithDuration:0.5f position:CGPointMake(0, 0)]]];
//  [m_levels fadeIn];

  [m_scrollLayer runAction:[CCEaseBackOut actionWithAction:[CCMoveTo actionWithDuration:0.5f position:CGPointMake(m_scrollLayer.position.x, m_scrollLayer.contentSize.height)]]];
  m_scrollLayer.isTouchEnabled = NO;
  m_scrollLayer.isBounded = NO;
  m_scrollLayer.bounces = NO;
  
  if ([self.delegate respondsToSelector:@selector(packSelection:didSelectPack:)])
    [self.delegate packSelection:self didSelectPack:aPack];
}


- (void)returnToPacks
{
  [m_levels runAction:[CCEaseBackOut actionWithAction:[CCMoveTo actionWithDuration:0.5f position:CGPointMake(0, -m_levels.contentSize.height)]]];
  [m_levels fadeOut];
  
  [m_scrollLayer runAction:[CCEaseBackOut actionWithAction:[CCMoveTo actionWithDuration:0.5f position:CGPointMake(m_scrollLayer.position.x, 0)]]];
  m_scrollLayer.isTouchEnabled = YES;
  m_scrollLayer.isBounded = YES;
  m_scrollLayer.bounces = YES;
  
  if ([self.delegate respondsToSelector:@selector(packSelectionDidReturnToPacks:)])
    [self.delegate packSelectionDidReturnToPacks:self];
}


- (void)update:(ccTime)dt
{
  self.velocity = m_scrollLayer.velocity;
}


- (void)selectionLayer:(nt_scrollSelectionLayer *)selectionLayer didSelectCell:(nt_scrollSelectionCell *)cell atIndex:(NSInteger)index
{
  if (index != [sharedPC.packs count])
  {
    [self goToPack:index];
  }
  else
  {
    nt_alertview_stretchable * alert = [[nt_alertview_stretchable alloc] initWithMessage:@"More packs will be coming soon, but donating will speed up the process!\nYou can donate by buying coins in the in-game store." stretchableImageNamed:@"stretch_container.png" bottomOffset:0 delegate:nil];
    [alert setTextColor:ccWHITE];
    [alert show];
    [alert release];
  }
}


- (CGFloat)selectionLayerWidthOffset:(nt_scrollSelectionLayer *)selectionLayer
{
  return 50;
}


- (NSInteger)numberOfCellsInSelectionLayer:(nt_scrollSelectionLayer *)selectionLayer
{
  return [sharedPC.packs count] + 1;
}


- (BOOL)cellEnabledForIndex:(NSInteger)index
{
  return (index <= sharedPC.highestAvailablePack || index == [sharedPC.packs count]);
}


- (nt_scrollSelectionCell *)selectionLayer:(nt_scrollSelectionLayer *)selectionLayer cellForIndex:(NSInteger)index
{
  PackCell * cell = [[PackCell alloc] initWithPack:[sharedPC packForNumber:index]];
  
  if (index == sharedPC.packs.count)
  {
    [cell makeComingSoon];
  }
  
  return cell;
}


@end
