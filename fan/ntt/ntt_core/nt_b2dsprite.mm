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

#import "nt_b2dsprite.h"
#import "ntt_config.h"

@implementation nt_b2dsprite

- (id)init
{
  self = [super init];
  if (self) 
  {
    m_offset = CGPointMake(0, 0);
  }
  return self;
}


- (void)dealloc
{
//  [self destroyBody];
  [super dealloc];
}


- (void)setWorld:(b2World *)aWorld
{
  m_world = aWorld;
}


- (void)setBody:(b2Body *)aBody
{
  m_body = aBody;
  m_body->SetUserData(self);
}


- (void)destroyBody
{
  if (m_body != NULL)
  {
    m_world->DestroyBody(m_body);
    m_body = NULL;
  }
}


- (void)setOffset:(CGPoint)anOffset
{
  m_offset = anOffset;
}


- (b2Body *)body
{
  return m_body;
}


- (void)setLinearVelocity:(CGPoint)aVelocity
{
  m_body->SetLinearVelocity(b2Vec2(aVelocity.x, aVelocity.y));
}


- (void)setAngularVelocity:(float)aVelocity
{
  m_body->SetAngularVelocity(aVelocity);
}


- (void)destroy
{
  if (self != nil)
  {
    if (self.parent != nil)
      [self removeFromParentAndCleanup:YES];
    if (m_body != NULL)
    {
      m_world->DestroyBody(m_body);
      m_body = NULL;
    }
  }
}


- (BOOL)dirty
{
  return YES;
}


- (CGPoint)position
{
  if (!m_body)
    return CGPointMake(0, 0);
  
  b2Vec2 pos  = m_body->GetPosition();
	
	float x = pos.x * PTM_RATIO + m_offset.x;
	float y = pos.y * PTM_RATIO + m_offset.y;
  
  return ccp(x, y);
}


- (CGAffineTransform)nodeToParentTransform
{
  if (m_body == NULL)
    return transform_;
  
  b2Vec2 pos  = b2Vec2(self.position.x, self.position.y);
	
	float x = pos.x;
	float y = pos.y;
	
	if (ignoreAnchorPointForPosition_)
  {
		x += anchorPointInPoints_.x;
		y += anchorPointInPoints_.y;
	}
	
	float radians = m_body->GetAngle();
	float c = cosf(radians);
	float s = sinf(radians);
	
	if(!CGPointEqualToPoint(anchorPointInPoints_, CGPointZero))
  {
		x += c *- (anchorPointInPoints_.x * self.scaleX) + -s *- (anchorPointInPoints_.y * self.scaleY);
		y += s *- (anchorPointInPoints_.x * self.scaleX) + c *- (anchorPointInPoints_.y * self.scaleY);
	}
  
  transform_ = CGAffineTransformMake( c * self.scaleX,  s * self.scaleX,
                                     -s * self.scaleY,	c * self.scaleY,
                                     x,	y );
  
  //transform_ = CGAffineTransformScale(transform_, self.scaleX, self.scaleY);
	
	return transform_;
}

@end
