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

#import "MenuScene.h"
#import "nt_button.h"
#import "GameScene.h"
#import "LevelEditSelectionScene.h"
#import "StoreScene.h"
#import "SettingsController.h"
#import "SettingsViewController.h"
#import "TestScene.h"
#import "AppDelegate.h"
#import "nt_pack.h"
#import "PackSelectionScene.h"
#import "PackController.h"
#import "DataController.h"
#import "CCSprite+StretchableImage.h"
#import "nt_alertBanner.h"
#import "CreditsAlert.h"

static BOOL first = YES;

@implementation MenuScene

+ (CCScene *) scene
{
  CCScene *scene = [CCScene node];
	
	MenuScene * layer = [MenuScene node];
  
  [scene addChild:layer];
	
	return scene;
}

- (id)init
{
  self = [super init];
  if (self) 
  {
    [self setBackGroundColor:ccc4(200, 200, 200, 255)];
    
    sharedSC = [SettingsController sharedSettingsController];
    sharedPC = [PackController sharedPackController];
    
    m_menu = [[CCLayer alloc] init];
    [self addChild:m_menu];
    
    m_moving = YES;
    
    CCMenuItemFont * play = [CCMenuItemFont itemWithString:@"Play" block:^(id sender)
                             { 
                               PackSelectionScene * l = [[PackSelectionScene alloc] init];
                               l.delegate = self;
                               [self goToSubLayer:l];
                               [l release];
                               
//                               [self goToScene:[PackSelectionScene scene]];
                             }];
    CCMenuItemFont * edit = [CCMenuItemFont itemWithString:@"Create" block:^(id sender)
                             {
                               if ([[DataController sharedDataController] hasCloudAccess])
                               {
                                 if (sharedSC.tutorial)
                                 {
                                   nt_alertBanner * alert = [[nt_alertBanner alloc] initWithMessage:@"Try to play a game before creating one." height:self.screenSize.height/2.0f delegate:nil];
                                   alert.cancelsMenuTouches = YES;
                                   [alert show];
                                   [alert release];
                                 }
                                 else
                                 {
                                   LevelEditSelectionScene * l = [[LevelEditSelectionScene alloc] init];
                                   [self goToSubLayer:l];
                                   [l release];
                                 }
                               }
                               else
                               {
                                 nt_alertview_stretchable * alert = [[nt_alertview_stretchable alloc] initWithMessage:@"You Do Not Have iCloud Documents & Data Enabled.\nTo turn it on, go to \"Settings->iCloud->Documents & Data\" and switch it on. If you do have iCloud turned on, please try again in a moment." stretchableImageNamed:@"stretch_container.png" bottomOffset:0 delegate:nil];
                                 [alert setTextColor:ccWHITE];
                                 [alert show];
                                 [alert release];
                               }
                             }];
    
    CCMenuItemFont * store = [CCMenuItemFont itemWithString:@"Store" block:^(id sender)
                              {
                                StoreScene * l = [[StoreScene alloc] init];
                                [self goToSubLayer:l];
                                [l release];
                              }];
    
    CCMenuItemFont * set   = [CCMenuItemFont itemWithString:@"Game Center" block:^(id sender)
                              {
                                SettingsViewController * v = [[SettingsViewController alloc] init];
                                v.modalPresentationStyle = UIModalPresentationFormSheet;
                                [self presentViewController:v animated:YES];
                                [v release];
//                                [[GameKitHelper sharedGameKitHelper] showAchievements];
                              }];
    
    CCMenuItemFont * cred = [CCMenuItemFont itemWithString:@"Credits" block:^(id sender)
                             {
                               CreditsAlert * alert = [[CreditsAlert alloc] init];
                               [alert show];
                               [alert release];
                             }];
    
    CCSprite * s = [CCSprite spriteWithStretchableImageNamed:@"stretch_container.png" withLeftCapWidth:18 topCapHeight:20 size:CGSizeMake(210, 220)];
    [m_menu addChild:s];
    
    m_logo = [[CCSprite alloc] initWithFile:@"logo.png"];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
      m_logo.scale = 250 / m_logo.contentSize.width;
      s.position = self.screenCenter;
      m_logo.position = CGPointMake(s.position.x, s.position.y + s.contentSize.height);
    }
    else
    {
      m_logo.scale = (self.screenSize.width/2.0f - 50) / m_logo.contentSize.width;
      s.position = CGPointMake(self.screenSize.width - s.contentSize.width/2.0f - 20, self.screenSize.height/2.0f);
      m_logo.position = CGPointMake(m_logo.contentSize.width*m_logo.scale/2.0f + 20, self.screenSize.height/2.0f);
    }
    
    [self addChild:m_logo];
    
    CCMenu * menu = [CCMenu menuWithItems:play, edit, store, set, cred, nil];
    [menu alignItemsVertically];
    menu.position = s.position;
    [m_menu addChild:menu];
    
    m_parallax = [[ParallaxBackground alloc] init];
    //[m_parallax addGameObjects];
    [self addChild:m_parallax z:-5];
    
    m_menu.position = CGPointMake(m_menu.position.x, m_menu.position.y - self.screenSize.height);
    m_logo.position = CGPointMake(m_logo.position.x, m_logo.position.y + self.screenSize.height);
    
    m_logo.tag = m_menu.tag = DONT_MOVE_SPRITE_TAG;
    
    [self hideSpritesStartingFromNode:self animated:NO];
    
    [self scheduleUpdate];
  }
  return self;
}


- (void)dealloc
{
  [m_logo release];
  [m_menu release];
  [m_parallax release];
  [super dealloc];
}


- (void)onEnterTransitionDidFinish
{
  [super onEnterTransitionDidFinish];
  
  if (first)
  {
    CCAction * moveMenu = [CCMoveBy actionWithDuration:0.4f position:CGPointMake(0, self.screenSize.height)];
    CCAction * moveLogo = [CCMoveBy actionWithDuration:0.4f position:CGPointMake(0, -self.screenSize.height)];
    
    [m_menu runAction:moveMenu];
    [m_logo runAction:moveLogo];
    
    [self showSprites];
    
    [self callBlock:^{m_moving = NO;} afterDelay:0.5f];
    
    first = NO;
  }
  
//  if (sharedSC.firstTime)
//  {
//    [self scheduleOnce:@selector(showWelcome) delay:0.4f];
//    sharedSC.firstTime = NO;
//    [sharedSC saveData];
//  }
}


- (void)update:(ccTime)dt
{
  static float prevX = m_menu.position.x;
  
  if (m_moving)
  {
    m_velocity = m_menu.position.x - prevX;
    prevX = m_menu.position.x;
    
    [m_parallax updateWithVelocity:CGPointMake(m_velocity, 0.0f) AndDelta:dt];
  }
  else
  {
    if (m_subLayer != nil)
    {
      [m_parallax updateWithVelocity:m_subLayer.velocity AndDelta:dt];
    }
    else
    {
      if (m_velocity > -2)
      {
        m_velocity -= 0.01;
      }
      else if (m_velocity < -2)
      {
        m_velocity += 0.01;
      }
      
      [m_parallax updateWithVelocity:CGPointMake(m_velocity, 0) AndDelta:dt];
    }
  }
}


- (void)goToSubLayer:(MenuSubLayer *)aSubLayer
{
  if (m_subLayer)
    return;
  
//  [self removeSubLayer];
  
  [self addBackButtonWithBlock:^(id sender)
   {
     [self goToMenu];
   }];
  
  self.backButton.normalImage.opacity = 0.0f;
  
  m_subLayer = [aSubLayer retain];
  m_subLayer.position = CGPointMake(self.screenSize.width, 0);
  [self addChild:m_subLayer];
  
  [self scheduleOnce:@selector(moveToSubLayer) delay:0.2f];
}


- (void)moveToSubLayer
{
  m_moving = YES;
  //m_velocity = -(self.screenSize.width)/(0.4*50.0f);
  
  
  m_subLayer.clipsToBounds = NO;
  [m_subLayer runAction:[CCEaseBackOut actionWithAction:[CCMoveTo actionWithDuration:0.6f position:CGPointMake(0, 0)]]];
  [m_menu runAction:[CCSequence actionOne:[CCEaseBackOut actionWithAction:[CCMoveBy actionWithDuration:0.6f position:CGPointMake(-self.screenSize.width, 0)]]
                                      two:[CCCallBlockN actionWithBlock:^(CCNode *node) {m_moving = NO; m_subLayer.clipsToBounds = YES;}]]];
  
  [m_logo runAction:[CCEaseBackOut actionWithAction:[CCMoveBy actionWithDuration:0.6f position:CGPointMake(-self.screenSize.width, 0)]]];
  
  [self.backButton.normalImage runAction:[CCFadeIn actionWithDuration:0.6f]];
}


- (void)removeSubLayer
{
  if (m_subLayer != nil)
  {
    if (m_subLayer.parent != nil)
      [m_subLayer removeFromParentAndCleanup:YES];
    [m_subLayer release];
    m_subLayer = nil;
  }
}


- (void)goToMenu
{ 
  if (CGPointEqualToPoint(m_menu.position, self.screenCenter))
    return;
  
  m_moving = YES;
  //m_velocity = (self.screenSize.width)/(0.4*50.0f);
  
  [self performSelector:@selector(removeSubLayer) withObject:nil afterDelay:0.6f];
  
  [m_subLayer runAction:[CCEaseBackOut actionWithAction:[CCMoveTo actionWithDuration:0.6f position:CGPointMake(self.screenSize.width, 0)]]];
  [m_menu runAction:[CCSequence actionOne:[CCEaseBackOut actionWithAction:[CCMoveTo actionWithDuration:0.6f position:CGPointMake(0, 0)]]
                                      two:[CCCallBlockN actionWithBlock:^(CCNode *node) {m_moving = NO;}]]];
  
  [m_logo runAction:[CCEaseBackOut actionWithAction:[CCMoveBy actionWithDuration:0.6f position:CGPointMake(self.screenSize.width, 0)]]];
  
  [self removeBackButton];
}


- (void)showWelcome
{
  nt_alertBanner * a = [[nt_alertBanner alloc] initWithMessage:@"Welcome to the game!" height:self.screenSize.height*3.0f/4.0f delegate:nil];
  a.cancelsMenuTouches = NO;
  [a show];
  [a release];
}


- (void)test
{
  PackSelectionScene * l = [[PackSelectionScene alloc] init];
  l.delegate = self;
  [self goToSubLayer:l];
  [l release];
}


- (void)packSelection:(PackSelectionScene *)packSelectionScene didSelectPack:(int)aPack
{
  [m_back setBlock:^(id sender)
  {
    [packSelectionScene returnToPacks];
  }];
}


- (void)packSelectionDidReturnToPacks:(PackSelectionScene *)packSelectionScene
{
  [m_back setBlock:^(id sender)
   {
     [self goToMenu];
   }];
}


@end
