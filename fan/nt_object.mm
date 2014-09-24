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

#import "nt_object.h"
#import "ntt_config.h"
#import "types.h"
#import "config.h"
#import "nt_attribute.h"
#import "CCRotateAround.h"

@interface nt_object (Private)

- (void)rotateAtSpeed:(float)aSpeed clockWise:(BOOL)isClockWise;
- (void)rotateAroundPoint:(CGPoint)aRotationPoint atSpeed:(float)aSpeed clockWise:(BOOL)isClockWise;
- (void)oscillateAtSpeed:(float)aSpeed distance:(CGPoint)aDistance;

@end

@implementation nt_object
@synthesize rotates, isEditingPosition;

- (id)init
{
  return [self initWithPosition:CGPointMake(0, 0) angle:0];
}


- (id)initWithPosition:(CGPoint)aPosition angle:(float)aAngle
{
  return [self initWithPosition:aPosition angle:aAngle attributes:[NSArray array]];
}


- (id)initWithPosition:(CGPoint)aPosition angle:(float)aAngle attribute:(nt_attribute *)aAttribute
{
  return [self initWithPosition:aPosition angle:aAngle attributes:[NSArray arrayWithObject:aAttribute]];
}


- (id)initWithPosition:(CGPoint)aPosition angle:(float)aAngle attributes:(NSArray *)aAttributes
{
  self = [super init];
  if (self) 
  {
    self.rotates = YES;
    self.isEditingPosition = YES;
    
    m_attributes = [[NSMutableArray alloc] initWithArray:aAttributes copyItems:YES];
    
    m_animating = NO;
    self.position = aPosition;
    self.angle = aAngle;
    m_originalPosition = aPosition;
    m_originalAngle = aAngle;
  }
  return self;
}


- (id)copyWithZone:(NSZone *)zone
{
  nt_object * another = [[nt_object alloc] initWithPosition:CGPointMake(m_physicsPosition.x*PTM_RATIO, m_physicsPosition.y*PTM_RATIO) angle:CC_RADIANS_TO_DEGREES(m_angle) attributes:m_attributes];
  return another;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
  float angle = [aDecoder decodeFloatForKey:@"angle"];
  float x = [aDecoder decodeFloatForKey:@"x"];
  float y = [aDecoder decodeFloatForKey:@"y"];
  NSArray * attributes = [aDecoder decodeObjectForKey:@"attributes"];
  
  return [self initWithPosition:CGPointMake(x, y) angle:angle attributes:attributes];
}


- (void)dealloc
{
  [m_attributes release];
  [super dealloc];
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
  CGPoint pos = m_originalPosition;
  [aCoder encodeFloat:m_originalAngle forKey:@"angle"];
  [aCoder encodeFloat:pos.x forKey:@"x"];
  [aCoder encodeFloat:pos.y forKey:@"y"];
  [aCoder encodeObject:m_attributes forKey:@"attributes"];
}


- (void)setAngle:(float)anAngle
{
  if (!self.rotates)
    return;
  
  m_angle = CC_DEGREES_TO_RADIANS(anAngle);
  if (m_body)
    m_body->SetTransform(m_body->GetWorldCenter(), m_angle);
}


- (float)angle
{
  return CC_RADIANS_TO_DEGREES(m_angle);
}


- (CGPoint)originalPosition
{
  return m_originalPosition;
}


- (void)checkSnap
{
  CGPoint newPos = self.position;
  float newAngle = self.angle;
  CGSize grid = CGSizeMake(10, 10);
  float angleThresh = 45;
  
  newPos.x /= grid.width;
  newPos.y /= grid.height;
  
  newPos.x = roundf(newPos.x);
  newPos.y = roundf(newPos.y);
  
  newPos.x *= grid.width;
  newPos.y *= grid.height;
  
  newAngle /= angleThresh;
  
  newAngle = roundf(newAngle);
  
  newAngle *= angleThresh;
  
  [self runAction:[CCEaseElasticOut actionWithAction:[CCMoveTo actionWithDuration:0.4f position:newPos]]];
  [self runAction:[CCEaseElasticOut actionWithAction:[CCActionTween actionWithDuration:0.4f key:@"angle" from:self.angle to:newAngle]]];
}


- (void)reset
{
  m_body->SetTransform(m_physicsPosition, 0);
  m_body->SetLinearVelocity(b2Vec2_zero);
  m_body->SetAngularVelocity(0);
  self.visible = YES;
}


- (NSMutableArray *)attributes
{
  return m_attributes;
}


- (nt_attribute *)lastAttribute
{
  return [m_attributes lastObject];
}


- (void)addAttribute:(nt_attribute *)aAttribute
{
  if (aAttribute.movement != kObjectMovementTypeNone)
    [m_attributes addObject:aAttribute];
}


- (void)removeAttribute:(nt_attribute *)aAttribute
{
  [m_attributes removeObject:aAttribute];
}


- (void)removeLastAttribute
{
  [self removeAttribute:[self lastAttribute]];
}


- (UIImage *)uiimage
{
  int tx = self.contentSize.width;
  int ty = self.contentSize.height;
  
  CGPoint ap = self.anchorPoint;
  self.anchorPoint  = CGPointZero;
  
  CCRenderTexture *renderer   = [CCRenderTexture renderTextureWithWidth:tx height:ty];
  
  [renderer begin];
  [self visit];
  [renderer end];
  
  self.anchorPoint = ap;
  
  return [renderer getUIImage];
}


- (void)startMovement
{
  if (m_animating)
    return;
  
  m_animating = YES;
  
  for (nt_attribute * a in m_attributes)
  {
    switch (a.movement)
    {
      case kObjectMovementTypeNone:
        
        break;
      case kObjectMovementTypeOscillateVertical:
        [self oscillateAtSpeed:a.time distance:CGPointMake(0.0f, a.distance * (a.inverted ? -1.0f : 1.0f))];
        break;
      case kObjectMovementTypeOscillateHorizontal:
        [self oscillateAtSpeed:a.time distance:CGPointMake(a.distance * (a.inverted ? -1.0f : 1.0f), 0.0f)];
        break;
      case kObjectMovementTypeRotate:
        
        [self rotateAroundPoint:a.rotationPoint atSpeed:a.time clockWise:a.inverted];
        
        if (!a.dontRotateBody)
        {
          [self rotateAtSpeed:a.time clockWise:a.inverted];
        }
        
        break;
        
      default:
        a.movement = kObjectMovementTypeNone;
        break;
    }
  }
}


- (void)stopMovement
{
  m_animating = NO;
  
  [self stopAllActions];
}


- (void)resetMovement
{
  [self stopMovement];
  
  id move = [CCMoveTo actionWithDuration:0.4f position:m_originalPosition];
  id rotate = [CCRotateTo actionWithDuration:0.4f angle:m_originalAngle];
  
  [self runAction:move];
  [self runAction:rotate];
  
//  [self startMovement];
}


- (void)rotateAtSpeed:(float)aSpeed clockWise:(BOOL)isClockWise
{
  [self runAction:[CCRepeatForever actionWithAction:[CCActionTween actionWithDuration:aSpeed key:@"angle" from:(isClockWise ? m_originalAngle + 360 : m_originalAngle) to:(isClockWise ? m_originalAngle : m_originalAngle + 360)]]];
}


- (void)rotateAroundPoint:(CGPoint)aRotationPoint atSpeed:(float)aSpeed clockWise:(BOOL)isClockWise
{
  CGSize size = [[CCDirector sharedDirector] winSize];
  float scale = size.width / STANDARD_SCREEN_WIDTH;
  
  aRotationPoint = ccpAdd(aRotationPoint, CGPointMake(0.5, 0.5));
  CGPoint rotPoint = [self convertToWorldSpace:CGPointMake(aRotationPoint.x*self.contentSize.width, aRotationPoint.y*self.contentSize.height)];
  rotPoint = CGPointMake(rotPoint.x/scale, rotPoint.y/scale);
  [self runAction:[CCRepeatForever actionWithAction:[CCRotateAroundBy actionWithDuration:aSpeed angle:(isClockWise ? 360 : -360) rotationPoint:rotPoint]]];
}


- (void)oscillateAtSpeed:(float)aSpeed distance:(CGPoint)aDistance
{
  id move1 = [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:aSpeed position:CGPointMake(m_originalPosition.x + aDistance.x, m_originalPosition.y + aDistance.y)]];
  id move2 = [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:aSpeed position:CGPointMake(m_originalPosition.x - aDistance.x, m_originalPosition.y - aDistance.y)]];
  
  [self runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne:move1 two:move2]]];
}


- (void)enableGuide:(BOOL)isEnableGuide
{
  if (m_guide == nil)
  {
    m_guide = [[CCSprite alloc] initWithFile:@"level_edit_rotate.png"];
    m_guide.position = CGPointMake(self.contentSize.width/2, self.contentSize.height/2);
    m_guide.tag = kTagLevelEdit;
  }
  
  if (isEnableGuide)
  {
    if (m_guide.parent == nil)
    {
      m_guide.scale = 0;
      m_guide.opacity = 0;
      [self addChild:m_guide z:-1];
      [m_guide runAction:[CCFadeIn actionWithDuration:0.2f]];
      [m_guide runAction:[CCEaseElasticOut actionWithAction:[CCScaleTo actionWithDuration:0.4f scale:1.0f]]];
    }
  }
  else
  {
    if (m_guide.parent != nil)
    {
      [m_guide runAction:[CCFadeOut actionWithDuration:0.1f]];
      [m_guide runAction:[CCSequence actionOne:[CCScaleTo actionWithDuration:0.15f scale:0.0f] two:[CCCallBlock actionWithBlock:^{
        if (m_guide.parent != nil)
          [self removeChild:m_guide cleanup:NO];
      }]]];
    }
  }
}


- (BOOL)guideVisible
{
  if (m_guide == nil)
    return NO;
  
  return (m_guide.parent != nil ? YES : NO);
}


- (void)setSensor:(BOOL)isSensor
{
  m_body->GetFixtureList()->SetSensor(isSensor);
}


- (void)createBodies
{
  //subclass should override
}


- (void)setWorld:(b2World *)aWorld
{
  [super setWorld:aWorld];
  [self createBodies];
}


- (void)setPosition:(CGPoint)position
{ 
  [super setPosition:position];
  
  m_physicsPosition = b2Vec2(position.x/PTM_RATIO, position.y/PTM_RATIO);
  
  if (m_body)
  {
    m_body->SetTransform(m_physicsPosition, m_angle);
  }
}


@end
