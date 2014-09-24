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

#import "UpgradeCell.h"
#import "nt_label.h"
#import "CCSprite+StretchableImage.h"
#import "nt_alertview_stretchable.h"

@implementation UpgradeCell

+ (id)cellWithUpgrade:(nt_upgrade *)aUpgrade
{
  return [[[self alloc] initWithUpgrade:aUpgrade] autorelease];
}

- (id)initWithUpgrade:(nt_upgrade *)aUpgrade
{
  self = [super initWithText:aUpgrade.title sprite:[CCSprite spriteWithStretchableImageNamed:@"stretch_container.png" withLeftCapWidth:18 topCapHeight:20 size:CGSizeMake(300, 186)]];
  if (self) 
  {
    m_labelTitle.position = CGPointMake(m_labelTitle.position.x, m_labelTitle.position.y + 50);
    
    m_upgrade = aUpgrade;
    
    m_lLevel = [[nt_label alloc] initWithString:@"Level: 0" fontSize:24];
    m_lLevel.position = CGPointMake(self.contentSize.width/2.0f, 100);
    [m_lLevel setTextColor:ccWHITE];
    [self addChild:m_lLevel];
    
    m_lCost = [[nt_label alloc] initWithString:@"0" dimensions:CGSizeMake(self.contentSize.width/2.0f, 60) alignment:UITextAlignmentRight fontSize:24];
    m_lCost.position = CGPointMake(self.contentSize.width/2.0f - m_lCost.contentSize.width/2.0f, m_lLevel.position.y - 50);
    [m_lCost setTextColor:ccWHITE];
    [self addChild:m_lCost];
    
    m_sCoin = [CCSprite spriteWithFile:@"coin.png"];
    m_sCoin.position = CGPointMake(self.contentSize.width/2.0f + 20, m_lCost.position.y);
    m_sCoin.scale = 0.8;
    [self addChild:m_sCoin];
    
    m_preview = [CCSprite spriteWithFile:aUpgrade.preview];
    m_preview.position = CGPointMake(10 + m_preview.contentSize.width/2.0f, self.contentSize.height/2.0f);
    [self addChild:m_preview];
    
    nt_buttonitem * info = [nt_buttonitem itemFromNormalSprite:[CCSprite spriteWithFile:@"info_button.png"] target:self selector:@selector(showInfo)];
    info.position = CGPointMake(self.contentSize.width - 20, self.contentSize.height - 20);
    [self addSubMenuItem:info];
    
    [self update];
  }
  return self;
}


- (void)dealloc
{
  [m_lLevel release];
  [super dealloc];
}


- (void)update
{
  if (m_upgrade.isMaxed)
  {
    [m_lLevel setString:@"Maxed Out"];
    [m_lCost setString:@""];
    m_sCoin.visible = NO;
    m_preview.visible = NO;
  }
  else
  {
    [m_lLevel setString:[NSString stringWithFormat:@"Level: %i", m_upgrade.level]];
    [m_lCost setString:[NSString stringWithFormat:@"%i Coins", [m_upgrade currentPrice]]];
    m_sCoin.visible = YES;
    m_preview.visible = YES;
  }
}


- (void)showInfo
{
  nt_alertview_stretchable * alert = [[nt_alertview_stretchable alloc] initWithMessage:m_upgrade.info stretchableImageNamed:@"stretch_container.png" bottomOffset:0 delegate:nil];
  [alert setTextColor:ccWHITE];
  [alert show];
  [alert release];
}


@end
