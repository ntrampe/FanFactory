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

#import "nt_layer.h"
#import "AppDelegate.h"
#import "nt_scenecontroller.h"
#import "nt_button.h"
#import "nt_label.h"
#import "nt_spritepos.h"

@implementation nt_layer
@synthesize clipsToBounds;

- (id)init
{
  self = [super init];
  if (self)
  {
    self.isTouchEnabled = YES;
    self.clipsToBounds = NO;
    m_gestures = nil;
    m_spritepositions = [[CCArray alloc] init];
  }
  return self;
}


- (void)dealloc
{
  //NSLog(@"nt_layer: %@ Deallocating...", NSStringFromClass([self class]));
  if (m_back != nil)
    [m_back release];
  if (m_gestures != nil)
  {
    [m_gestures release];
    m_gestures = nil;
  }
  if (m_spritepositions != nil)
  {
    [m_spritepositions release];
    m_spritepositions = nil;
  }
  [super dealloc];
}


- (void)onExit
{
  [super onExit];
  
  for (UIGestureRecognizer * r in m_gestures)
    [self removeGesture:r];
}


- (void)onEnter
{
  [super onEnter];
  
  for (UIGestureRecognizer * r in m_gestures)
    [self addGesture:r];
}


- (void)visit
{
  if (self.clipsToBounds)
  {
    glEnable(GL_SCISSOR_TEST);
    CGPoint pos = [self convertToWorldSpace:self.position];
    glScissor(pos.x, pos.y, self.contentSize.width*self.scaleX*CC_CONTENT_SCALE_FACTOR(), self.contentSize.height*self.scaleY*CC_CONTENT_SCALE_FACTOR());
    [super visit];
    glDisable(GL_SCISSOR_TEST);
  }
  else
  {
    [super visit];
  }
}


- (void)addBackButton
{
  [self addBackButtonWithBlock:^(id sender)
   {
     [self goBack];
   }];
}


- (void)addBackButtonWithBlock:(void (^)(id))aBlock
{
  [self addBackButtonAtPosition:CGPointMake(-self.screenSize.width/2 + 40, self.screenSize.height/2 - 35) withBlock:aBlock];
}


- (void)addBackButtonAtPosition:(CGPoint)aPos withBlock:(void (^)(id))aBlock
{
  if (m_back != nil)
  {
    if (m_back.parent != nil)
      [m_back removeFromParentAndCleanup:YES];
    
    [m_back release];
    m_back = nil;
  }
  
  m_back = [[nt_buttonitem alloc] initWithText:nil image:@"back_button.png" block:aBlock];
  m_back.position = aPos;
  CCMenu * menu = [CCMenu menuWithItems:m_back,nil];
  menu.position = self.screenCenter;
  [self addChild:menu z:20 tag:69];
}


- (void)removeBackButton
{
  [self removeChildByTag:69 cleanup:YES];
}


- (nt_buttonitem *)backButton
{
  return m_back;
}


- (UIViewController *)rootViewController
{
  AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
  return (UIViewController *)appDelegate.director;
}


- (void)presentViewController:(UIViewController *)aViewController animated:(BOOL)isAnimated
{
  [self.rootViewController presentViewController:aViewController animated:isAnimated completion:nil];
}


- (void)addButton:(nt_buttonitem *)aButton atLocation:(CGPoint)aLoc
{
  CCMenu * menu = [CCMenu menuWithItems:aButton, nil];
  aButton.position = aLoc;
  [self addChild:menu];
}



- (void)goToScene:(CCScene *)aScene
{
  [nt_scenecontroller goToScene:aScene];
}


- (void)goToScene:(CCScene *)aScene animate:(BOOL)shouldAnimate
{
  [nt_scenecontroller goToScene:aScene animate:shouldAnimate];
}


- (void)changeScene:(CCScene *)aScene
{
  [nt_scenecontroller changeScene:aScene];
}


- (void)changeScene:(CCScene *)aScene animate:(BOOL)shouldAnimate
{
  [nt_scenecontroller changeScene:aScene animate:shouldAnimate];
}


- (void)goBack
{
  [nt_scenecontroller goBack];
}


- (void)changeToMenu
{
  
}


- (void)setMenuStatus:(BOOL)enabled node:(id)node
{
  for (id menu in [(CCNode *)node children])
  {
    if ([menu isKindOfClass:[CCMenu class]])
    {
      [(CCMenu *)menu setIsTouchEnabled:enabled];
    }
    
    [self setMenuStatus:enabled node:menu];
  }
}


- (void)removeAllMenusStartingFromNode:(id)node
{
  for (id menu in [(CCNode *)node children])
  {
    if ([menu isKindOfClass:[CCMenu class]])
    {
      [self removeChild:menu cleanup:YES];
    }
    else
    {
      [self removeAllMenusStartingFromNode:menu];
    }
  }
}


- (void)killAllTouchesStartingFromNode:(id)node
{
  for (id layer in [(CCNode *)node children])
  {
    if ([layer isKindOfClass:[CCLayer class]])
    {
      [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:layer];
      //NSLog(@"nt_layer: Killing Touches For Node: %@", layer);
    }
    else
    {
      [self killAllTouchesStartingFromNode:layer];
    }
  }
}


- (void)setBackGround:(NSString *)aBg
{
  [self setBackGround:aBg scaleMode:BGScaleModeFit];
}


- (void)setBackGround:(NSString *)aBg scaleMode:(BGScaleMode)aMode
{
  [self setBackGround:aBg scaleMode:aMode replaceOld:YES];
}


- (void)setBackGround:(NSString *)aBg scaleMode:(BGScaleMode)aMode replaceOld:(BOOL)shouldReplace
{
  if (shouldReplace)
    [self removeChildByTag:BG_TAG cleanup:YES];
  CCSprite * bg = [[CCSprite alloc] initWithFile:aBg];
  bg.position = CGPointMake(self.screenSize.width/2, self.screenSize.height/2);
  
  float newScale = bg.scale;
  
  switch (aMode)
  {
    case BGScaleModeNone:
      
      break;
    case BGScaleModeFit:
      
      if (bg.contentSize.width > self.screenSize.width ||
          bg.contentSize.height > self.screenSize.height)
      {
        while (bg.contentSize.height*newScale > self.screenSize.height ||
               bg.contentSize.width*newScale > self.screenSize.width)
        {
          newScale -= 0.001;
        }
      }
      else if (bg.contentSize.width < self.screenSize.width ||
               bg.contentSize.height < self.screenSize.height)
      {
        while (bg.contentSize.height*newScale < self.screenSize.height ||
               bg.contentSize.width*newScale < self.screenSize.width)
        {
          newScale += 0.001;
        }
      }
      
      bg.scale = newScale;
      
      break;
    case BGScaleModeStretch:
      bg.scaleX = self.screenSize.width/bg.contentSize.width;
      bg.scaleY = self.screenSize.height/bg.contentSize.height;
      break;
      
    default:
      break;
  }
  
  [self addChild:bg z:-20 tag:BG_TAG];
  [bg release];
}


- (void)setBackGroundColor:(ccColor4B)aColor
{
  [self removeChildByTag:BG_COLOR_TAG cleanup:YES];
  CCLayerColor * c = [[CCLayerColor alloc] initWithColor:aColor width:self.screenSize.width height:self.screenSize.height];
  [self addChild:c z:-10 tag:BG_COLOR_TAG];
  [c release];
}


- (nt_label *)showLabel:(NSString *)aLabel color:(ccColor3B)aColor size:(float)aSize atPos:(CGPoint)aPos tag:(NSInteger)aTag time:(float)aTime
{
  nt_label * label = [nt_label labelWithString:aLabel fontSize:aSize];
  label.color = aColor;
  [label addShadow:CGSizeMake(2, 2) blur:2.0f color:ccc4(0, 0, 0, 255)];
  label.position = aPos;
  [self addChild:label z:10 tag:aTag];
  [label popUp];
  if (aTime >= 0)
  {
    [self performSelector:@selector(hideLabel:) withObject:label afterDelay:aTime];
  }
  return label;
}


- (void)hideLabel:(nt_label *)aLabel
{
  [aLabel popDown];
  [self performSelector:@selector(removeLabel:) withObject:aLabel afterDelay:0.3];
}


- (void)hideLabelByTag:(NSInteger)aTag
{
  nt_label * label = (nt_label *)[self getChildByTag:(NSInteger)aTag];
  [self removeLabel:label];
}


- (void)removeLabel:(nt_label *)aLabel
{
  [self removeChild:aLabel cleanup:YES];
}


- (void)removeLabelByTag:(NSInteger)aTag
{
  id label = [self getChildByTag:aTag];
  if (label != nil)
    if ([label isKindOfClass:[nt_label class]])
      [self removeLabel:label];
}


- (void)removeAllLabels
{
  for (id child in self.children)
    if ([child isKindOfClass:[nt_label class]])
      [child removeFromParentAndCleanup:YES];
}


- (void)addGesture:(UIGestureRecognizer *)aGesture
{
  if (m_gestures == nil)
    m_gestures = [[CCArray alloc] init];
  
  [m_gestures addObject:aGesture];
  
  [[[CCDirector sharedDirector] view] addGestureRecognizer:[m_gestures lastObject]];
}


- (void)removeGesture:(UIGestureRecognizer *)aGesture
{
  [[[CCDirector sharedDirector] view] removeGestureRecognizer:aGesture];
  
  if (m_gestures != nil)
  {
    [m_gestures removeObject:aGesture];
  }
}


- (CGSize)screenSize
{
  return [[CCDirector sharedDirector] winSize];
}


- (CGPoint)screenCenter
{
  return CGPointMake(self.screenSize.width/2, self.screenSize.height/2);
}


- (void)show:(BOOL)shouldAnimate
{
  for (CCSprite * s in [self children])
  {
    if (shouldAnimate)
    {
      CCAction * act = [CCFadeIn actionWithDuration:SCENE_ANIMATION_TIME];
      [s runAction:act];
    }
    else
    {
      s.opacity = 255;
    }
  }
}


- (void)hide:(BOOL)shouldAnimate
{
  for (CCSprite * s in [self children])
  {
    if (shouldAnimate)
    {
      CCAction * act = [CCFadeOut actionWithDuration:SCENE_ANIMATION_TIME];
      [s runAction:act];
    }
    else
    {
      s.opacity = 0;
    }
  }
}


- (void)show
{
  [self show:YES];
}


- (void)hide
{
  [self hide:YES];
}


- (void)hideSpritesStartingFromNode:(id)node animated:(BOOL)isAnimated
{
  for (id sprite in [(CCNode *)node children])
  {
    if ([sprite isKindOfClass:[CCSprite class]])
    {
      CCSprite * s = sprite;
      
      if (s.tag != BG_TAG && s.tag != BG_COLOR_TAG && s.tag != DONT_MOVE_SPRITE_TAG)
      {
        CGPoint pos = s.position;
        float realHeight = pos.y;
        CCNode * p = s.parent;
        
        while (p != nil)
        {
          realHeight += p.position.y;
          p = p.parent;
        }
        
        if (realHeight < self.screenCenter.y)
        {
          pos.y -= self.screenSize.height;
        }
        else
        {
          pos.y += self.screenSize.height;
        }
        
        nt_spritepos * sp = [[nt_spritepos alloc] init];
        sp.sprite = s;
        sp.position = s.position;
        [m_spritepositions addObject:sp];
        [sp release];
        
        if (isAnimated)
        {
          CCAction * move = [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:SCENE_ANIMATION_TIME position:pos]];
          CCAction * fade = [CCEaseSineInOut actionWithAction:[CCFadeTo actionWithDuration:SCENE_ANIMATION_TIME opacity:0.0f]];
          [sprite runAction:move];
          [sprite runAction:fade];
        }
        else
        {
          s.position = pos;
          s.opacity = 0.0f;
        }
      }
    }
    else
    {
      [self hideSpritesStartingFromNode:sprite animated:isAnimated];
    }
  }
}


- (void)showSprites
{
  for (nt_spritepos * sp in m_spritepositions)
  {
    CCAction * move = [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:SCENE_ANIMATION_TIME position:sp.position]];
    CCAction * fade = [CCEaseSineInOut actionWithAction:[CCFadeIn actionWithDuration:SCENE_ANIMATION_TIME]];
    [sp.sprite runAction:move];
    [sp.sprite runAction:fade];
  }
  
  [m_spritepositions removeAllObjects];
}


- (void)callBlock:(void(^)())block afterDelay:(float)aDelay
{
  [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:aDelay] two:[CCCallBlock actionWithBlock:block]]];
}


@end
