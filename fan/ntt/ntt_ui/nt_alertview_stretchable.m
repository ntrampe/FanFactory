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

#import "nt_alertview_stretchable.h"
#import "CCSprite+StretchableImage.h"
#import "ntt_config.h"

@implementation nt_alertview_stretchable

- (id)initWithMessage:(NSString *)aMessage stretchableImageNamed:(NSString *)aStretchableImageName bottomOffset:(float)aOffset delegate:(id)aDelegate
{
  CGSize size = [nt_alertview containerSizeForMessage:aMessage];
  
  self = [super initWithContainer:[CCSprite spriteWithStretchableImageNamed:aStretchableImageName withLeftCapWidth:20 topCapHeight:20 size:CGSizeMake(size.width, size.height + aOffset)] message:aMessage delegate:aDelegate cancelButtonTitle:nil otherButtonTitles:nil];
  if (self) 
  {
    
  }
  return self;
}


- (void)dealloc
{
  
  [super dealloc];
}


@end
