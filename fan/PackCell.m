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

#import "PackCell.h"
#import "CCSprite+StretchableImage.h"
#import "nt_pack.h"
#import "nt_button.h"

@implementation PackCell

+ (id)layerWithPack:(nt_pack *)aPack
{
  return [[[self alloc] initWithPack:aPack] autorelease];
}


- (id)initWithPack:(nt_pack *)aPack
{
  self = [super initWithText:aPack.name
                      sprite:[CCSprite spriteWithStretchableImageNamed:@"stretch_container.png" withLeftCapWidth:18 topCapHeight:20 size:CGSizeMake(300, 186)]];
  if (self) 
  {
    m_pack = aPack;
    
    m_labelTitle.position = CGPointMake(self.contentSize.width/2.0f, self.contentSize.height - 50);
    
    [m_labelTitle setTextColor:ccWHITE];
    
    m_lStars = [nt_label labelWithString:[NSString stringWithFormat:@"(%i/%i)", m_pack.totalStars, m_pack.totalStarsInLevels] fontSize:24];
    m_lStars.position = CGPointMake(self.contentSize.width/2.0f, m_labelTitle.position.y - 50);
    [m_lStars setTextColor:ccWHITE];
    [self addChild:m_lStars];
    
    m_sStar = [CCSprite spriteWithFile:@"star_big.png"];
    m_sStar.position = CGPointMake(self.contentSize.width/2.0f + 60, m_lStars.position.y - 1);
    m_sStar.scale = 0.7;
    [self addChild:m_sStar];
    
    m_lCoins = [nt_label labelWithString:[NSString stringWithFormat:@"(%i/%i)", m_pack.totalCoinsCollected, m_pack.totalCoinsInLevels] fontSize:24];
    m_lCoins.position = CGPointMake(self.contentSize.width/2.0f, m_lStars.position.y - 50);
    [m_lCoins setTextColor:ccWHITE];
    [self addChild:m_lCoins];
    
    m_sCoin = [CCSprite spriteWithFile:@"coin.png"];
    m_sCoin.position = CGPointMake(self.contentSize.width/2.0f + 60, m_lCoins.position.y - 2);
    m_sCoin.scale = 0.8;
    [self addChild:m_sCoin];
  }
  return self;
}


- (void)dealloc
{
  
  [super dealloc];
}


- (void)makeComingSoon
{
  [self removeChild:m_lStars cleanup:YES];
  [self removeChild:m_sStar cleanup:YES];
  [self removeChild:m_lCoins cleanup:YES];
  [self removeChild:m_sCoin cleanup:YES];
  
  [self setText:@""];
  
  nt_label * lComingSoon = [nt_label labelWithString:@"More Packs\nComing Soon!" dimensions:self.contentSize alignment:UITextAlignmentCenter lineBreakMode:UILineBreakModeWordWrap fontSize:24];
  lComingSoon.position = CGPointMake(self.contentSize.width/2.0f, self.contentSize.height/2.0f);
  [lComingSoon setTextColor:ccWHITE];
  [self addChild:lComingSoon];
}


@end
