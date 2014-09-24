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

#import "nt_block.h"
#import "types.h"
#import "ntt_config.h"

@interface nt_block (Private)

- (void)initBlockWithType:(kBlockType)aType;

+ (NSString *)nameFromType:(kBlockType)aType;

@end

@implementation nt_block

- (id)initWithPosition:(CGPoint)aPosition angle:(float)aAngle attributes:(NSArray *)aAttributes
{
  self = [super initWithPosition:aPosition angle:aAngle attributes:aAttributes];
  if (self) 
  {
    self.tag = kTagBlock;
    self.rotates = YES;
    //[self setType:kBlockTypeLongLarge];
  }
  return self;
}


- (id)copyWithZone:(NSZone *)zone
{
  nt_block * another = [[nt_block alloc] initWithPosition:CGPointMake(m_physicsPosition.x*PTM_RATIO, m_physicsPosition.y*PTM_RATIO) angle:CC_RADIANS_TO_DEGREES(m_angle) attributes:m_attributes];
  [another setType:m_type];
  return another;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self)
  {
    kBlockType type = (kBlockType)[aDecoder decodeIntForKey:@"type"];
    [self setType:type];
  }
  return self;
}


- (void)dealloc
{
  
  [super dealloc];
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [super encodeWithCoder:aCoder];
  
  [aCoder encodeInt:m_type forKey:@"type"];
}


- (kBlockType)type
{
  return m_type;
}


- (void)setType:(kBlockType)aType
{
  m_type = aType;
  [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[nt_block nameFromType:m_type]]];
}


- (void)createBodies
{
  b2BodyDef bDef;
  b2FixtureDef bFix;
  b2PolygonShape bShapePoly;
  b2CircleShape bShapeCircle;
  b2Body * bBody;
  CGSize s = CGSizeMake((self.contentSize.width - 1.0f)/(2*PTM_RATIO), (self.contentSize.height - 1.0f)/(2*PTM_RATIO));
  
  bDef.position.Set(m_physicsPosition.x, m_physicsPosition.y);
  bDef.type = b2_staticBody;
  bDef.allowSleep = true;
  
  bShapePoly.SetAsBox(s.width, s.height);
  bShapeCircle.m_radius = (self.contentSize.width - 1.0f)/(2*PTM_RATIO);
  
  if (m_type == kBlockTypeCircle)
  {
    bFix.shape = &bShapeCircle;
  }
  else if (m_type == kBlockTypeTriangleHole)
  {
    b2Vec2 v1 = b2Vec2(-s.width, -s.height);
    b2Vec2 v2 = b2Vec2( s.width, -s.height);
    b2Vec2 v3 = b2Vec2( 0, s.height);
    
    b2Vec2 verts[3] = {v1, v2, v3};
    
    bShapePoly.Set(verts, 3);
    bFix.shape = &bShapePoly;
  }
  else if (m_type == kBlockTypeTriangleWhole)
  {
    b2Vec2 v1 = b2Vec2(-s.width, -s.height);
    b2Vec2 v2 = b2Vec2(s.width, -s.height);
    b2Vec2 v3 = b2Vec2(-s.width, s.height);
    
    b2Vec2 verts[3] = {v1, v2, v3};
    
    bShapePoly.Set(verts, 3);
    bFix.shape = &bShapePoly;
  }
  else
  {
    bFix.shape = &bShapePoly;
  }
  
  bFix.density = 1.0f;
  bFix.friction = 1.0f;
  
  bBody = m_world->CreateBody(&bDef);
  bBody->CreateFixture(&bFix);
  
  bBody->SetTransform(bBody->GetWorldCenter(), m_angle);
  
  [self setBody:bBody];
}


+ (NSString *)nameFromType:(kBlockType)aType
{
  NSString * res = @"";
  
  switch (aType)
  {
    case kBlockTypeLongSmall:
      res = @"block_long_small.png";
      break;
    case kBlockTypeLongLarge:
      res = @"block_long_large.png";
      break;
    case kBlockTypeSquareSmall:
      res = @"block_square_small.png";
      break;
    case kBlockTypeSquareLarge:
      res = @"block_square_large.png";
      break;
    case kBlockTypeTriangleHole:
      res = @"block_triangle_hole.png";
      break;
    case kBlockTypeTriangleWhole:
      res = @"block_triangle_whole.png";
      break;
    case kBlockTypeCircle:
      res = @"block_circle.png";
      break;
      
    default:
      break;
  }
  return res;
}


@end
