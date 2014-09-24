/*
 * Copyright (c) 2013 Nicholas Trampe
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

@interface nt_label : CCLabelTTF
{
  CGSize          m_shadowOffset;
  float           m_shadowBlur;
	ccColor4B       m_shadowColor;
  ccColor3B       m_fillColor;
  BOOL            m_showing;
}
@property (readonly) BOOL isShowing;


+ (id)labelWithString:(NSString *)string fontSize:(CGFloat)size;
- (id)initWithString:(NSString *)string fontSize:(CGFloat)size;

+ (id)labelWithString:(NSString *)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontSize:(CGFloat)size;
- (id)initWithString:(NSString *)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontSize:(CGFloat)size;

+ (id)labelWithString:(NSString *)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment lineBreakMode:(UILineBreakMode)lineBreakMode fontSize:(CGFloat)size;
- (id)initWithString:(NSString *)str dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment lineBreakMode:(UILineBreakMode)lineBreakMode fontSize:(CGFloat)size;

- (void)setTextColor:(ccColor3B)aColor;

- (void)pulse;
- (void)flash;
- (void)stepFromValue:(unsigned int)aFirst toValue:(unsigned int)aLast inIncrement:(unsigned int)aIncrement;
- (void)popUp;
- (void)popDown;
- (void)popDownAfterDelay:(float)aDelay;
- (void)addShadow:(CGSize)size blur:(float)blur color:(ccColor4B)color;


@end
