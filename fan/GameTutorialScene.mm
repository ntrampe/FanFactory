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

#import "GameTutorialScene.h"
#import "SettingsController.h"
#import "config.h"

#define ATTEMPT_THRESHOLD 5

@implementation GameTutorialScene

+ (CCScene *)scene
{
  CCScene *scene = [CCScene node];
  
  GameTutorialScene * layer = [[GameTutorialScene alloc] init];
  
  [scene addChild:layer];
  
  [layer release];
  
  return scene;
}


- (id)init
{
  nt_level * l = [[nt_level alloc] initWithFilePath:[[NSBundle mainBundle] pathForResource:@"levels/tutorial" ofType:@"dat"]];
  self = [super initWithLevel:l];
  [l release];
  
  if (self) 
  {
    sharedSC = [SettingsController sharedSettingsController];
    
    m_tutorial = [[nt_tutorial alloc] init];
    [m_tutorial setDelegate:self];
    [m_game addChild:m_tutorial z:10];
    m_hasCollectedCoin = NO;
    m_playerDistance = 0.0f;
    
    [m_game zoomToScale:m_game.minimumScale inTime:0.0f];
    m_game.zooms = NO;
    m_game.isTouchEnabled = NO;
    
    [m_tutorial addStateString:@"Welcome to the tutorial!\nTap anywhere to continue..."
                      forState:0];
    
    [m_tutorial addStateString:@"This is you.\nYou are a ball."
              andArrowLocation:m_game.playerPoint
                      forState:1];
    
    [m_tutorial addStateString:@"This is a fan.\nIt will help you reach your goal."
              andArrowLocation:[[m_game.fans objectAtIndex:0] position]
                      forState:2];
    
    [m_tutorial addStateString:@"This is your goal. It is your crate."
              andArrowLocation:m_game.goalPoint
                      forState:3];
    
    [m_tutorial addStateString:@"You can adjust the power and angle of the fan by tapping on the tip of the fan and moving your finger."
              andArrowLocation:[[m_game.fans objectAtIndex:0] position]
                      forState:4];
    
    [m_tutorial addStateString:@"This is a block.\nYou do not want to hit these."
              andArrowLocation:[[m_game.blocks lastObject] position]
                      forState:5];
    
    [m_tutorial addStateString:@"This is a coin.\nYou want to collect these.\n\nYou can upgrade your player in the store with coins."
              andArrowLocation:[[m_game.coins lastObject] position]
                      forState:6];
    
    [m_tutorial addState:7];
    [m_tutorial addState:8];
    
    [m_tutorial addStateString:@"Give it a try!"
                      forState:9];
    
    [m_tutorial addState:100];
    [m_tutorial addState:101];
    
    m_tutorial.autoRemoveArrow = NO;
    
    [self hideSpritesStartingFromNode:self animated:NO];
  }
  return self;
}


- (void)dealloc
{
  [m_tutorial release];
  [super dealloc];
}


- (void)onEnterTransitionDidFinish
{
  [super onEnterTransitionDidFinish];
  [self showSprites];
  [m_tutorial scheduleOnce:@selector(start) delay:0.5f];
}


- (void)tutorial:(nt_tutorial *)sender didUpdateTutorialState:(unsigned int)aState
{
  switch (aState)
  {
    case 3:
      if (self.screenSize.width == SMALLEST_SCREEN_WIDTH)
        [m_game scrollToEndInTime:1.0f];
      break;
    case 4:
      if (self.screenSize.width == SMALLEST_SCREEN_WIDTH)
        [m_game scrollToStartInTime:1.0f];
      break;
    case 7:
      [sender addAlertWithText:@"This button starts the game."];
      [sender pointArrowToLocation:[m_game convertToNodeSpace:ccpAdd(m_menu.position, m_start.position)]];
      break;
      
    case 8:
      [sender addAlertWithText:@"This button resets the game."];
      [sender pointArrowToLocation:[m_game convertToNodeSpace:ccpAdd(m_menu.position, m_retry.position)]];
      m_tutorial.autoRemoveArrow = YES;
      break;
      
    case 9:
      m_game.isTouchEnabled = YES;
      break;
      
    case 100:
      
      sender.attempts++;
      
      [self stillNeedsHelp];
      
      [sender removeArrow];
      sender.autoNext = NO;
      
      break;
      
    case 101:
      
      NSLog(@"sdfgsdfg");
      
      if (sender.attempts < ATTEMPT_THRESHOLD || m_hasCollectedCoin)
      {
        [sender addAlertWithText:@"Good job! You're ready!"];
        sender.autoNext = YES;
      }
      else
      {
        [sender addAlertWithText:(m_tutorial.attempts == ATTEMPT_THRESHOLD ? @"Now try to collect the coin!" : @"You didn't get the coin!")];
        [sender setState:100 update:NO];
        sender.attempts++;
        [m_game reset];
      }
      
      [sender removeArrow];
      break;
      
    default:
      
      break;
  }
}


- (void)tutorialDidReachEndOfTutorial:(nt_tutorial *)sender
{
  sharedSC.tutorial = FALSE;
  [sharedSC saveData];
  [self skipPressed];
}


- (void)createMenu
{
  float scale = self.screenSize.width / STANDARD_SCREEN_WIDTH;
  
  m_start = [nt_buttonitem itemFromNormalSprite:[CCSprite spriteWithFile:@"go_button.png"] block:^(id sender)
                          {
                            [m_game start];
                          }];
  
  m_retry = [nt_buttonitem itemFromNormalSprite:[CCSprite spriteWithFile:@"retry_button.png"] block:^(id sender)
                          {
                            [m_game reset];
                          }];
  
  m_start.scale = m_retry.scale = scale;
	
	m_menu = [CCMenu menuWithItems:m_start, m_retry, nil];
	
	[m_menu alignItemsHorizontallyWithPadding:4];
	
	[m_menu setPosition:ccp(m_start.contentSize.width*scale*1.8f, self.screenSize.height - m_start.contentSize.height*scale/2 - 10)];
	
	[self addChild:m_menu];
}


- (void)skipPressed
{
  [self hideSpritesStartingFromNode:self animated:YES];
  [self scheduleOnce:@selector(goBack) delay:0.4f];
}


- (void)stillNeedsHelp
{
  NSString * message = nil;
  float percent = m_playerDistance/m_game.bounds.width * 100;
  
  if (m_tutorial.attempts < ATTEMPT_THRESHOLD && !self.hasMovedFans)
  {
    message = @"You didn't move any fans...\nTry moving the fans by touching the tip of the fan and dragging your finger.";
  }
  else
  {
    if (m_tutorial.attempts < ATTEMPT_THRESHOLD)
    {
      if (percent < 30)
      {
        message = @"It looks like you're not getting very far.\nTry rotating the fan so the ball will move forward.";
      }
      else if (percent >= 30 && percent < 60)
      {
        message = @"The farther you drag your finger, the more powerful the wind.";
      }
      else
      {
        message = @"Almost there!\nYou can do it!";
      }
    }
    else
    {
      message = @"Having too much trouble?\nThe fans are now set at a power and angle that will guide the ball to the goal, but you will not collect the coin.";
      
      //left
      [[m_game.fans objectAtIndex:2] animateToAngle:-20.0f andPower:8.0f];
      
      //center
      [[m_game.fans objectAtIndex:0] animateToAngle:0.0f andPower:8.0f];
      
      //right
      [[m_game.fans objectAtIndex:1] animateToAngle:0.0f andPower:7.0f];
    }
  }
  
  if (message != nil)
  {
    [nt_alertview removeAllAlertViews];
    [m_tutorial addAlertWithText:message];
  }
}


- (BOOL)hasMovedFans
{
  BOOL moved = NO;
  for (nt_fan * f in m_game.fans)
  {
    if (f.power != 1.0f && f.angle != 0.0f)
      moved = YES;
  }
  return moved;
}


- (void)gameLayerDidFinish:(GameLayer *)gameLayer
{
  [m_tutorial setState:101];
}


- (void)gameLayerDidDie:(GameLayer *)gameLayer
{
  m_hasCollectedCoin = NO;
  m_playerDistance = gameLayer.playerPoint.x;
  [m_tutorial setState:100];
}


- (void)gameLayerDidReset:(GameLayer *)gameLayer
{
  m_hasCollectedCoin = NO;
}


- (void)gameLayer:(GameLayer *)gameLayer didEatCoin:(uint)aNumberOfTimes
{
  m_hasCollectedCoin = YES;
}


//- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//  UITouch * touch = [touches anyObject];
//  CGPoint location = [touch locationInView:touch.view];
//  location = [[CCDirector sharedDirector] convertToGL:location];
//  location = [m_game convertToNodeSpace:location];
//  [self pointArrowToLocation:location];
//  NSLog(@"%@", NSStringFromCGPoint(location));
//}


@end
