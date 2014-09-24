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

#import "GameWinAlertView.h"
#import "GameLayer.h"
#import "CCSprite+StretchableImage.h"
#import "nt_button.h"
#import "PackController.h"

@interface GameWinAlertView (Private)

- (void)showStars;

@end

@implementation GameWinAlertView

- (id)initWithStarsEarned:(unsigned int)aStarsEarned coinsCollected:(unsigned int)aCoinsCollected
{
  self = [super initWithContainer:[CCSprite spriteWithStretchableImageNamed:@"stretch_container.png" withLeftCapWidth:18 topCapHeight:20 size:CGSizeMake(400, 300)] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
  if (self) 
  {
    m_starsEarned = aStarsEarned;
    m_coinsCollected = aCoinsCollected;
    
    m_starMeter = [[StarMeter alloc] init];
    m_starMeter.position = CGPointMake(self.container.contentSize.width/2.0f - 82, self.container.contentSize.height - 50 - 10);
    [self.container addChild:m_starMeter];
    self.outsideTouchDismisses = NO;
    
    lCoins = [nt_label labelWithString:@"0" dimensions:CGSizeMake(self.container.contentSize.width/2, 60) alignment:UITextAlignmentRight fontSize:28];
    lCoins.position = CGPointMake(self.container.contentSize.width/2.0f - 75, m_starMeter.position.y - 40);
    [self.container addChild:lCoins];
    
    sCoin = [CCSprite spriteWithFile:@"coin.png"];
    sCoin.position = CGPointMake(self.container.contentSize.width/2.0f, lCoins.position.y);
    sCoin.scale = 0.8;
    [self.container addChild:sCoin];
    
    NSString * receivedString = [NSString stringWithFormat:@"You didn't get any coins :("];
    
    if (aCoinsCollected != 0)
    {
      receivedString = [NSString stringWithFormat:@"You got %i coin%@!\nSpend %@ in the store!", aCoinsCollected, (aCoinsCollected == 1 ? @"" : @"s"), (aCoinsCollected == 1 ? @"it" : @"them")];
    }
    
    lReceived = [nt_label labelWithString:receivedString dimensions:self.container.contentSize alignment:UITextAlignmentCenter fontSize:18];
    lReceived.position = CGPointMake(self.container.contentSize.width/2.0f, lCoins.position.y - 100);
    [self.container addChild:lReceived];
    
    lCoins.opacity = 0.0f;
    sCoin.opacity = 0.0f;
    lReceived.opacity = 0.0f;
    
    [self addButtonImageName:@"menu_button.png" atPosition:CGPointZero];
    [self addButtonImageName:@"retry_button.png" atPosition:CGPointZero];
    
    if (![[PackController sharedPackController] endOfLevels])
    {
      [self addButtonImageName:@"next_button.png" atPosition:CGPointZero];
    }
    
    [self alignMenuItems];
    [self setMenuOffsetFromBottom:40];
  }
  return self;
}


- (void)dealloc
{
  [m_starMeter release];
  [super dealloc];
}


- (void)show:(BOOL)shouldAnimate
{
  [super show:shouldAnimate];
  
  [self performSelector:@selector(showStars) withObject:nil afterDelay:0.4f];
}


- (void)showStars
{
  [lCoins runAction:[CCFadeIn actionWithDuration:0.2f]];
  [sCoin runAction:[CCFadeIn actionWithDuration:0.2f]];
  [lReceived runAction:[CCFadeIn actionWithDuration:0.2f]];
  
  [m_starMeter setStars:m_starsEarned];
  
  [lCoins stepFromValue:0 toValue:m_coinsCollected inIncrement:1];
}


@end
