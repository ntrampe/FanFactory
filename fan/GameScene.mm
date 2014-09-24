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

#import "GameScene.h"
#import "GameController.h"
#import "PackController.h"
#import "SettingsController.h"
#import "MenuScene.h"
#import "nt_b2dsprite.h"
#import "nt_block.h"
#import "nt_label.h"
#import "nt_button.h"
#import "nt_leveldata.h"
#import "GameWinAlertView.h"
#import "GameTutorialScene.h"
#import "GameKitHelper.h"
#import "ConfirmPopUp.h"
#import "config.h"

@interface GameScene (Private)

- (void)handlePauseWithButtonIndex:(int)aButtonIndex;
- (void)handleWinWithButtonIndex:(int)aButtonIndex;
- (void)startMovement;
- (void)goNext;
- (void)goCurrent;

@end

@implementation GameScene


+ (CCScene *)sceneWithLevel:(nt_level *)aLevel
{
  CCScene *scene = [CCScene node];
  
  GameScene * layer = [[GameScene alloc] initWithLevel:aLevel];
  
  [scene addChild:layer];
  
  [layer release];
  
  return scene;
}


- (id)initWithLevel:(nt_level *)aLevel
{
  self = [super initWithLevel:aLevel];
  if (self)
  {
    sharedGC = [GameController sharedGameController];
    sharedPC = [PackController sharedPackController];
    sharedSC = [SettingsController sharedSettingsController];
    
    float scale = max(self.screenSize.width / STANDARD_SCREEN_WIDTH, 0.75);
    
    m_starMeter = [[StarMeter alloc] init];
    m_starMeter.starScale = scale;
    [m_starMeter setStars:3 animated:NO];
    m_starMeter.position = CGPointMake(self.contentSize.width - 175*scale, self.contentSize.height - 58*scale);
    [self addChild:m_starMeter];
    
    
    for (nt_fan * f in m_game.fans)
    {
      [f setMaxPower:sharedGC.fanPower];
    }
    
    [m_game collectCoins:[sharedPC currentLevelCollectedCoins]];
    
    [self hideSpritesStartingFromNode:self animated:NO];
  }
  return self;
}


- (void)dealloc
{
  [m_starMeter release];
	[super dealloc];
}


- (void)onExit
{
  [super onExit];
  sharedGC.testing = NO;
}


- (void)onEnterTransitionDidFinish
{
  [super onEnterTransitionDidFinish];
  
  if (sharedSC.tutorial)
  {
    [self goToScene:[GameTutorialScene scene] animate:NO];
  }
  else
  {
    [self showSprites];
  }
  
  [self scheduleOnce:@selector(startMovement) delay:0.5f];
}


#pragma mark -
#pragma mark Game Layer Delegate


- (void)gameLayerDidStart:(GameLayer *)gameLayer
{
  
}


- (void)gameLayerDidFinish:(GameLayer *)gameLayer
{
  if (sharedGC.testing == NO)
  {
    unsigned int prevCoins = [sharedPC currentLevelCollectedCoins].count;
    unsigned int nextCoins = gameLayer.coinsCollected;
    unsigned int newCoins = (nextCoins > prevCoins ? nextCoins - prevCoins : 0);
    
    GameWinAlertView * alert = [[GameWinAlertView alloc] initWithStarsEarned:gameLayer.starsEarned coinsCollected:newCoins];
    alert.tag = 1;
    alert.delegate = self;
    [alert show];
    
    sharedPC.coins += newCoins;
    [sharedPC setCurrentLevelStars:gameLayer.starsEarned];
    [sharedPC makeCurrentLevelCollectCoins:gameLayer.collectedCoins];
    
    if (sharedPC.currentPackNumber == 0 && sharedPC.currentLevelNumber == 0)
    {
      [[GameKitHelper sharedGameKitHelper] reportAchievementSuffix:@"gettingstarted" percentComplete:100];
    }
    
    [sharedPC saveData];
    
    [alert release];
  }
  else
  {
    [self hideSpritesStartingFromNode:self animated:YES];
    [self scheduleOnce:@selector(goBack) delay:0.4f];
  }
}


- (void)gameLayerDidDie:(GameLayer *)gameLayer
{
  
}


- (void)gameLayerDidReset:(GameLayer *)gameLayer
{
  [m_starMeter setStars:3];
  
  [gameLayer collectCoins:[sharedPC currentLevelCollectedCoins]];
}


- (void)gameLayer:(GameLayer *)gameLayer didKnockOnWood:(uint)aNumberOfTimes
{
  [m_starMeter setStars:gameLayer.starsEarned animated:NO];
}


- (void)gameLayer:(GameLayer *)gameLayer didSmashBlock:(nt_block *)aBlock
{
  
}


- (void)gameLayer:(GameLayer *)gameLayer didEatCoin:(uint)aNumberOfTimes
{
  
}


#pragma mark -
#pragma mark Pause Delegate


- (void)ntalertViewWillShow:(nt_alertview *)sender
{
  [super ntalertViewWillShow:sender];
  
  if (sender.tag == 0)
  {
    for (nt_object * o in m_game.objects)
      [o pauseSchedulerAndActions];
  }
}


- (void)ntalertViewDidHide:(nt_alertview *)sender
{
  [super ntalertViewDidHide:sender];
  
  if (sender.tag == 0)
  {
    for (nt_object * o in m_game.objects)
      [o resumeSchedulerAndActions];
  }
}


- (void)ntalertView:(nt_alertview *)sender didFinishWithButtonIndex:(int)buttonIndex
{
  if (sender.tag == 0)
  {
    //[super ntalertView:sender didFinishWithButtonIndex:buttonIndex];
    [self handlePauseWithButtonIndex:buttonIndex];
  }
  else if (sender.tag == 1)
  {
    [self handleWinWithButtonIndex:buttonIndex];
  }
  else if (sender.tag == 2)
  {
    
  }
  else
  {
    
  }
}


- (void)createMenu
{
  float scale = max(self.screenSize.width / STANDARD_SCREEN_WIDTH, 0.75);
  
  nt_buttonitem *pause = [nt_buttonitem itemFromNormalSprite:[CCSprite spriteWithFile:@"pause_button.png"] block:^(id sender)
                          {
                            nt_pausePopUp * p = [[nt_pausePopUp alloc] initWithDelegate:self];
                            p.tag = 0;
                            [p show];
                            [p release];
                          }];
  
  nt_buttonitem *start = [nt_buttonitem itemFromNormalSprite:[CCSprite spriteWithFile:@"go_button.png"] block:^(id sender)
                          {
                            [m_game start];
                          }];
  
  nt_buttonitem *retry = [nt_buttonitem itemFromNormalSprite:[CCSprite spriteWithFile:@"retry_button.png"] block:^(id sender)
                          {
                            [m_game reset];
                          }];
  
  pause.scale = start.scale = retry.scale = scale;
	
	CCMenu *menu = [CCMenu menuWithItems:pause, start, retry, nil];
	
	[menu alignItemsHorizontallyWithPadding:4];
	
	[menu setPosition:ccp(pause.contentSize.width*scale*1.8f, self.screenSize.height - pause.contentSize.height*scale/2 - 10)];
	
	[self addChild:menu];
}


- (void)handlePauseWithButtonIndex:(int)aButtonIndex
{
  switch (aButtonIndex)
  {
    case 0:
      [m_game reset];
      break;
    case 1:
      [self hideSpritesStartingFromNode:self animated:YES];
      [self scheduleOnce:@selector(goBack) delay:0.4f];
      break;
    case 2:
      
      break;
      
    default:
      break;
  }
}


- (void)handleWinWithButtonIndex:(int)aButtonIndex
{
  [self hideSpritesStartingFromNode:self animated:YES];
  
  switch (aButtonIndex)
  {
    case 0:
      [self scheduleOnce:@selector(goBack) delay:0.4f];
      break;
    case 1:
      [self scheduleOnce:@selector(goCurrent) delay:0.4f];
      break;
    case 2:
      [self scheduleOnce:@selector(goNext) delay:0.4f];
      break;
      
    default:
      break;
  }
}


- (void)startMovement
{
  for (nt_object * o in m_game.objects)
    [o startMovement];
}


- (void)goNext
{
  [self changeScene:[GameScene sceneWithLevel:[sharedPC nextLevel]] animate:NO];
}


- (void)goCurrent
{
  [self changeScene:[GameScene sceneWithLevel:[sharedPC currentLevel]] animate:NO];
}


@end