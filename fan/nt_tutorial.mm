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

#import "nt_tutorial.h"
#import "nt_alertBanner.h"

@interface nt_tutorial (Private)

- (void)arrowAttributesForPoint:(CGPoint)aPoint
                   andDirection:(kArrowDirection)aDirection
                       position:(CGPoint&)aPosition
                       rotation:(float&)aRotation
               movementDistance:(CGPoint&)aMovementDistance;

@end

@implementation nt_tutorial
@synthesize delegate = _delegate;
@synthesize state = m_state;
@synthesize attempts = m_attempts;

- (id)init
{
  self = [super init];
  if (self) 
  {
    m_arrow = [[CCSprite alloc] initWithFile:@"tutorial_arrow.png"];
    m_states = [[NSMutableArray alloc] init];
    m_state = 0;
    m_attempts = 0;
    m_arrowBounds = self.contentSize;
    self.autoNext = YES;
    self.autoRemoveArrow = YES;
  }
  return self;
}


- (void)dealloc
{
  [m_states release];
  [m_arrow release];
  [super dealloc];
}


- (void)pointArrowToLocation:(CGPoint)aPoint forceDirection:(kArrowDirection)aDirection
{
  CGPoint movePos = CGPointMake(0, 0);
  CGPoint pos = m_arrow.position;
  float rot = m_arrow.rotation;
  
  if (aDirection == kArrowDirectionNone)
  {
    //this set of statements is not dependent because we want to try all cases
    
    //set default case
    aDirection = kArrowDirectionDown;
    
    if (aPoint.x < m_arrow.contentSize.width*m_arrow.scale/2.0f)
    {
      aDirection = kArrowDirectionLeft;
    }
    if (aPoint.x > m_arrowBounds.width - m_arrow.contentSize.width*m_arrow.scale/2.0f)
    {
      aDirection = kArrowDirectionRight;
    }
    if (aPoint.y > m_arrowBounds.height - m_arrow.contentSize.height*m_arrow.scale)
    {
      aDirection = kArrowDirectionUp;
    }
    if (aPoint.y < m_arrow.contentSize.height*m_arrow.scale)
    {
      aDirection = kArrowDirectionDown;
    }
  }
  
  [self arrowAttributesForPoint:aPoint
                   andDirection:aDirection
                       position:pos
                       rotation:rot
               movementDistance:movePos];
  
  if (m_arrow.parent == nil)
  {
    m_arrow.opacity = 0;
    m_arrow.position = pos;
    m_arrow.rotation = rot;
    [self addChild:m_arrow z:10];
  }
  
  CCAction * oscillate = [CCRepeatForever actionWithAction:
                          [CCSequence actionOne:[CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:1.0f position:movePos]]
                                            two:[CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:1.0f position:CGPointMake(-movePos.x, -movePos.y)]]]];
  
  if (self.transitioning)
    return;
  
  [m_arrow stopAllActions];
  
  CCAction * move = [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:0.4f position:pos]];
  CCAction * rotate = [CCEaseSineInOut actionWithAction:[CCRotateTo actionWithDuration:0.4f angle:rot]];
  
  if (m_arrow.opacity == 0)
  {
    m_arrow.position = pos;
    m_arrow.rotation = rot;
    [m_arrow runAction:[CCFadeIn actionWithDuration:0.1f]];
  }
  
  [m_arrow runAction:move];
  [m_arrow runAction:rotate];
  
  [m_arrow performSelector:@selector(runAction:) withObject:oscillate afterDelay:0.4f];
}


- (void)pointArrowToLocation:(CGPoint)aPoint
{
  [self pointArrowToLocation:aPoint forceDirection:kArrowDirectionNone];
}


- (void)removeArrow
{
  if (m_arrow.opacity > 0)
  {
    [m_arrow runAction:[CCFadeOut actionWithDuration:0.2f]];
  }
}


- (void)addStateString:(NSString *)aStateString andArrowLocation:(CGPoint)aLocation forState:(unsigned int)aState
{
  nt_tutorialState * t = [nt_tutorialState tutorialStateWithState:aState stateString:aStateString arrowPoint:aLocation];
  [m_states addObject:t];
}


- (void)addStateString:(NSString *)aStateString forState:(unsigned int)aState
{
  [self addStateString:aStateString andArrowLocation:CGPointMake(-1, -1) forState:aState];
}


- (void)addState:(unsigned int)aState
{
  [self addStateString:nil forState:aState];
}


- (nt_tutorialState *)tutorialStateForState:(unsigned int)aState
{
  for (nt_tutorialState * t in m_states)
  {
    if (t.state == aState)
      return t;
  }
  
  return nil;
}


- (unsigned int)lastState
{
  unsigned int res = 0;
  
  for (nt_tutorialState * t in m_states)
  {
    if (t.state > res)
      res = t.state;
  }
  
  return res;
}


- (unsigned int)numberOfStates
{
  return m_states.count;
}


- (void)setState:(unsigned int)aState update:(BOOL)shouldUpdate
{
  m_state = aState;
  
  if (!shouldUpdate)
    return;
  
  [nt_alertview removeAllAlertViews];
  
  if (m_state > self.lastState)
  {
    if ([self.delegate respondsToSelector:@selector(tutorialDidReachEndOfTutorial:)])
      [self.delegate tutorialDidReachEndOfTutorial:self];
    return;
  }
  
  nt_tutorialState * t = [self tutorialStateForState:aState];
  
  if (t != nil)
  {
    if (t.stateString != nil && ![t.stateString isEqualToString:@""])
      [self addAlertWithText:t.stateString];
    
    if (!CGPointEqualToPoint(t.arrowPoint, CGPointMake(-1, -1)))
    {
      [self pointArrowToLocation:t.arrowPoint];
    }
    else
    {
      if (self.autoRemoveArrow)
        [self removeArrow];
    }
  }
  
  if ([self.delegate respondsToSelector:@selector(tutorial:didUpdateTutorialState:)])
    [self.delegate tutorial:self didUpdateTutorialState:self.state];
}


- (void)setState:(unsigned int)aState
{
  [self setState:aState update:YES];
}


- (void)setArrowScale:(float)aScale
{
  m_arrow.scale = aScale;
}


- (void)start
{
  [self setState:0];
}


- (void)next
{
  [self setState:m_state + 1];
}


- (void)end
{
  [self removeArrow];
  [nt_alertview removeAllAlertViews];
}


- (BOOL)transitioning
{
  return (m_arrow.numberOfRunningActions > 1);
}


- (void)addAlertWithText:(NSString *)aText time:(float)aTime
{
  nt_alertBanner * alert = [[nt_alertBanner alloc] initWithMessage:aText height:self.screenSize.height/2.0f delegate:self];
  [alert addTime:aTime];
  [alert show];
  [alert release];
}


- (void)addAlertWithText:(NSString *)aText
{
  [self addAlertWithText:aText time:0.0];
}


- (void)setArrowBounds:(CGSize)aBounds
{
  m_arrowBounds = aBounds;
}


- (void)ntalertViewDidShow:(nt_alertview *)sender
{
  
}


- (void)ntalertViewDidHide:(nt_alertview *)sender
{
  if (self.autoNext)
    [self next];
}


- (void)arrowAttributesForPoint:(CGPoint)aPoint
                   andDirection:(kArrowDirection)aDirection
                       position:(CGPoint&)aPosition
                       rotation:(float&)aRotation
               movementDistance:(CGPoint&)aMovementDistance
{
  float awayDistance = 30;
  
  switch (aDirection)
  {
    case kArrowDirectionUp:
      aRotation = 0;
      aPosition = CGPointMake(aPoint.x, aPoint.y - m_arrow.contentSize.height*m_arrow.scale/2.0f - awayDistance);
      aMovementDistance = CGPointMake(0, -awayDistance);
      break;
    case kArrowDirectionDown:
      aRotation = 180;
      aPosition = CGPointMake(aPoint.x, aPoint.y + m_arrow.contentSize.height*m_arrow.scale/2.0f + awayDistance);
      aMovementDistance = CGPointMake(0, awayDistance);
      break;
    case kArrowDirectionLeft:
      aRotation = -90;
      aPosition = CGPointMake(aPoint.x + m_arrow.contentSize.height*m_arrow.scale/2.0f + awayDistance, aPoint.y);
      aMovementDistance = CGPointMake(awayDistance, 0);
      break;
    case kArrowDirectionRight:
      aRotation = 90;
      aPosition = CGPointMake(aPoint.x - m_arrow.contentSize.height*m_arrow.scale/2.0f - awayDistance, aPoint.y);
      aMovementDistance = CGPointMake(-awayDistance, 0);
      break;
      
    default:
      break;
  }
}


@end
