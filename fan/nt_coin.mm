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

#import "nt_coin.h"
#import "ntt_config.h"
#import "types.h"

@interface nt_coin (Private)



@end


@implementation nt_coin
@synthesize isEaten = m_eaten;

- (id)initWithPosition:(CGPoint)aPosition angle:(float)aAngle attributes:(NSArray *)aAttributes
{
  self = [super initWithPosition:aPosition angle:m_angle attributes:aAttributes];
  if (self)
  {
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"coin.png"]];
    
    self.tag = kTagCoin;
    self.rotates = NO;
    m_eaten = NO;
  }
  return self;
}


- (id)copyWithZone:(NSZone *)zone
{
  nt_coin * another = [[nt_coin alloc] initWithPosition:CGPointMake(m_physicsPosition.x*PTM_RATIO, m_physicsPosition.y*PTM_RATIO) angle:CC_RADIANS_TO_DEGREES(m_angle) attributes:m_attributes];
  return another;
}


- (void)dealloc
{
  
  [super dealloc];
}


- (BOOL)eatMe
{
  BOOL res = !m_eaten;
  m_eaten = YES;
  self.visible = NO;
  return res;
}


- (void)reset
{
  [super reset];
  m_eaten = NO;
}


- (void)createBodies
{
  b2BodyDef bDef;
  b2FixtureDef bFix;
  b2PolygonShape bShapePoly;
  b2Body * bBody;
  CGSize s = CGSizeMake(self.contentSize.width/(2*PTM_RATIO), self.contentSize.height/(2*PTM_RATIO));
  
  bDef.position.Set(m_physicsPosition.x, m_physicsPosition.y);
  bDef.type = b2_staticBody;
  bDef.allowSleep = true;
  
  bShapePoly.SetAsBox(s.width, s.height);
  
  bFix.shape = &bShapePoly;
  bFix.density = 1.0f;
  bFix.friction = 1.0f;
  bFix.isSensor = true;
  
  bBody = m_world->CreateBody(&bDef);
  bBody->CreateFixture(&bFix);
  
  bBody->SetTransform(bBody->GetWorldCenter(), m_angle);
  
  [self setBody:bBody];
}

@end
