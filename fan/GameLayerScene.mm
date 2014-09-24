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

#import "GameLayerScene.h"
#import "GameController.h"
#import "MenuScene.h"
#import "nt_b2dsprite.h"
#import "nt_block.h"
#import "nt_label.h"
#import "nt_button.h"
#import "PackController.h"

@implementation GameLayerScene

+ (CCScene *)sceneWithLevel:(nt_level *)aLevel
{
  CCScene *scene = [CCScene node];
  
  GameLayerScene * layer = [[GameLayerScene alloc] initWithLevel:aLevel];
  
  [scene addChild:layer];
  
  [layer release];
  
  return scene;
}


- (id)init
{
  return [self initWithLevel:[nt_level levelWithLength:self.screenSize.width fans:nil blocks:nil coins:nil]];
}


- (id)initWithLevel:(nt_level *)aLevel
{
  self = [super init];
  if (self) 
  {
    sharedGC = [GameController sharedGameController];
    
    m_level = [aLevel copy];
    
    self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
    self.clipsToBounds = YES;
    
    [self setBackGroundColor:ccc4(200, 200, 200, 255)];
    
    m_game = [[GameLayer alloc] initWithLevel:m_level];
    [m_game setGameDelegate:self];
    [m_game addToParent:self];
    
    [self createMenu];
  }
  return self;
}


- (void)dealloc
{
  [m_level release];
  [m_game release];
  [super dealloc];
}


- (void)createMenu
{
  //overriden by subclass
}


#pragma mark -
#pragma mark Game Layer Delegate


- (void)gameLayerDidStart:(GameLayer *)gameLayer
{
  
}


- (void)gameLayerDidFinish:(GameLayer *)gameLayer
{
  
}


- (void)gameLayerDidDie:(GameLayer *)gameLayer
{
  
}


- (void)gameLayerDidReset:(GameLayer *)gameLayer
{
  
}


- (void)gameLayer:(GameLayer *)gameLayer didKnockOnWood:(uint)aNumberOfTimes
{
  
}


- (void)gameLayer:(GameLayer *)gameLayer didEatCoin:(uint)aNumberOfTimes
{
  
}


#pragma mark -
#pragma mark Pause Delegate


- (void)ntalertViewWillShow:(nt_alertview *)sender
{
  m_game.isTouchEnabled = NO;
  [sharedGC pause];
  
}


- (void)ntalertViewDidHide:(nt_alertview *)sender
{
  m_game.isTouchEnabled = YES;
  [sharedGC resume];
  
}


- (void)ntalertView:(nt_alertview *)sender didFinishWithButtonIndex:(int)buttonIndex
{
  switch (buttonIndex)
  {
    case 0:
      
      break;
    case 1:
      [self goBack];
      break;
    case 2:
      
      break;
      
    default:
      break;
  }
}


@end
