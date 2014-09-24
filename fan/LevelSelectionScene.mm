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

#import "LevelSelectionScene.h"
#import "PackController.h"
#import "nt_button.h"
#import "nt_pack.h"
#import "nt_level.h"
#import "nt_leveldata.h"
#import "GameScene.h"
#import "CCSprite+StretchableImage.h"
#import "config.h"
#import "nt_alertBanner.h"

@interface LevelSelectionScene (Private)

- (void)updateLevels;
- (void)actuallyGoToLevel;

@end

@implementation LevelSelectionScene

+ (CCScene *)sceneWithPack:(nt_pack *)aPack
{
  CCScene *scene = [CCScene node];
	
	LevelSelectionScene * layer = [[LevelSelectionScene alloc] initWithPack:aPack];
  
  [scene addChild:layer];
  
  [layer release];
	
	return scene;
}

- (id)initWithPack:(nt_pack *)aPack
{
  self = [super init];
  if (self) 
  { 
    sharedPC = [PackController sharedPackController];
    m_pack = aPack;
    
    m_menu = [CCMenu menuWithItems:nil];
    m_menu.position = self.screenCenter;
    [self addChild:m_menu];
    
    for (int x = 0; x < m_pack.numberOfLevels; x++)
    {
      CCSprite * button_bg = [CCSprite spriteWithStretchableImageNamed:@"stretch_container_no_screws.png" withLeftCapWidth:18 topCapHeight:20 size:CGSizeMake(52, 61)];
      nt_buttonitem * button = [nt_buttonitem buttonWithText:[NSString stringWithFormat:@"%i", x+1] sprite:button_bg target:self selector:@selector(goToLevel:)];
      button.tag = x;
      
      [m_menu addChild:button];
    }
    
    if (m_pack.numberOfLevels == LEVELS_PER_PACK)
    {
      [m_menu alignItemsInColumns:[NSNumber numberWithInt:6], [NSNumber numberWithInt:6], [NSNumber numberWithInt:6], [NSNumber numberWithInt:6], nil];
    }
    else
    {
      NSLog(@"ERROR: There should be %i levels not %i levels.", LEVELS_PER_PACK, m_pack.numberOfLevels);
    }
    
    m_levelsUpdated = NO;
    
    [self updateLevels];
  }
  return self;
}


- (void)dealloc
{
  
  [super dealloc];
}


- (void)onEnterTransitionDidFinish
{
  [super onEnterTransitionDidFinish];
  [self showSprites];
  
  [self scheduleOnce:@selector(updateLevels) delay:0.4f];
}


- (void)onExit
{
  [super onExit];
  m_levelsUpdated = NO;
}


- (void)updateWithPack:(nt_pack *)aPack
{
  if (m_pack.numberOfLevels != aPack.numberOfLevels)
    return;
  
  m_pack = aPack;
  
  m_levelsUpdated = NO;
  
  [self updateLevels];
}


- (void)goToLevel:(nt_buttonitem *)sender
{
  if (sender.tag <= m_pack.highestAvailableLevel)
  {
    [sharedPC setCurrentLevel:sender.tag];
    [self hideSpritesStartingFromNode:self.parent.parent animated:YES];
    [self scheduleOnce:@selector(actuallyGoToLevel) delay:0.4f];
  }
  else
  {
    [nt_alertBanner removeAllAlertViews];
    
    nt_alertBanner * alert = [[nt_alertBanner alloc] initWithMessage:@"This level is locked.\nTry completing the one before it." height:self.screenSize.height/2.0f delegate:nil];
    alert.cancelsMenuTouches = NO;
    [alert setAlertHeight:self.screenSize.height - 20 - alert.container.contentSize.height/2.0f];
    [alert show];
    [alert release];
  }
}


- (void)fadeIn
{
  for (nt_buttonitem * b in m_menu.children)
  {
    b.opacity = 0.0f;
    [b runAction:[CCFadeIn actionWithDuration:0.4f]];
  }
}


- (void)fadeOut
{
  for (nt_buttonitem * b in m_menu.children)
  {
    b.opacity = 255.0f;
    [b runAction:[CCEaseSineInOut actionWithAction:[CCFadeOut actionWithDuration:0.4f]]];
  }
}


- (void)updateLevels
{
  if (m_levelsUpdated)
    return;
  
  for (nt_buttonitem * b in m_menu.children)
  {
    CCArray * starSprites = [CCArray array];
    
    //get star sprites
    for (CCSprite * s in b.children)
      if (s.tag == 99)
        [starSprites addObject:s];
    
    //remove star sprites
    for (CCSprite * s in starSprites)
      [b removeChild:s cleanup:YES];
    
    int stars = [m_pack levelDataForNumber:b.tag].stars;
    
    for (int i = 0; i < 3; i++)
    {
      CCSprite * s = [CCSprite spriteWithFile:(i < stars ? @"star.png" : @"nostar.png")];
      s.tag = 99;
      s.position = CGPointMake(s.contentSize.width*(i+1) - s.contentSize.width/2 + 2, s.contentSize.height/2 + 2*CC_CONTENT_SCALE_FACTOR());
      s.opacity = 0.0f;
      [b addChild:s];
      [s runAction:[CCFadeTo actionWithDuration:0.4f opacity:255.0f]];
    }
    
    if (!(b.tag <= m_pack.highestAvailableLevel))
    {
      [b runAction:[CCFadeTo actionWithDuration:0.4f opacity:150.0f]];
      [b setIsEnabled:NO];
    }
    else
    {
      b.opacity = 255.0f;
      [b setIsEnabled:YES];
    }
  }
  
  m_levelsUpdated = YES;
}


- (void)actuallyGoToLevel
{
  [self goToScene:[GameScene sceneWithLevel:[sharedPC currentLevel]] animate:NO];
}


@end
