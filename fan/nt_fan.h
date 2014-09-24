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
#import "Box2D.h"
#import "cocos2d.h"
#import "nt_object.h"

@interface nt_fan : nt_object <NSCopying, NSCoding>
{
  CCSprite * m_arrow;
  b2Fixture * m_wind, * m_fan;
  float m_power, m_maxPower;
}

- (void)setPower:(float)aPower;
- (void)setMaxPower:(float)aMaxPower;
- (void)setAnimating:(BOOL)isAnimating;

- (CGPoint)tip;
- (BOOL)isPointOnSprite:(CGPoint)aPoint;
- (BOOL)fixtureIsWind:(b2Fixture *)aFixture;
- (BOOL)fixtureIsFan:(b2Fixture *)aFixture;

- (float)power;
- (float)maxPower;

- (void)updateOnBody:(b2Body *)aBody;

- (void)animateToAngle:(float)aAngle andPower:(float)aPower;

@end
