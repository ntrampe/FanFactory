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

#import "StarMeter.h"

@interface StarMeter (Private)

- (void)removeStars;
- (void)showStars;
- (void)showStar:(CCSprite *)aStar;
- (void)hideStars;
- (void)hideStar:(CCSprite *)aStar;

@end

@implementation StarMeter
@synthesize starScale;

- (id)init
{
  self = [super init];
  if (self) 
  {
    m_nStars = 0;
    self.starScale = 1.0f;
  }
  return self;
}


- (void)dealloc
{
  [self removeStars];
  [super dealloc];
}


- (void)setStars:(int)aStars
{
  [self setStars:aStars animated:YES];
}


- (void)setStars:(int)aStars animated:(BOOL)isAnimated
{
  m_nStars = aStars;
  
  [self removeStars];
  
  for (int i = 0; i < 3; i++)
  {
    BOOL star = i < m_nStars;
    CCSprite * s = [[CCSprite alloc] initWithFile:(star ? @"star_big.png" : @"nostar_big.png")];
    s.scale = self.starScale;
    s.position = CGPointMake(s.contentSize.width*s.scale*(i+1) - s.contentSize.width*s.scale/4, 2 + (s.contentSize.height*s.scale/2.0f));
    m_stars[i] = s;
    
    if (isAnimated)
    {
      m_stars[i].scale = 0.0f;
    }
    else
    {
      [self addChild:m_stars[i]];
    }
    
  }
  
  if (isAnimated)
  {
    [self showStars];
  }
}


- (CGSize)starSize
{
  if (m_stars[0])
    return m_stars[0].contentSize;
  return CGSizeZero;
}


- (void)removeStars
{
  for (int i = 0; i < 3; i++)
  {
    if (m_stars[i] != nil)
    {
      [m_stars[i] removeFromParentAndCleanup:YES];
      [m_stars[i] release];
      m_stars[i] = nil;
    }
  }
  [self removeAllChildrenWithCleanup:YES];
}


- (void)showStars
{
  for (int i = 0; i < 3; i++)
  {
    [self performSelector:@selector(showStar:) withObject:m_stars[i] afterDelay:0.1f*(i+1)];
  }
}


- (void)showStar:(CCSprite *)aStar
{
  aStar.scale = 0.0f;
  CCScaleTo * scale = [CCScaleTo actionWithDuration:0.4f scale:starScale];
  
  [self addChild:aStar];
  [aStar runAction:scale];
}


- (void)hideStars
{
  for (int i = 0; i < 3; i++)
  {
    [self performSelector:@selector(hideStar:) withObject:m_stars[i] afterDelay:0.1f*(i+1)];
  }
}


- (void)hideStar:(CCSprite *)aStar
{
  aStar.scale = starScale;
  CCScaleTo * scale = [CCScaleTo actionWithDuration:0.4f scale:0.0f];
  
  [aStar runAction:scale];
  [aStar performSelector:@selector(removeFromParentAndCleanup:) withObject:YES afterDelay:0.4f];
}


@end
