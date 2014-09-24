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

#import "nt_player.h"
#import "ntt_config.h"

@interface nt_player (Private)

- (void)initPhysics;

@end

@implementation nt_player

- (id)initWithWorld:(b2World *)aWorld atPosition:(CGPoint)aPosition
{
  self = [super initWithSpriteFrameName:@"player.png"];
  if (self) 
  {
    m_hurtLevel = 0;
    m_shieldLevel = 0;
    m_isShielded = NO;
    m_isReset = YES;
    self.finished = NO;
    m_physicsPosition = b2Vec2(aPosition.x/PTM_RATIO, aPosition.y/PTM_RATIO);
    m_shield = [[CCSprite alloc] initWithFile:@"player_shield.png"];
    m_shield.position = CGPointMake(self.contentSize.width/2.0f, self.contentSize.height/2.0f);
    m_shield.opacity = 200.0f;
    
    [self setWorld:aWorld];
  }
  return self;
}


- (void)dealloc
{
  [m_shield release];
  [super dealloc];
}


- (void)launch
{
  m_body->SetType(b2_dynamicBody);
  //m_body->ApplyForceToCenter(b2Vec2(500, 1000));
  m_isReset = NO;
}


- (void)reset
{
  [super reset];
  
  m_body->SetType(b2_staticBody);
  
  m_hurtLevel = 0;
  m_shieldLevel = 0;
  self.color = ccc3(255, 255, 255);
  m_isReset = YES;
  self.finished = NO;
  //[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"player.png"]];
  
  [self deactivateShield];
}


- (void)getHurt
{
  if (self.isShielded)
  {
    m_shieldLevel--;
    m_shield.opacity = m_shield.opacity - 30.0f;
    if (m_shieldLevel <= 0)
    {
      [self deactivateShield];
    }
  }
  else
  {
    m_hurtLevel++;
    
    if (m_hurtLevel > 3)
    {
      m_hurtLevel = 3;
    }
    
    self.color = ccc3(255 - 50*m_hurtLevel, 255 - 50*m_hurtLevel, 255 - 50*m_hurtLevel);
  }
}


- (uint)hurtLevel
{
  return m_hurtLevel;
}


- (BOOL)isDead
{
  return (m_hurtLevel >= 3);
}


- (BOOL)isReset
{
  return (m_isReset);
}


- (BOOL)isShielded
{
  return m_isShielded;
}


- (void)setShieldLevel:(unsigned int)aLevel
{
  m_shieldLevel = aLevel;
}


- (void)activateShield
{
  if (m_shieldLevel > 0)
  {
    if (![m_shield parent])
      [self addChild:m_shield z:1];
    
    CCAction * scale = [CCRepeatForever actionWithAction:[CCSequence actionOne:[CCScaleTo actionWithDuration:1.0f scale:1.2f] two:[CCScaleTo actionWithDuration:1.0f scale:1.0f]]];
    [m_shield runAction:scale];
    
    m_isShielded = YES;
  }
}


- (void)deactivateShield
{
  [m_shield stopAllActions];
  m_shield.scale = 1.0f;
  
  if ([m_shield parent])
    [m_shield removeFromParentAndCleanup:NO];
  
  m_shield.opacity = 200.0f;
  
  m_isShielded = NO;
}


- (void)setBallSize:(unsigned int)aSize
{
  if (m_body != nil)
  {
    [self destroyBody];
    self.scale = 1.0f - aSize*0.05f;
    [self createBodies];
  }
}


- (void)createBodies
{
  b2BodyDef playerDef;
  b2FixtureDef playerFix;
  b2CircleShape playerShape;
  b2Body * body;
  
  float mass = 2.136190966;
  float radius = ((self.contentSize.height*self.scale/2 - 2)/PTM_RATIO);
  
  playerDef.position.Set(m_physicsPosition.x, m_physicsPosition.y);
  playerDef.type = b2_staticBody;
  playerDef.allowSleep = false;
  playerShape.m_radius = radius;
  
  playerFix.shape = &playerShape;
  playerFix.density = mass/(M_PI*powf(radius, 2));  //1.16
  playerFix.friction = 1.0f;
  playerFix.restitution = 0.4f;
  
  body = m_world->CreateBody(&playerDef);
  body->CreateFixture(&playerFix);
  
  [self setBody:body];
}


@end
