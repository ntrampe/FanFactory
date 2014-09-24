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

#import "nt_alertBanner.h"
#import "ntt_config.h"

@implementation nt_alertBanner

- (id)initWithMessage:(NSString *)aMessage height:(float)aHeight delegate:(id)aDelegate
{
  float width = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 320 : 180);
  
  self = [super initWithColor:ccc4(0, 0, 0, 150) size:[nt_alertview containerSizeForMessage:aMessage andMaxWidth:width] message:aMessage delegate:aDelegate cancelButtonTitle:nil otherButtonTitles:nil];
  if (self)
  {
    [self setTextColor:ccWHITE];
    [self setPresentationStyle:kAlertViewPresentationStyleCoverRight];
    [self setAlertHeight:aHeight];
    m_black.visible = NO;
    self.cancelsMenuTouches = NO;
    m_time = 0;
  }
  return self;
}


- (void)dealloc
{
  if (m_timer != nil)
  {
    [m_timer release];
    m_timer = nil;
  }
  [super dealloc];
}


- (void)setAlertHeight:(float)aHeight
{
  [self setDisplayPosition:CGPointMake(self.screenSize.width - self.container.contentSize.width, aHeight - self.container.contentSize.height/2.0f)];
}


- (void)addTime:(float)aTimeInSeconds
{
  if (aTimeInSeconds <= 0)
    return;
  
  self.outsideTouchDismisses = NO;
  
  if (m_timer == nil)
  {
    CCSprite * s = [[CCSprite alloc] initWithFile:@"timer.png"];
    m_timer = [[CCProgressTimer alloc] initWithSprite:s];
    [m_timer setType:kCCProgressTimerTypeRadial];
    m_timer.position = CGPointMake(m_timer.contentSize.width/2.0f + 2, m_timer.contentSize.height/2.0f + 2);
    [m_container addChild:m_timer];
    [s release];
  }
  
  [m_timer setPercentage:100];
  m_time = aTimeInSeconds;
}


- (void)show:(BOOL)shouldAnimate
{
  [super show:shouldAnimate];
  
  if (m_timer != nil)
  {
    CCActionTween * rot = [CCActionTween actionWithDuration:m_time key:@"percentage" from:100 to:0];
    CCCallBlock * ret = [CCCallBlock actionWithBlock:^{self.outsideTouchDismisses = YES;}];
    [m_timer runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:(shouldAnimate ? ALERT_SHOW_TIME : 0)] two:[CCSequence actionOne:rot two:ret]]];
  }
}


@end
