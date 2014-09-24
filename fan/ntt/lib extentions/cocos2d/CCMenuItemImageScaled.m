/*
 * Copyright (c) 2012 Nicholas Trampe
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

#import "CCMenuItemImageScaled.h"
#define kZoomInActionTag 1
#define kZoomOutActionTag 2

@implementation CCMenuItemImageScaled


+ (id)itemFromNormalSprite:(CCNode<CCRGBAProtocol> *)normalSprite target:(id)target selector:(SEL)selector
{
  return [[[self alloc] initWithNormalSprite:normalSprite target:target selector:selector] autorelease];
}


+ (id)itemFromNormalImage:(NSString *)normalImage target:(id)target selector:(SEL)selector
{
  return [[[self alloc] initWithNormalImage:normalImage target:target selector:selector] autorelease];
}


+ (id)itemFromNormalSprite:(CCNode<CCRGBAProtocol> *)normalSprite block:(void(^)(id sender))block
{
  return [[[self alloc] initWithNormalSprite:normalSprite block:block] autorelease];
}


+ (id)itemFromNormalImage:(NSString *)normalImage block:(void(^)(id sender))block
{
  return [[[self alloc] initWithNormalImage:normalImage block:block] autorelease];
}


- (id)initWithNormalSprite:(CCNode<CCRGBAProtocol> *)normalSprite target:(id)target selector:(SEL)selector
{
  self = [super initWithNormalSprite:normalSprite selectedSprite:nil disabledSprite:nil target:target selector:selector];
  if (self)
  {
    originalScale = self.scale;
  }
  return self;
}


- (id)initWithNormalImage:(NSString *)normalImage target:(id)target selector:(SEL)selector
{
  self = [super initWithNormalImage:normalImage selectedImage:nil disabledImage:nil target:target selector:selector];
  if (self)
  {
    originalScale = self.scale;
  }
  return self;
}


- (id)initWithNormalSprite:(CCNode<CCRGBAProtocol> *)normalSprite block:(void(^)(id sender))block
{
  self = [super initWithNormalSprite:normalSprite selectedSprite:nil disabledSprite:nil block:block];
  if (self)
  {
    originalScale = self.scale;
  }
  return self;
}


- (id)initWithNormalImage:(NSString *)normalImage block:(void(^)(id sender))block
{
  self = [super initWithNormalImage:normalImage selectedImage:nil disabledImage:nil block:block];
  if (self)
  {
    originalScale = self.scale;
  }
  return self;
}


- (void)selected
{
  // subclass to change the default action
  [super selected];
  if(isEnabled_)
  {
    [self stopActionByTag:kZoomInActionTag];
    CCAction *zoomAction = [CCScaleTo actionWithDuration:0.1f scale:originalScale*1.1f];
    zoomAction.tag = kZoomInActionTag;
    [self runAction:zoomAction];
  }
}


- (void)unselected
{
  // subclass to change the default action
  [super unselected];
  if(isEnabled_)
  {
    [self stopActionByTag:kZoomOutActionTag];
    CCAction *zoomAction = [CCScaleTo actionWithDuration:0.1f scale:originalScale];
    zoomAction.tag = kZoomOutActionTag;
    [self runAction:zoomAction];
  }
}


- (void)setScale:(float)scale
{
  originalScale = scale;
  [super setScale:scale];
}


@end
