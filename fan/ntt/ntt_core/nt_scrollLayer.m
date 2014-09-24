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

#import "nt_scrollLayer.h"
#import "CCChangeScaleWithoutPositionChangeCenter.h"

@interface nt_scrollLayer (Private)

- (CGRect)contentFrame;
- (kScrollOutOfBoundsState)outOfBoundsState;
- (BOOL)isOutOfBounds;
- (void)checkBoundsAnimated:(BOOL)isAnimated;
- (void)bounceBack;

- (void)handleTapOnPoint:(CGPoint)aPoint;
- (void)handleEndScrollAnimation;

@end

@implementation nt_scrollLayer
@synthesize delegate = _delegate;
@synthesize scrollX, scrollY, isBounded, sticksToBottom, zooms = _zooms, bounces, doubleTapToZoom, drawBounds;
@synthesize touchDistance;
@synthesize touchDistancePoint;
@synthesize minimumScale, maximumScale;
@synthesize isScaling = m_scaling;

- (id)init
{
  self = [super init];
  if (self) 
  {
    self.isTouchEnabled = YES;
    m_velocity = CGPointMake(0, 0);
    m_maxVelocity = CGPointMake(100, 100); //not really a max velocity
    m_stretch = CGPointMake(0, 0);
    m_maxStretch = CGPointMake(self.screenSize.width/4, self.screenSize.height/4);
    m_state = kScrollLayerStateIdle;
    m_dragged = NO;
    m_scaling = NO;
    m_lastScale = 1.0f;
    m_animationTime = 0.4f;
    m_isTouching = NO;
    self.scrollX = YES;
    self.scrollY = YES;
    self.isBounded = YES;
    self.sticksToBottom = NO;
    self.zooms = NO;
    self.bounces = NO;
    self.doubleTapToZoom = NO;
    self.drawBounds = NO;
    self.minimumScale = self.maximumScale = 1.0f;
    
    m_touches = [[NSMutableArray alloc] init];
    
    [self scheduleUpdate];
  }
  return self;
}


- (void)dealloc
{
  [m_touches release];
  [super dealloc];
}


- (void)update:(ccTime)dt
{
  float friction = 0.98f;
  static CGPoint lastPos = (CGPoint){0,0};
  
	if (!m_isTouching)
	{
		// inertia
		if (!m_animating)
    {
      m_velocity.x *= friction * (self.isOutOfBounds && self.bounces ? 0.1f : 1.0f);
      m_velocity.y *= friction * (self.isOutOfBounds && self.bounces ? 0.1f : 1.0f);
      
      CGPoint pos = self.position;
      pos.x += m_velocity.x;
      pos.y += m_velocity.y;
      
      self.position = pos;
    }
    
    if (m_state == kScrollLayerStateScrolling)
    {
      if (fabsf(self.velocity.x) <= 0.2 && fabsf(self.velocity.y) <= 0.2)
      {
        m_state = kScrollLayerStateIdle;
        m_velocity = CGPointMake(0, 0);
        if (self.isBounded)
          [self checkBoundsAnimated:self.bounces];
        
        if ([self.delegate respondsToSelector:@selector(scrollLayerDidEndDecelerating:)])
          [self.delegate scrollLayerDidEndDecelerating:self];
      }
    }
	}
	else
	{
		if (self.scrollX)
      m_velocity.x = (self.position.x - lastPos.x)*self.scaleX;
    if (self.scrollY)
      m_velocity.y = (self.position.y - lastPos.y)*self.scaleY;
    
    //check bounds
    if (m_velocity.x > m_maxVelocity.x)
      m_velocity.x = m_maxVelocity.x;
    if (m_velocity.x < -m_maxVelocity.x)
      m_velocity.x = -m_maxVelocity.x;
    if (m_velocity.y < -m_maxVelocity.y)
      m_velocity.y = -m_maxVelocity.y;
	}
  
  lastPos = self.position;
  
  if (self.isBounded)
  {
    if (!self.bounces || self.isZooming)
    {
      [self checkBoundsAnimated:NO];
    }
    
    if (self.sticksToBottom)
    {
      self.position = CGPointMake(self.position.x, 0 - (self.screenSize.height/2*(1.0f - self.scale)));
      m_velocity.y = 0;
    }
    
    CGRect bounds = self.contentFrame;
    
    m_stretch = CGPointMake(max(self.position.x - bounds.origin.x, bounds.size.width - self.position.x), max(self.position.y - bounds.origin.y, bounds.size.height - self.position.y));
    
    if (m_stretch.x < 0)
      m_stretch.x = 0;
    if (m_stretch.x > m_maxStretch.x)
      m_stretch.x = m_maxStretch.x;
    if (m_stretch.y < 0)
      m_stretch.y = 0;
    if (m_stretch.y > m_maxStretch.y)
      m_stretch.y = m_maxStretch.y;
  }
}


- (void)visit
{
  [super visit];
  
  if (self.drawBounds)
  {
    float stroke = 4.0f;
    CGPoint points[4];
    CGPoint adjPos = self.position;
    
    adjPos.x += (self.screenSize.width/2.0f) * (1 - self.scaleX);
    adjPos.y += (self.screenSize.height/2.0f) * (1 - self.scaleY);
    
    points[0] = CGPointMake(adjPos.x - stroke/2.0f,                                  adjPos.y - stroke/2.0f                                   );
    points[1] = CGPointMake(adjPos.x - stroke/2.0f,                                  adjPos.y + self.bounds.height*self.scaleY + stroke/2.0f  );
    points[2] = CGPointMake(adjPos.x + self.bounds.width*self.scaleX + stroke/2.0f,  adjPos.y + self.bounds.height*self.scaleY + stroke/2.0f  );
    points[3] = CGPointMake(adjPos.x + self.bounds.width*self.scaleX + stroke/2.0f,  adjPos.y - stroke/2.0f                                   );
    
    glLineWidth(stroke);
    ccDrawPoly(points, 4, YES);
  }
}


- (CGPoint)velocity
{
  return m_velocity;
}


- (CGPoint)velocityPercentage
{
  return CGPointMake(m_velocity.x/m_maxVelocity.x, m_velocity.y/m_maxVelocity.y);
}


- (void)setBounds:(CGSize)aBounds
{
  m_bounds = aBounds;
  if (self.isBounded)
    [self checkBoundsAnimated:self.bounces];
}


- (CGSize)bounds
{
  return m_bounds;
}


- (void)setAnimationTime:(CGFloat)aAnimationTime
{
  m_animationTime = aAnimationTime;
}


- (void)setMaxVelocity:(CGPoint)aVelocity
{
  m_maxVelocity = aVelocity;
}


- (void)scrollToPosition:(CGPoint)aPoint inTime:(float)aTime
{
  if (aTime > 0.0f)
  {
    [self runAction:[CCSequence actionOne:[CCMoveTo actionWithDuration:aTime position:aPoint]
                                      two:[CCCallFunc actionWithTarget:self selector:@selector(handleEndScrollAnimation)]]];
    m_animating = YES;
    m_velocity = CGPointMake((aPoint.x - self.position.x)/(aTime*50), (aPoint.y - self.position.y)/(aTime*50));
  }
  else
  {
    self.position = aPoint;
    m_velocity = CGPointMake(0, 0);
  }
}


- (void)scrollToStartInTime:(float)aTime
{
  [self scrollToPosition:CGPointMake(0, 0) inTime:aTime];
}


- (void)scrollToEndInTime:(float)aTime
{
  [self scrollToPosition:CGPointMake(-m_bounds.width, 0) inTime:aTime];
}


- (void)zoomToScale:(float)aScale atPoint:(CGPoint)aPoint inTime:(float)aTime
{
  if (aScale > self.maximumScale)
    aScale = self.maximumScale;
  if (aScale < self.minimumScale)
    aScale = self.minimumScale;
  
  if (aTime > 0.0f)
  {
    [self runAction:[CCScaleTo actionWithDuration:aTime scale:aScale]];
    [self scrollToPosition:aPoint inTime:aTime];
  }
  else
  {
    self.scale = aScale;
    self.position = aPoint;
  }
}


- (void)zoomToScale:(float)aScale inTime:(float)aTime
{
  [self zoomToScale:aScale atPoint:self.position inTime:aTime];
}


- (void)zoomToScaleAndKeepPosition:(float)aScale inTime:(float)aTime
{
  CGPoint newPos = self.position;
  CGSize oldSize = CGSizeMake(self.contentSize.width*self.scale, self.contentSize.height*self.scale);
  CGSize newSize = CGSizeMake(self.contentSize.width*aScale, self.contentSize.height*aScale);
  CGSize difference = CGSizeMake((oldSize.width - newSize.width)/1.0f, (oldSize.height - newSize.height)/1.0f);
  
  newPos = CGPointMake(newPos.x + difference.width, newPos.y + difference.height);
  
  if (aTime > 0.0f)
  {
    [self runAction:[CCScaleTo actionWithDuration:aTime scale:aScale]];
    [self scrollToPosition:newPos inTime:aTime];
  }
  else
  {
    self.scale = aScale;
    self.position = newPos;
  }
}


- (void)zoomToNormalInTime:(float)aTime
{
  [self zoomToScaleAndKeepPosition:1.0f inTime:aTime];
}


- (BOOL)isZooming
{
  return (self.scale != self.maximumScale);
}


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  for (UITouch * touch in touches.allObjects)
    [m_touches addObject:touch];
  
  if (m_touches.count == 1)
  {
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:touch.view];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    if (touch.tapCount == 2)
    {
      if (self.doubleTapToZoom)
      {
        [self handleTapOnPoint:location];
      }
    }
    else
    {
      m_dragged = NO;
      
      if ([self.delegate respondsToSelector:@selector(scrollLayerWillBeginDragging:)])
        [self.delegate scrollLayerWillBeginDragging:self];
    }
  }
  
  m_isTouching = YES;
  self.touchDistance = 0.0f;
  self.touchDistancePoint = CGPointMake(0, 0);
}


- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (m_touches.count > 1)
  {
    UITouch * touch1 = [m_touches objectAtIndex: 0];
		UITouch * touch2 = [m_touches objectAtIndex: 1];
		CGPoint curPosTouch1 = [[CCDirector sharedDirector] convertToGL: [touch1 locationInView: [touch1 view]]];
		CGPoint curPosTouch2 = [[CCDirector sharedDirector] convertToGL: [touch2 locationInView: [touch2 view]]];
		CGPoint prevPosTouch1 = [[CCDirector sharedDirector] convertToGL: [touch1 previousLocationInView: [touch1 view]]];
		CGPoint prevPosTouch2 = [[CCDirector sharedDirector] convertToGL: [touch2 previousLocationInView: [touch2 view]]];
    CGPoint curPosLayer = ccpMidpoint(curPosTouch1, curPosTouch2);
		CGPoint prevPosLayer = ccpMidpoint(prevPosTouch1, prevPosTouch2);
    
    CGFloat prevScale = self.scale;
    CGFloat newScale = self.scale * ccpDistance(curPosTouch1, curPosTouch2) / ccpDistance(prevPosTouch1, prevPosTouch2);
    
    if (newScale != prevScale && self.zooms)
    {
      [self zoomToScale:newScale inTime:0.0f];
      
      CGPoint realCurPosLayer = [self convertToNodeSpace: curPosLayer];
      CGFloat deltaX = (realCurPosLayer.x - self.anchorPoint.x * self.contentSize.width) * (self.scale - prevScale);
      CGFloat deltaY = (realCurPosLayer.y - self.anchorPoint.y * self.contentSize.height) * (self.scale - prevScale);
      self.position = ccp(self.position.x - deltaX, self.position.y - deltaY);
    }
    
    if (!CGPointEqualToPoint(prevPosLayer, curPosLayer))
		{
      CGPoint percent = CGPointMake(((m_maxStretch.x - m_stretch.x)/m_maxStretch.x), ((m_maxStretch.y - m_stretch.y)/m_maxStretch.y));
      CGPoint delta = CGPointMake((curPosLayer.x - prevPosLayer.x)*percent.x, (curPosLayer.y - prevPosLayer.y)*percent.y);
      CGPoint pos = self.position;
      if (self.scrollX)
        pos.x = pos.x + delta.x;
      if (self.scrollY)
        pos.y = pos.y + delta.y;
      
      self.position = pos;
    }
  }
  else if (m_touches.count != 0)
  {
    UITouch * touch = [m_touches objectAtIndex:0];
    CGPoint curTouchPosition = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
    CGPoint prevTouchPosition = [[CCDirector sharedDirector] convertToGL: [touch previousLocationInView: [touch view]]];
    
    CGPoint percent = CGPointMake(((m_maxStretch.x - m_stretch.x)/m_maxStretch.x), ((m_maxStretch.y - m_stretch.y)/m_maxStretch.y));
    CGPoint delta = CGPointMake((curTouchPosition.x - prevTouchPosition.x)*percent.x, (curTouchPosition.y - prevTouchPosition.y)*percent.y);
    CGPoint pos = self.position;
    if (self.scrollX)
      pos.x = pos.x + delta.x;
    if (self.scrollY)
      pos.y = pos.y + delta.y;
    
    self.position = pos;
    
    self.touchDistance += ccpDistance(curTouchPosition, prevTouchPosition);
    self.touchDistancePoint = CGPointMake(self.touchDistancePoint.x + delta.x, self.touchDistancePoint.y + delta.y);
  }
  
  m_dragged = YES;
  m_state = kScrollLayerStateScrolling;
  
  if ([self.delegate respondsToSelector:@selector(scrollLayerDidScroll:)])
    [self.delegate scrollLayerDidScroll:self];
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  for (UITouch * touch in [touches allObjects])
    [m_touches removeObject:touch];
  
	if (!m_dragged)
  {
    //single touch
  }
  
  if (self.bounces && m_touches.count == 0)
  {
    [self bounceBack];
  }
  
  m_isTouching = NO;
  
  if ([self.delegate respondsToSelector:@selector(scrollLayerWillEndDragging:withVelocity:)])
    [self.delegate scrollLayerWillEndDragging:self withVelocity:self.velocity];
  
  if ([self.delegate respondsToSelector:@selector(scrollLayerWillBeginDecelerating:)])
    [self.delegate scrollLayerWillBeginDecelerating:self];
}


- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
  [self ccTouchesEnded:touches withEvent:event];
}


- (CGRect)contentFrame
{
  return CGRectMake(0 - (self.screenSize.width/2)*(1.0f - self.scale),
                    0 - (self.screenSize.height/2)*(1.0f - self.scale),
                    -(m_bounds.width*self.scale + (self.screenSize.width/2)*(1.0f - self.scale)) + self.screenSize.width,
                    -((m_bounds.height - self.screenSize.height)*self.scale - (self.screenSize.height/2)*(1.0f - self.scale)));
}


- (kScrollOutOfBoundsState)outOfBoundsState
{
  kScrollOutOfBoundsState res = kScrollOutOfBoundsStateNone;
  CGRect bounds = self.contentFrame;
  
  if (self.position.x > bounds.origin.x)
  {
    res = kScrollOutOfBoundsStateLeft;
  }
  else if (self.position.x < bounds.size.width)
  {
    res = kScrollOutOfBoundsStateRight;
  }
  
  if (self.position.y > bounds.origin.y)
  {
    if (res == kScrollOutOfBoundsStateLeft)
      res = kScrollOutOfBoundsStateLeftDown;
    else if (res == kScrollOutOfBoundsStateRight)
      res = kScrollOutOfBoundsStateRightDown;
    else
      res = kScrollOutOfBoundsStateDown;
  }
  else if (self.position.y < bounds.size.height)
  {
    if (res == kScrollOutOfBoundsStateLeft)
      res = kScrollOutOfBoundsStateLeftUp;
    else if (res == kScrollOutOfBoundsStateRight)
      res = kScrollOutOfBoundsStateRightUp;
    else
      res = kScrollOutOfBoundsStateUp;
  }
  
  return res;
}


- (BOOL)isOutOfBounds
{
  return (self.outOfBoundsState != kScrollOutOfBoundsStateNone);
}


- (void)checkBoundsAnimated:(BOOL)isAnimated
{
  CGRect bounds = self.contentFrame;
  CGPoint pos = self.position;
  CGPoint vel = self.velocity;
  kScrollOutOfBoundsState state = self.outOfBoundsState;
  
  if (self.position.x > bounds.origin.x)
  {
    pos.x = bounds.origin.x;
    vel.x = 0;
  }
  else if (self.position.x < bounds.size.width)
  {
    pos.x = bounds.size.width;
    vel.x = 0;
  }
  
  if (self.position.y > bounds.origin.y)
  {
    pos.y = bounds.origin.y;
    vel.y = 0;
  }
  else if (self.position.y < bounds.size.height)
  {
    pos.y = bounds.size.height;
    vel.y = 0;
  }
  
  if (state != kScrollOutOfBoundsStateNone)
  {
    if (isAnimated)
    {
      m_velocity = vel;
      [self scrollToPosition:pos inTime:0.2f];
    }
    else
    {
      m_velocity = vel;
      self.position = pos;
    }
  }
}


- (void)bounceBack
{
  [self checkBoundsAnimated:YES];
}


- (void)handleTapOnPoint:(CGPoint)aPoint
{
  if (!self.zooms)
    return;
  
  aPoint = [self convertToNodeSpace:aPoint];
  aPoint = CGPointMake(aPoint.x - self.screenSize.width/2, aPoint.y - self.screenSize.height/2);
  aPoint = ccpMult(aPoint, -1.0f);
  
  if (self.isZooming)
  {
    [self zoomToScale:1.0f atPoint:aPoint inTime:0.4f];
  }
  else
  {
    [self zoomToScaleAndKeepPosition:self.minimumScale inTime:0.4f];
  }
}


- (void)handleEndScrollAnimation
{
  m_animating = NO;
  m_velocity = CGPointMake(0, 0);
}


@end
