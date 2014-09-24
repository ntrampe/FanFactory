/*
 * Copyright (c) 2013 Nicholas Trampe
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

#import "nt_pagedLayer.h"
#import "CCGL.h"

@implementation nt_pagedLayer

+ (id)nodeWithLayers:(NSArray *)aLayers widthOffset:(int)aWidthOffset
{
  return [[[self alloc] initWithLayers:aLayers widthOffset:aWidthOffset] autorelease];
}


- (id)initWithLayers:(NSArray *)aLayers widthOffset:(int)aWidthOffset
{
  self = [super init];
  if (self) 
  {
    m_layers = [[NSMutableArray alloc] initWithArray:aLayers copyItems:NO];
    self.pagesWidthOffset = aWidthOffset;
    self.minimumTouchLengthToSlide = 30.0f;
		self.minimumTouchLengthToChangePage = 100.0f;
		self.showPagesIndicator = YES;
    self.scrollY = NO;
    self.bounces = YES;
		self.pagesIndicatorPosition = ccp(0.5f * self.contentSize.width, ceilf ( self.contentSize.height / 8.0f ));
    m_currentScreen = 0;
    [self updatePages];
  }
  return self;
}


- (void)dealloc
{
  [m_layers release];
  [super dealloc];
}


#pragma mark -
#pragma mark Page Management


- (int)numberOfLayers
{
  return m_layers.count;
}


- (void)updatePages
{
  for (int x = 0; x < m_layers.count; x++)
  {
    CCLayer * l = [m_layers objectAtIndex:x];
    l.anchorPoint = CGPointMake(0, 0);
		l.contentSize = self.screenSize;
		l.position = CGPointMake((x * (self.contentSize.width - self.pagesWidthOffset)), 0);
		if (!l.parent)
			[self addChild:l];
  }
  m_bounds = CGSizeMake(m_layers.count * (self.contentSize.width - self.pagesWidthOffset) + self.pagesWidthOffset, self.screenSize.height);
}


- (void)addPage:(CCLayer *)aPage withNumber:(int)aPageNumber
{
  if (aPageNumber >= 0 && aPageNumber < [m_layers count])
  {
    [m_layers insertObject:aPage atIndex:aPageNumber];
    [self updatePages];
  }
}


- (void)addPage:(CCLayer *)aPage
{
  [self addPage:aPage withNumber:m_layers.count];
}


- (void)removePage:(CCLayer *)aPage
{
  [m_layers removeObject:aPage];
  [self removeChild:aPage cleanup:YES];
  [self updatePages];
}


- (void)removePageWithNumber:(int)aPageNumber
{
  if (aPageNumber >= 0 && aPageNumber < [m_layers count])
  {
    [self removePage:[m_layers objectAtIndex:aPageNumber]];
  }
}


- (int)pageNumberForPosition:(CGPoint)aPosition
{
  CGFloat pageWidth = self.contentSize.width;
  int page = floor((self.pagesWidthOffset - pageWidth / 2) / pageWidth) + 1;
  return page;
}


- (CGPoint)positionForPageWithNumber:(int)aPageNumber
{
  return CGPointMake(-aPageNumber * (self.contentSize.width - self.pagesWidthOffset), 0.0f);
}


- (void)moveToPage:(int)aPage animated:(BOOL)isAnimated
{
  [self stopAllActions];
  [self scrollToPosition:[self positionForPageWithNumber:aPage] inTime:(isAnimated ? 0.4f : 0.0f)];
  m_currentScreen = aPage;
}


#pragma mark -
#pragma mark Touches


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super ccTouchesEnded:touches withEvent:event];
  
	if (self.position.x < 0 && self.position.x > -self.bounds.width + self.screenSize.width)
  {
    if (self.touchDistancePoint.x < -self.minimumTouchLengthToChangePage && (m_currentScreen+1) < [m_layers count])
    {
      [self moveToPage:m_currentScreen+1 animated:YES];
    }
    else if (self.touchDistancePoint.x > self.minimumTouchLengthToChangePage && m_currentScreen > 0)
    {
      [self moveToPage:m_currentScreen-1 animated:YES];
    }
    else
    {
      [self moveToPage:m_currentScreen animated:YES];
    }
  }
}


#pragma mark -
#pragma mark Page Control


//that's a TODO!


@end
