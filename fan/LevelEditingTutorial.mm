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

#import "LevelEditingTutorial.h"
#import "GameScene.h"
#import "GameController.h"
#import "SettingsController.h"
#import "config.h"

@implementation LevelEditingTutorial


+ (CCScene *)sceneWithLevelDocument:(LevelDocument *)aLevel
{
  CCScene *scene = [CCScene node];
	
	LevelEditingTutorial * layer = [[LevelEditingTutorial alloc] initWithLevelDocument:aLevel];
  
  [scene addChild:layer];
  
  [layer release];
	
	return scene;
}


- (id)initWithLevelDocument:(LevelDocument *)aLevel
{
  self = [super initWithLevelDocument:aLevel];
  if (self) 
  {
    sharedGC = [GameController sharedGameController];
    
    m_tutorial = [[nt_tutorial alloc] init];
    [m_tutorial setDelegate:self];
    [self addChild:m_tutorial];
    
    m_tutorial.autoRemoveArrow = NO;
    
    [m_tutorial addStateString:@"This is where you will create your level.\nTap anywhere to continue..." forState:0];
    [m_tutorial addStateString:@"With the Level Editor, you can create and play levels of your own." forState:1];
    [m_tutorial addState:2];
    [m_tutorial addState:3];
    [m_tutorial addStateString:@"You select an object by tapping on it." forState:4];
    [m_tutorial addStateString:@"You deselect an object by tapping anywhere on the level." forState:5];
    [m_tutorial addStateString:@"To move or rotate an object, the object must be selected." forState:6];
    [m_tutorial addState:7];
    [m_tutorial addState:8];
    [m_tutorial addState:9];
    
    [m_tutorial setArrowScale:self.screenSize.width / STANDARD_SCREEN_WIDTH];
    
    m_game.isBounded = YES;
    m_game.scrollX = m_game.scrollY = m_game.zooms = NO;
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
  [m_tutorial scheduleOnce:@selector(start) delay:0.5f];
}


- (void)tutorial:(nt_tutorial *)sender didUpdateTutorialState:(unsigned int)aState
{
  CCSprite * s = [m_palleteObjects objectAtIndex:3];
  
  switch (aState)
  {
    case 2:
      [sender addAlertWithText:@"Start by dragging this block onto the level."];
      [sender pointArrowToLocation:s.position];
      //[sender setState:2 update:NO];
      sender.autoNext = NO;
      break;
    case 3:
      [sender addAlertWithText:@"An object is selected when this guide is visible."];
      [sender pointArrowToLocation:[m_game convertToWorldSpace:[[m_game.objects objectAtIndex:0] position]]];
      sender.autoNext = YES;
      break;
    case 7:
      [sender addAlertWithText:@"Drag the block to the trashcan to remove it." time:0];
      [sender pointArrowToLocation:m_trashcan.position];
      sender.autoNext = NO;
      break;
    case 8:
      [sender addAlertWithText:@"Drag a few objects on to the level."];
      [sender removeArrow];
      break;
    case 9:
      [sender addAlertWithText:@"You're ready to test your first level!"];
      [sender removeArrow];
      sender.autoNext = YES;
      break;
      
    default:
      break;
  }
}


- (void)tutorialDidReachEndOfTutorial:(nt_tutorial *)sender
{
  sharedGC.testing = YES;
  [[SettingsController sharedSettingsController] setEditingTutorial:NO];
  [[SettingsController sharedSettingsController] saveData];
  [self changeScene:[GameScene sceneWithLevel:m_game.level]];
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super ccTouchesEnded:touches withEvent:event];
  
  if (m_tutorial.transitioning)
    return;
  
  //before any instructions given
  if (m_tutorial.state < 2)
  {
    if (m_game.objects.count > 0)
    {
      [m_game removeAllObjects];
    }
  }
  
  //dragging first block
  if (m_tutorial.state == 2)
  {
    BOOL correct = NO;
    
    if (m_game.objects.count > 0)
    {
      if (m_game.blocks.count > 0)
      {
        nt_block * b = [m_game.blocks objectAtIndex:0];
        if (b.type == kBlockTypeSquareLarge)
        {
          [m_tutorial setState:3];
          correct = YES;
        }
      }
      
      if (!correct)
      {
        [m_tutorial addAlertWithText:@"Wrong object!" time:0];
        [m_game removeAllObjects];
      }
    }
  }
  
  //explaining guides
  if (m_tutorial.state >= 4 && m_tutorial.state <= 6)
  {
    if (m_game.objects.count == 0)
    {
      [m_tutorial setState:7];
    }
    else if (m_game.objects.count > 1)
    {
      [m_game removeObject:[m_game.objects lastObject]];
    }
  }
  
  
  //dragging block to trashcan
  if (m_tutorial.state == 7)
  {
    if (m_game.objects.count > 0)
    {
      if (m_game.objects.count == 1)
      {
        nt_object * o = [m_game.objects objectAtIndex:0];
        if (!o.guideVisible)
        {
          m_tutorial.attempts++;
          if (m_tutorial.attempts < 5)
          {
            [m_tutorial addAlertWithText:@"Remember to select the object by tapping on it." time:0];
          }
          else
          {
            [m_tutorial addAlertWithText:@"Having trouble?\nThe object is now selected." time:0];
            [o enableGuide:YES];
            [m_game addSelectedObject:o];
          }
        }
      }
      else
      {
        [m_tutorial addAlertWithText:@"Drag the object to the trashcan." time:0];
        [m_game removeObject:[m_game.objects lastObject]];
      }
    }
    else
    {
      [m_tutorial setState:8];
    }
  }
  
  //adding at least three objects and a fan
  float minObjects = 3;
  
  if (m_tutorial.state == 8)
  {
    if (m_game.fans.count > 0)
    {
      if (m_game.fans.count == 1)
      {
        nt_fan * f = [m_game.fans objectAtIndex:0];
        
        if (f.position.x < 100 && f.position.y < 150)
        {
          if (m_game.objects.count > minObjects)
            [m_tutorial setState:9];
        }
        else
        {
          if (m_game.objects.count > minObjects)
          {
            [m_tutorial addAlertWithText:@"Drag the fan underneath the player." time:0];
            [m_tutorial pointArrowToLocation:[m_game convertToWorldSpace:ccpAdd(m_game.playerPoint, CGPointMake(0, -150))]];
          }
        }
      }
      else
      {
        [m_tutorial addAlertWithText:@"Drag other objects to the level!" time:0];
        [m_game removeObject:[m_game.fans lastObject]];
      }
    }
    else
    {
      if (m_game.objects.count > minObjects)
      {
        [m_tutorial addAlertWithText:@"Drag a fan to the level!" time:0];
        [m_tutorial pointArrowToLocation:[[m_palleteObjects objectAtIndex:7] position]];
      }
    }
  }
}


@end
