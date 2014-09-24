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

#import "CCSprite+StretchableImage.h"

@implementation CCSprite (Stretchable)

+ (id)spriteWithStretchableImageNamed:(NSString *)aName withLeftCapWidth:(NSInteger)aLeft topCapHeight:(NSInteger)aTop size:(CGSize)aSize
{
  return [[[self alloc] initWithStretchableImageNamed:aName withLeftCapWidth:aLeft topCapHeight:aTop size:aSize] autorelease];
}


- (id)initWithStretchableImageNamed:(NSString *)aName withLeftCapWidth:(NSInteger)aLeft topCapHeight:(NSInteger)aTop size:(CGSize)aSize
{
  BOOL retina = CC_CONTENT_SCALE_FACTOR() != 1;
  if (retina)
  {
    aName = [aName stringByReplacingOccurrencesOfString:@"." withString:@"-hd."];
    aSize.width *= CC_CONTENT_SCALE_FACTOR();
    aSize.height *= CC_CONTENT_SCALE_FACTOR();
  }
  
  UIImage * image = [[UIImage imageNamed:aName] stretchableImageWithLeftCapWidth:aLeft topCapHeight:aTop];
  UIGraphicsBeginImageContextWithOptions(CGSizeMake(aSize.width, aSize.height), NO, 1.0f);
  [image drawInRect:CGRectMake(0, 0, aSize.width, aSize.height)];
  UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  CCTexture2D * tex = [[CCTextureCache sharedTextureCache] addCGImage:newImage.CGImage forKey:[NSString stringWithFormat:@"%@_%f_%f", aName, aSize.width, aSize.height]];
  
  return [self initWithTexture:tex];
}

@end
