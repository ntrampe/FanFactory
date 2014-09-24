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
#import "cocos2d.h"
#import "Box2d.h"
#import "nt_object.h"

@interface nt_player : nt_object
{
  uint m_hurtLevel, m_shieldLevel;
  BOOL m_isReset, m_isShielded;
  CCSprite * m_shield;
}
@property(readwrite, assign) BOOL finished;

- (id)initWithWorld:(b2World *)aWorld atPosition:(CGPoint)aPosition;

- (void)launch;
- (void)getHurt;
- (uint)hurtLevel;
- (BOOL)isDead;
- (BOOL)isReset;
- (BOOL)isShielded;

- (void)setShieldLevel:(unsigned int)aLevel;
- (void)activateShield;
- (void)deactivateShield;

- (void)setBallSize:(unsigned int)aSize;

@end
