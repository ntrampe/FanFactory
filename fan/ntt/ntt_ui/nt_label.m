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

#import "nt_label.h"
#import "CCTexture2D+TextShadow.h"
#import "ccMacros.h"
#import "ntt_macros.h"
#import "ntt_config.h"

@interface nt_label (Private)

- (void)setUp;

@end

@implementation nt_label
@synthesize isShowing = m_showing;

+ (id)labelWithString:(NSString *)string fontSize:(CGFloat)size
{
  return [[[self alloc] initWithString:string fontSize:size] autorelease];
}


- (id)initWithString:(NSString *)string fontSize:(CGFloat)size
{
  self = [super initWithString:string fontName:FONT_NAME fontSize:size*CC_CONTENT_SCALE_FACTOR()];
  if (self)
  {
    [self setUp];
  }
  return self;
}


+ (id)labelWithString:(NSString *)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontSize:(CGFloat)size
{
  return [[[self alloc] initWithString:string dimensions:dimensions alignment:alignment fontSize:size] autorelease];
}


- (id)initWithString:(NSString *)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontSize:(CGFloat)size
{
  self = [super initWithString:string dimensions:dimensions hAlignment:alignment fontName:FONT_NAME fontSize:size*CC_CONTENT_SCALE_FACTOR()];
  if (self)
  {
    [self setUp];
  }
  return self;
}


+ (id)labelWithString:(NSString *)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment lineBreakMode:(UILineBreakMode)lineBreakMode fontSize:(CGFloat)size
{
  return [[[self alloc] initWithString:string dimensions:dimensions alignment:alignment lineBreakMode:lineBreakMode fontSize:size] autorelease];
}


- (id)initWithString:(NSString *)str dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment lineBreakMode:(UILineBreakMode)lineBreakMode fontSize:(CGFloat)size
{
  self = [super initWithString:str dimensions:dimensions hAlignment:alignment lineBreakMode:lineBreakMode fontName:FONT_NAME fontSize:size*CC_CONTENT_SCALE_FACTOR()];
  if (self)
  {
    [self setUp];
  }
  return self;
}


- (void)setTextColor:(ccColor3B)aColor
{
  [self setColor:aColor];
  [self addShadow:CGSizeMake(0, 0) blur:0 color:ccc4(0, 0, 0, 0)];
}


- (void)pulse
{
  CCSequence * seq = [CCSequence actions:[CCScaleTo actionWithDuration:0.6 scale:1.1], [CCScaleTo actionWithDuration:0.5 scale:1], [CCScaleTo actionWithDuration:0.1 scale:1], nil];
  CCRepeatForever * act = [CCRepeatForever actionWithAction:seq];
  [self runAction:act];
}


- (void)flash
{
  CCSequence * seq = [CCSequence actions:[CCTintTo actionWithDuration:0.6 red:255 green:0 blue:0], [CCTintTo actionWithDuration:0.5 red:255 green:255 blue:255], [CCTintTo actionWithDuration:0.2 red:255 green:255 blue:255], nil];
  CCRepeatForever * act = [CCRepeatForever actionWithAction:seq];
  [self runAction:act];
}


- (void)stepFromValue:(unsigned int)aFirst toValue:(unsigned int)aLast inIncrement:(unsigned int)aIncrement
{
  if (aFirst > 0 && aFirst-aIncrement >= aLast)
  {
    [self setString:[NSString stringWithFormat:@"%i", aLast]];
    return;
  }
  
  [self setString:[NSString stringWithFormat:@"%i", aFirst]];
  CCAction * act = [CCSequence actions:[CCScaleTo actionWithDuration:0.04 scale:1.5],
                    [CCScaleTo actionWithDuration:0.02 scale:1.0],
                    [CCCallBlock actionWithBlock:^
                    {
                      [self stepFromValue:aFirst+aIncrement toValue:aLast inIncrement:aIncrement];
                    }],
                    nil];
  [self runAction:act];
}


- (void)popUp
{
  if (!self.isShowing)
  {
    self.scale = 0.00001;
    id scale1 = [CCScaleTo actionWithDuration:0.1 scale:1.2];
    id scale2 = [CCScaleTo actionWithDuration:0.05 scale:1.0];
    CCSequence * show = [CCSequence actions:scale1, scale2, nil];
    [self runAction:show];
    m_showing = YES;
  }
}


- (void)popDown
{
  [self popDownAfterDelay:0.0f];
}


- (void)popDownAfterDelay:(float)aDelay
{
  if (self.isShowing)
  {
    id pause = [CCScaleTo actionWithDuration:0.2 scale:1.0];
    id scale3 = [CCScaleTo actionWithDuration:0.1 scale:0.00001];
    CCSequence * remove = [CCSequence actions:pause, scale3, nil];
    [self performSelector:@selector(runAction:) withObject:remove afterDelay:aDelay];
    m_showing = NO;
  }
}


- (void)addShadow:(CGSize)size blur:(float)blur color:(ccColor4B)color;
{
  self.position = CGPointMake(self.position.x - size.width, self.position.y - size.height); //to compensate for shadow
  m_fillColor = self.color;
  m_shadowOffset = CGSizeMake(size.width * CC_CONTENT_SCALE_FACTOR(), size.height*CC_CONTENT_SCALE_FACTOR());
  m_shadowBlur = SIGNCHECK(blur* CC_CONTENT_SCALE_FACTOR());
  m_shadowColor = color;
  [self setString:self.string];
}


- (void) setString:(NSString*)str
{
	[string_ release];
	string_ = [str copy];
  
	CCTexture2D *tex;
	if( CGSizeEqualToSize( dimensions_, CGSizeZero ) )
  {
    ccColor4F sColor4F = ccc4FFromccc4B(m_shadowColor);
    ccColor4F fColor4F = ccc4FFromccc3B(m_fillColor);
    
    float sColor[4] = {sColor4F.r, sColor4F.g, sColor4F.b, sColor4F.a};
    float fColor[4] = {fColor4F.r, fColor4F.g, fColor4F.b, fColor4F.a};
    
    tex = [[CCTexture2D alloc] initWithString:str
                                     fontName:fontName_
                                     fontSize:fontSize_
                                 shadowOffset:m_shadowOffset
                                   shadowBlur:m_shadowBlur
                                  shadowColor:sColor
                                    fillColor:fColor];
  }
	else
  {
    ccColor4F sColor4F = ccc4FFromccc4B(m_shadowColor);
    ccColor4F fColor4F = ccc4FFromccc3B(m_fillColor);
    
    float sColor[4] = {sColor4F.r, sColor4F.g, sColor4F.b, sColor4F.a};
    float fColor[4] = {fColor4F.r, fColor4F.g, fColor4F.b, fColor4F.a};
    
    tex = [[CCTexture2D alloc] initWithString:str
                                   dimensions:dimensions_
                                    alignment:hAlignment_
                                     fontName:fontName_
                                     fontSize:fontSize_
                                 shadowOffset:m_shadowOffset
                                   shadowBlur:m_shadowBlur
                                  shadowColor:sColor
                                    fillColor:fColor];
  }
  
	[self setTexture:tex];
	[tex release];
  
	CGRect rect = CGRectZero;
	rect.size = [texture_ contentSize];
	[self setTextureRect: rect];
}


- (void)setShadowColor:(ccColor4B)shadowColor
{
  m_shadowColor = shadowColor;
  [self setString:string_];
}


- (void)setColor:(ccColor3B)color
{
  [super setColor:color];
  m_fillColor = color;
}


- (void)setUp
{
  self.color = ccBLACK;
  [self addShadow:CGSizeMake(0, 0) blur:0 color:ccc4(0, 0, 0, 0)];
  m_showing = YES;
}


@end
