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

#import "nt_fan.h"
#import "ntt_config.h"
#import "types.h"

#define FAN_HEIGHT 0.75f
#define WIND_HEIGHT 15.0f
#define DISTANCE_DIVISOR 400
#define MAX_POWER 15
#define FAN_ANIMATION_TAG 99

@interface nt_fan (Private)



@end

@implementation nt_fan


- (id)initWithPosition:(CGPoint)aPosition angle:(float)aAngle attributes:(NSArray *)aAttributes
{
  self = [super initWithPosition:aPosition angle:aAngle attributes:aAttributes];
  if (self)
  {
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"fan_1.png"]];
    
    self.tag = kTagFan;
    self.rotates = YES;
    
    m_arrow = [[CCSprite alloc] initWithFile:@"arrow.png"];
    m_arrow.position = CGPointMake(self.contentSize.width/2, self.contentSize.height);
    m_arrow.tag = kTagWind;
    [self addChild:m_arrow];
    
    [self setMaxPower:MAX_POWER];
  }
  return self;
}


- (id)copyWithZone:(NSZone *)zone
{
  nt_fan * another = [[nt_fan alloc] initWithPosition:CGPointMake(m_physicsPosition.x*PTM_RATIO, m_physicsPosition.y*PTM_RATIO) angle:CC_RADIANS_TO_DEGREES(m_angle) attributes:m_attributes];
  [another setPower:m_power];
  return another;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self)
  {
    float power = [aDecoder decodeFloatForKey:@"power"];
    [self setPower:power];
  }
  return self;
}


- (void)dealloc
{
  [m_arrow release];
  [super dealloc];
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [super encodeWithCoder:aCoder];
  
  [aCoder encodeFloat:self.power forKey:@"power"];
}


- (void)setPower:(float)aPower
{
  m_power = aPower;
  
  if (m_power > m_maxPower)
    m_power = m_maxPower;
  
  if (m_power < 0)
    m_power = 0;
  
  float scaleY = PTM_RATIO*m_power/m_arrow.contentSize.height;
  
  m_arrow.scaleY = scaleY;
  m_arrow.position = CGPointMake(self.contentSize.width/2, self.contentSize.height + m_arrow.contentSize.height*scaleY/2);
}


- (void)setMaxPower:(float)aMaxPower
{
  m_maxPower = aMaxPower;
}


- (void)setAnimating:(BOOL)isAnimating
{
  m_animating = isAnimating;
  
  if (isAnimating)
  {
    NSMutableArray * animFrames = [NSMutableArray array];
    
    for (int x = 1; x <= 24; x+=2) //24 images
    {
      [animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"fan_%i.png", x]]];
    }
    
    //float delay = max((MAX_POWER - m_power)/(MAX_POWER*6), 0.015f);  //6 is arbitrary
    float delay = 0.018f;
    
    CCAnimation *animation = [CCAnimation
                             animationWithSpriteFrames:animFrames delay:delay];
    CCAction * act = [CCRepeatForever actionWithAction:
                       [CCAnimate actionWithAnimation:animation]];
    act.tag = FAN_ANIMATION_TAG;
    [self runAction:act];
    m_arrow.visible = NO;
  }
  else
  {
    [self stopActionByTag:FAN_ANIMATION_TAG];
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"fan_1.png"]];
    m_arrow.visible = YES;
  }
}


- (CGPoint)tip
{
  CGPoint res = CGPointZero;
  
  res = CGPointMake(self.contentSize.width/2, self.contentSize.height/2 + m_arrow.contentSize.height*m_arrow.scaleY);
  
  return [self convertToWorldSpace:res];
}


- (BOOL)isPointOnSprite:(CGPoint)aPoint
{
  CGRect rectBounds = CGRectMake(m_arrow.position.x-(m_arrow.contentSize.width*0.5f*m_arrow.scaleX), m_arrow.position.y-(m_arrow.contentSize.width*0.5f*m_arrow.scaleY), m_arrow.contentSize.width*m_arrow.scaleX, m_arrow.contentSize.height*m_arrow.scaleY);
  rectBounds = CGRectApplyAffineTransform(rectBounds, [self nodeToWorldTransform]);      // convert box to world coordinates, scaling etc.
  CGPoint rotatedPt = ccpRotateByAngle(aPoint, m_arrow.position, -CC_DEGREES_TO_RADIANS(self.rotation));
  return CGRectContainsPoint(rectBounds, rotatedPt);
}


- (BOOL)fixtureIsWind:(b2Fixture *)aFixture
{
  return m_wind == aFixture;
}


- (BOOL)fixtureIsFan:(b2Fixture *)aFixture
{
  return m_fan == aFixture;
}


- (CCSprite *)arrow
{
  return m_arrow;
}


- (float)power
{
  return m_power;
}


- (float)maxPower
{
  return m_maxPower;
}


- (void)updateOnBody:(b2Body *)aBody
{
  b2Vec2 p1 = m_body->GetWorldCenter();
  b2Vec2 p2 = aBody->GetWorldCenter();
  
  float distance = FAN_HEIGHT*2 + WIND_HEIGHT*2 - sqrtf(powf(p1.x - p2.x, 2) + powf(p1.y - p2.y, 2));
  
  distance /= DISTANCE_DIVISOR;
  
  b2Vec2 forceDirection = m_body->GetWorldVector(b2Vec2(0,1));
  
  forceDirection = b2Vec2(forceDirection.x * distance * m_power, forceDirection.y * distance * m_power);
  
  aBody->ApplyLinearImpulse(forceDirection, aBody->GetWorldCenter());
}


- (void)animateToAngle:(float)aAngle andPower:(float)aPower
{
  [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f],
                [CCActionTween actionWithDuration:0.5f key:@"angle" from:self.angle to:aAngle],
                [CCActionTween actionWithDuration:0.5f key:@"power" from:self.power to:aPower], nil]];
}


- (void)createBodies
{
  b2BodyDef fanDef;
  b2FixtureDef fanFix;
  b2PolygonShape fanShape;
  
  fanDef.position.Set(m_physicsPosition.x, m_physicsPosition.y);
  fanDef.angle = m_angle;
  fanDef.type = b2_staticBody;
  fanDef.allowSleep = true;
  
  fanShape.SetAsBox(2.0f, FAN_HEIGHT);
  
  fanFix.shape = &fanShape;
  fanFix.density = 1.0f;
  fanFix.friction = 1.0f;
  
  m_body = m_world->CreateBody(&fanDef);
  m_fan = m_body->CreateFixture(&fanFix);
  
  fanShape.SetAsBox(2.0f, WIND_HEIGHT, b2Vec2(0, FAN_HEIGHT + WIND_HEIGHT), 0);
  
  fanFix.shape = &fanShape;
  fanFix.isSensor = true;
  
  m_wind = m_body->CreateFixture(&fanFix);
  [self setBody:m_body];
}


@end
