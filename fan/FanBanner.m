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

#import "FanBanner.h"
#import "ntt_config.h"
#import "CCSprite+StretchableImage.h"

@implementation FanBanner

- (id)initWithMessage:(NSString *)aMessage height:(float)aHeight delegate:(id)aDelegate
{
  float width = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 320 : 180);
  
  UIFont *   font = [UIFont fontWithName:FONT_NAME size:[nt_alertview fontSize]];
  CGSize textSize = [aMessage sizeWithFont:font constrainedToSize:CGSizeMake(width - TEXT_OFFSET, self.screenSize.height) lineBreakMode:UILineBreakModeWordWrap];
  
  CCSprite * s = [CCSprite spriteWithStretchableImageNamed:@"stretch_container_straight.png" withLeftCapWidth:18 topCapHeight:20 size:CGSizeMake(width, textSize.height + [nt_alertview fontSize])];
  self = [super initWithContainer:s message:aMessage delegate:aDelegate cancelButtonTitle:nil otherButtonTitles:nil];
  
  if (self)
  {
    [self setTextColor:ccWHITE];
    [self setPresentationStyle:kAlertViewPresentationStyleCoverRight];
    [self setAlertHeight:aHeight];
    m_black.visible = NO;
    self.cancelsMenuTouches = NO;
    //self.outsideTouchDismisses = NO;
  }
  return self;
}


- (void)dealloc
{
  
  [super dealloc];
}


- (void)setAlertHeight:(float)aHeight
{
  [self setDisplayPosition:CGPointMake(self.screenSize.width - self.container.contentSize.width/2.0f, aHeight)];
}


@end
