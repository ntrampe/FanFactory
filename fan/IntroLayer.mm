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


#import "IntroLayer.h"
#import "MenuScene.h"
#import "config.h"
#import "DataController.h"

@implementation IntroLayer


+ (CCScene *)scene
{
	CCScene *scene = [CCScene node];
	
	IntroLayer *layer = [IntroLayer node];
	
	[scene addChild: layer];
	
	return scene;
}


- (id)init
{
  self = [super init];
  if (self)
  {
    m_logo = [CCSprite spriteWithFile:@"logo.png"];
    m_loading = [nt_label labelWithString:@"Loading..." fontSize:24];
  }
  return self;
}


- (void)dealloc
{
  [m_menuScene release];
  [super dealloc];
}


- (void)onEnter
{
	[super onEnter];
  
  [self setBackGroundColor:ccc4(200, 200, 200, 255)];
  
  m_logo.scale = self.screenSize.width / STANDARD_SCREEN_WIDTH;
  m_logo.position = ccp(self.screenSize.width/2, self.screenSize.height/2);
  //    m_logo.opacity = 0.0f;
  
  [self addChild:m_logo];
  
  m_loading.position = ccp(self.screenSize.width/2, 30);
  //    m_loading.opacity = 0.0f;
  
  [self addChild:m_loading];
  
  [self hideSpritesStartingFromNode:self animated:NO];
  
  [self scheduleOnce:@selector(start) delay:0.1f];
}


- (void)onExit
{
  [super onExit];
  
}


- (void)start
{
//  [m_logo runAction:[CCFadeIn actionWithDuration:0.5f]];
//  [m_logo runAction:[CCEaseSineOut actionWithAction:[CCMoveTo actionWithDuration:0.5f position:ccp(self.screenSize.width/2, self.screenSize.height/2)]]];
//  [m_loading runAction:[CCFadeIn actionWithDuration:0.5f]];
//  [m_loading runAction:[CCEaseSineOut actionWithAction:[CCMoveTo actionWithDuration:0.5f position:ccp(self.screenSize.width/2, 30)]]];

  [self showSprites];
  
  [self scheduleOnce:@selector(load) delay:0.6f];
}


- (void)load
{
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"blocks.plist"];
  //  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"player.plist"];
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"menu_elements.plist"];
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"game_elements.plist"];
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"fans.plist"];
  
  [[DataController sharedDataController] loadLevelsFromCloudDirectory];
  
  m_menuScene = [[MenuScene scene] retain];
  
  [self move];
}


- (void)move
{
  [m_logo runAction:[CCEaseSineIn actionWithAction:[CCMoveBy actionWithDuration:0.5f position:CGPointMake(0, self.screenSize.height)]]];
  [m_loading runAction:[CCEaseSineOut actionWithAction:[CCMoveTo actionWithDuration:0.5f position:ccp(self.screenSize.width/2, -30)]]];
  
  //[self hideSpritesStartingFromNode:self animated:YES];
  
  [self scheduleOnce:@selector(goToMenu) delay:0.6f];
}


- (void)goToMenu
{
  [self changeScene:m_menuScene animate:NO];
}


@end
