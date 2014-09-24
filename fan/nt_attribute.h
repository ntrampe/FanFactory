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

#import <Foundation/Foundation.h>
#import "types.h"

@interface nt_attribute : NSObject <NSCoding, NSCopying>
{
  kObjectMovementType m_movement;
  float m_time, m_distance;
  CGPoint m_rotationPoint;
  BOOL m_dontRotateBody;
  BOOL m_inverted;
}
@property (nonatomic, assign) kObjectMovementType movement;
@property (nonatomic, assign) float time, distance;
@property (nonatomic, assign) CGPoint rotationPoint;
@property (nonatomic, assign) BOOL dontRotateBody;
@property (nonatomic, assign) BOOL inverted;

+ (id)attributeWithMovement:(kObjectMovementType)aMovement time:(float)aTime distance:(float)aDistance rotationPoint:(CGPoint)aRotationPoint rotateBody:(BOOL)isRotatingBody invert:(BOOL)isInverted;
- (id)initWithMovement:(kObjectMovementType)aMovement time:(float)aTime distance:(float)aDistance rotationPoint:(CGPoint)aRotationPoint rotateBody:(BOOL)isRotatingBody invert:(BOOL)isInverted;

@end
