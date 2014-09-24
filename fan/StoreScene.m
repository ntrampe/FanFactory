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

#import "StoreScene.h"
#import "nt_label.h"
#import "GameController.h"
#import "PackController.h"
#import "GameKitHelper.h"
#import "UpgradeCell.h"
#import "CCSprite+StretchableImage.h"
#import "nt_iaphelper.h"

@implementation StoreScene

+ (CCScene *) scene
{
  CCScene *scene = [CCScene node];
	
	StoreScene * layer = [StoreScene node];
  
  [scene addChild:layer];
	
	return scene;
}

- (id)init
{
  self = [super init];
  if (self) 
  {
    sharedGC = [GameController sharedGameController];
    sharedPC = [PackController sharedPackController];
    
    //[sharedGC resetData];
    
    m_data = [[CCArray alloc] init];
    
    [m_data addObjectsFromNSArray:sharedGC.upgrades];
    
    m_selectionLayer = [[nt_scrollSelectionLayer alloc] init];
    m_selectionLayer.selectionDelegate = self;
    [self addChild:m_selectionLayer];
    
    m_lCoins = [nt_label labelWithString:@"Coins 00000" fontSize:24];
    m_lCoins.position = CGPointMake(self.screenCenter.x, m_lCoins.contentSize.height);
    [m_lCoins setTextColor:ccWHITE];
    [self addChild:m_lCoins];
    
    CCSprite * s = [CCSprite spriteWithStretchableImageNamed:@"stretch_container.png" withLeftCapWidth:18 topCapHeight:20 size:CGSizeMake(m_lCoins.contentSize.width + 20, 50)];
    s.position = m_lCoins.position;
    [self addChild:s z:-1];
    
    [self updateStoreInfo];
    [self scheduleUpdate];
  }
  return self;
}


- (void)dealloc
{
  [m_data release];
  [m_selectionLayer release];
  [super dealloc];
}


- (void)onEnter
{
  [super onEnter];
  
}


- (void)onExit
{
  [super onExit];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)update:(ccTime)dt
{
  self.velocity = m_selectionLayer.velocity;
}


- (void)updateStoreInfo
{
  [m_lCoins setString:[NSString stringWithFormat:@"Coins: %i", sharedPC.coins]];
}


- (void)coinapalooza
{
  CCParticleSystemQuad * p = [[CCParticleSystemQuad alloc] initWithFile:@"coins.plist"];
  p.position = m_lCoins.position;
  [self addChild:p z:5];
  p.autoRemoveOnFinish = YES;
  [p release];
}


- (void)goToMoreCoins
{
  m_oldCoins = sharedPC.coins;
  
  MoreCoinsViewController * v = [[MoreCoinsViewController alloc] init];
  v.delegate = self;
  v.modalPresentationStyle = UIModalPresentationFormSheet;
  [self presentViewController:v animated:YES];
  [v release];
}


- (void)moreCoinsViewControllerDidFinish:(MoreCoinsViewController *)sender
{
  [self updateStoreInfo];
  
  if (m_oldCoins != sharedPC.coins)
  {
    [self coinapalooza];
  }
}


- (void)upgradeItemIndex:(int)aIndex
{
  nt_upgrade * up = [m_data objectAtIndex:aIndex-1];
  if (!up.isMaxed)
  {
    if ([up upgrade])
    {
      [m_selectionLayer reloadData];
      [sharedGC saveData];
      [self coinapalooza];
      
      [[GameKitHelper sharedGameKitHelper] reportAchievementSuffix:@"fullyupgraded" percentComplete:[sharedGC percentOfUpgradesUnlocked]];
    }
    else
    {
      ConfirmPopUp * p = [[ConfirmPopUp alloc] initWithMessage:@"You do not have enough coins to unlock this upgrade.\n\nWould you like to get more?" delegate:self];
      p.tag = -1;
      [p show];
      [p release];
    }
  }
  
  [self updateStoreInfo];
}


- (void)selectionLayer:(nt_scrollSelectionLayer *)selectionLayer didSelectCell:(nt_scrollSelectionCell *)cell atIndex:(NSInteger)index
{
  if (index > 0)
  {
    nt_upgrade * up = [m_data objectAtIndex:index-1];
    
    if (!up.isMaxed)
    {
      ConfirmPopUp * p = [[ConfirmPopUp alloc] initWithMessage:[NSString stringWithFormat:@"Upgrade %@ to level %i for %i coins?", up.title, up.level+1, up.currentPrice] delegate:self];
      p.tag = index;
      [p show];
      [p release];
    }
  }
  else
  {
    NSLog(@"App Store Retrieval");
    [self goToMoreCoins];
    [sharedPC saveData];
  }
  
  [self updateStoreInfo];
}


- (CGFloat)selectionLayerWidthOffset:(nt_scrollSelectionLayer *)selectionLayer
{
  return 40.0f;
}


- (NSInteger)numberOfCellsInSelectionLayer:(nt_scrollSelectionLayer *)selectionLayer
{
  return [m_data count] + 1;
}


- (nt_scrollSelectionCell *)selectionLayer:(nt_scrollSelectionLayer *)selectionLayer cellForIndex:(NSInteger)index
{
  if (index > 0)
  {
    UpgradeCell * cell = [UpgradeCell cellWithUpgrade:[m_data objectAtIndex:index-1]];
    return cell;
  }
  else
  {
    nt_scrollSelectionCell * cell = [nt_scrollSelectionCell cellWithText:@"Get More Coins!" sprite:[CCSprite spriteWithStretchableImageNamed:@"stretch_container.png" withLeftCapWidth:18 topCapHeight:20 size:CGSizeMake(300, 186)]];
    return cell;
  }
}


- (void)ntalertView:(nt_alertview *)sender didFinishWithButtonIndex:(int)buttonIndex
{
  if (sender.tag == -1)
  {
    if (buttonIndex == 1)
    {
      [self goToMoreCoins];
    }
  }
  else
  {
    if (buttonIndex == 1)
    {
      [self upgradeItemIndex:sender.tag];
    }
  }
}


@end
