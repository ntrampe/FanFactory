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

#import "nt_attribute.h"

@implementation nt_attribute
@synthesize movement = m_movement, time = m_time, distance = m_distance, rotationPoint = m_rotationPoint, dontRotateBody = m_dontRotateBody, inverted = m_inverted;


+ (id)attributeWithMovement:(kObjectMovementType)aMovement time:(float)aTime distance:(float)aDistance rotationPoint:(CGPoint)aRotationPoint rotateBody:(BOOL)isRotatingBody invert:(BOOL)isInverted
{
  return [[[self alloc] initWithMovement:aMovement time:aTime distance:aDistance rotationPoint:aRotationPoint rotateBody:isRotatingBody invert:isInverted] autorelease];
}


- (id)initWithMovement:(kObjectMovementType)aMovement time:(float)aTime distance:(float)aDistance rotationPoint:(CGPoint)aRotationPoint rotateBody:(BOOL)isRotatingBody invert:(BOOL)isInverted
{
  self = [super init];
  if (self)
  {
    m_movement = aMovement;
    m_time = aTime;
    m_distance = aDistance;
    m_rotationPoint = aRotationPoint;
    m_dontRotateBody = !isRotatingBody;
    m_inverted = isInverted;
  }
  return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
  kObjectMovementType movement = (kObjectMovementType)[aDecoder decodeIntForKey:@"movement"];
  float time = [aDecoder decodeFloatForKey:@"time"];
  float distance = [aDecoder decodeFloatForKey:@"distance"];
  BOOL drb = [aDecoder decodeBoolForKey:@"dontRotateBody"];
  BOOL invert = [aDecoder decodeBoolForKey:@"invert"];
  CGPoint rotPoint;
  
  rotPoint.x = [aDecoder decodeFloatForKey:@"rotationPoint.x"];
  rotPoint.y = [aDecoder decodeFloatForKey:@"rotationPoint.y"];
  
  return [self initWithMovement:movement time:time distance:distance rotationPoint:rotPoint rotateBody:!drb invert:invert];
}


- (id)copyWithZone:(NSZone *)zone
{
  nt_attribute * another = [[nt_attribute alloc] initWithMovement:m_movement time:m_time distance:m_distance rotationPoint:m_rotationPoint rotateBody:!m_dontRotateBody invert:m_inverted];
  return another;
}


- (void)dealloc
{
  
  [super dealloc];
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeInt:m_movement forKey:@"movement"];
  [aCoder encodeFloat:m_time forKey:@"time"];
  [aCoder encodeFloat:m_distance forKey:@"distance"];
  [aCoder encodeFloat:m_rotationPoint.x forKey:@"rotationPoint.x"];
  [aCoder encodeFloat:m_rotationPoint.y forKey:@"rotationPoint.y"];
  [aCoder encodeBool:m_dontRotateBody forKey:@"dontRotateBody"];
  [aCoder encodeBool:m_inverted forKey:@"invert"];
}


@end
