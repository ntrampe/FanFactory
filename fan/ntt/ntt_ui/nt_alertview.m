/*
 * Copyright (c) 2013 Nicholas Trampe
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

#import "nt_alertview.h"
#import "ntt_config.h"
#import "nt_button.h"
#import "nt_label.h"

@interface nt_alertview (Private)

- (void)buttonClicked:(nt_buttonitem *)aButton;
- (void)notifyDelegateOfButton:(nt_buttonitem *)aButton;
- (void)setMenuStatus:(BOOL)enabled node:(id)node;
- (CGPoint)hiddenPosition;

- (void)addToRunningScene;
- (void)removeFromRunningScene;

@end

@implementation nt_alertview
@synthesize delegate = _delegate;
@synthesize menu = m_menu;
@synthesize canBeDismissed, outsideTouchDismisses = _outsideTouchDismisses, cancelsMenuTouches;

- (id)initWithImageName:(NSString *)aName
                message:(NSString *)aMessage
               delegate:(id)aDelegate
      cancelButtonTitle:(NSString *)aCancelButtonTitle
      otherButtonTitles:(NSArray *)someOtherTitles
{
  return [self initWithContainer:[CCSprite spriteWithFile:aName] message:aMessage delegate:aDelegate cancelButtonTitle:aCancelButtonTitle otherButtonTitles:someOtherTitles];
}


- (id)initWithImageFrameName:(NSString *)aName
                     message:(NSString *)aMessage
                    delegate:(id)aDelegate
           cancelButtonTitle:(NSString *)aCancelButtonTitle
           otherButtonTitles:(NSArray *)someOtherTitles
{
  return [self initWithContainer:[CCSprite spriteWithSpriteFrameName:aName] message:aMessage delegate:aDelegate cancelButtonTitle:aCancelButtonTitle otherButtonTitles:someOtherTitles];
}


- (id)initWithContainer:(CCNode *)aContainer
                message:(NSString *)aMessage
               delegate:(id)aDelegate
      cancelButtonTitle:(NSString *)aCancelButtonTitle
      otherButtonTitles:(NSArray *)someOtherTitles
{
  self = [super init];
  if (self)
  {
    self.isTouchEnabled = YES;
    self.canBeDismissed = YES;
    self.outsideTouchDismisses = YES;
    self.cancelsMenuTouches = YES;
    m_shown = NO;
    m_dismissing = NO;
    m_black = [[CCLayerColor alloc] initWithColor:ccc4(0, 0, 0, 100)];
    [self addChild:m_black];
    
    self.delegate = aDelegate;
    self.presentationStyle = kAlertViewPresentationStyleCoverUp;
    m_nButtons = (aCancelButtonTitle == nil ? 0 : 1);
    
    m_container = [aContainer retain];
    m_container.position = CGPointMake(0, 0);
    m_container.anchorPoint = CGPointMake(0.5f, 0.5f);
    [self addChild:m_container];
    
    m_menu = [CCMenu menuWithItems:nil];
    m_menu.position = CGPointMake(m_container.contentSize.width/2, TEXT_OFFSET*2);
    [m_container addChild:m_menu];
    
    float usedSpace = 0;
    
    if (aMessage != nil)
    {
      usedSpace += 85;
      m_lMessage = [nt_label labelWithString:aMessage dimensions:CGSizeMake(m_container.contentSize.width*CC_CONTENT_SCALE_FACTOR() - TEXT_OFFSET*2, m_container.contentSize.height*CC_CONTENT_SCALE_FACTOR() - TEXT_OFFSET*2) alignment:UITextAlignmentCenter lineBreakMode:UILineBreakModeWordWrap fontSize:[nt_alertview fontSize]];
      m_lMessage.color = ccBLACK;
      m_lMessage.position = CGPointMake(m_container.contentSize.width/2, m_container.contentSize.height/2);
      [m_container addChild:m_lMessage];
    }
    
    if (someOtherTitles != nil)
    {
      for (NSString * title in someOtherTitles)
      {
        nt_buttonitem * item = [[nt_buttonitem alloc] initWithText:title image:@"button.png" target:self selector:@selector(buttonClicked:)];
        item.tag = m_nButtons;
        [m_menu addChild:item];
        [item release];
        m_nButtons++;
      }
    }
    
    if (aCancelButtonTitle != nil)
    {
      nt_buttonitem * cancelItem = [[nt_buttonitem alloc] initWithText:aCancelButtonTitle image:@"button.png" target:self selector:@selector(buttonClicked:)];
      cancelItem.tag = 0;
      [m_menu addChild:cancelItem];
      [cancelItem release];
    }
    
    [self setMenuOffsetFromBottom:TEXT_OFFSET*2];
    [m_menu alignItemsHorizontallyWithPadding:5];
    
    if ([aContainer isKindOfClass:[CCLayer class]])
      [self setDisplayPosition:CGPointMake(self.screenCenter.x - m_container.contentSize.width/2, self.screenCenter.y - m_container.contentSize.height/2)];
    else
      [self setDisplayPosition:self.screenCenter];
  }
  return self;
}


- (void)dealloc
{
  [m_container release];
  [m_black release];
  [super dealloc];
}


- (void)addMenu:(CCMenu *)aMenu atPosition:(CGPoint)aPosition
{
  [m_container addChild:aMenu];
  aMenu.position = aPosition;
}


- (void)setMenuOffset:(float)anOffset
{
  m_menu.position = CGPointMake(m_container.contentSize.width/2, m_container.contentSize.height/2 + anOffset);
}


- (void)setMenuOffsetFromBottom:(float)anOffset
{
  [self setMenuOffset:-m_container.contentSize.height/2 + anOffset];
}


- (void)alignMenuItems
{
  [m_menu alignItemsHorizontallyWithPadding:5];
}


- (void)setDisplayPosition:(CGPoint)aPoint
{
  m_displayPosition = aPoint;
  m_container.position = self.hiddenPosition;
}


- (void)setTextColor:(ccColor3B)aColor
{
  [m_lMessage setTextColor:aColor];
}


- (CCNode *)container
{
  return m_container;
}


- (void)addButtonSprite:(CCSprite *)aSprite atPosition:(CGPoint)aPosition
{
  nt_buttonitem * button = [nt_buttonitem buttonWithText:nil sprite:aSprite target:self selector:@selector(buttonClicked:)];
  button.tag = m_nButtons;
  button.position = aPosition;
  [m_menu addChild:button];
  [self setMenuOffsetFromBottom:TEXT_OFFSET*2];
  m_nButtons++;
}


- (void)addButtonImageName:(NSString *)aButtonImageName atPosition:(CGPoint)aPosition
{
  [self addButtonSprite:[CCSprite spriteWithFile:aButtonImageName] atPosition:aPosition];
}


- (void)addButtonImageFrameName:(NSString *)aButtonImageFrameName atPosition:(CGPoint)aPosition
{
  [self addButtonSprite:[CCSprite spriteWithSpriteFrameName:aButtonImageFrameName] atPosition:aPosition];
}


- (NSString *)titleForButtonIndex:(int)anIndex
{
  for (nt_buttonitem * item in m_menu.children)
    if (item.tag == anIndex)
      return item.title;
  return nil;
}


- (void)buttonClicked:(nt_buttonitem *)aButton
{
  [self performSelector:@selector(notifyDelegateOfButton:) withObject:aButton afterDelay:ALERT_SHOW_TIME+0.1];
  [self dismiss];
}



- (void)notifyDelegateOfButton:(nt_buttonitem *)aButton
{
  if ([self.delegate respondsToSelector:@selector(ntalertView:didFinishWithButtonIndex:)])
    [self.delegate ntalertView:self didFinishWithButtonIndex:aButton.tag];
}


- (CGPoint)hiddenPosition
{
  CGPoint res = CGPointMake(0, 0);
  
  switch (self.presentationStyle)
  {
    case kAlertViewPresentationStyleCoverUp:
      res = CGPointMake(m_displayPosition.x, m_displayPosition.y - self.screenSize.height/2 - m_container.contentSize.height);
      break;
    case kAlertViewPresentationStyleCoverDown:
      res = CGPointMake(m_displayPosition.x, m_displayPosition.y + self.screenSize.height/2 + m_container.contentSize.height);
      break;
    case kAlertViewPresentationStyleCoverLeft:
      res = CGPointMake(m_displayPosition.x - m_container.contentSize.width, m_displayPosition.y);
      break;
    case kAlertViewPresentationStyleCoverRight:
      res = CGPointMake(m_displayPosition.x + m_container.contentSize.width, m_displayPosition.y);
      break;
      
    default:
      break;
  }
  
  return res;
}


- (void)addToRunningScene
{
  [[[CCDirector sharedDirector] runningScene] addChild:self z:10];
}


- (void)removeFromRunningScene
{
  [[[CCDirector sharedDirector] runningScene] removeChild:self cleanup:YES];
}


- (void)dismiss
{
  if (self.canBeDismissed && m_shown && !m_dismissing)
  {
    if ([self.delegate respondsToSelector:@selector(ntalertViewWillHide:)])
      [self.delegate ntalertViewWillHide:self];
    
    [self hide:YES];
    [self performSelector:@selector(removeFromRunningScene) withObject:nil afterDelay:ALERT_SHOW_TIME];
    m_dismissing = YES;
  }
}


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch * touch = [touches anyObject];
  CGPoint location = [touch locationInView:touch.view];
  location = [[CCDirector sharedDirector] convertToGL:location];
  
  if (!CGRectContainsPoint(m_container.boundingBox, location) && self.outsideTouchDismisses)
  {
    [self dismiss];
  }
}


+ (void)removeAllAlertViews
{
  for (CCNode * node in [[[CCDirector sharedDirector] runningScene] children])
  {
    if ([node isKindOfClass:[nt_alertview class]])
    {
      nt_alertview * alert = (nt_alertview *)node;
      [alert removeFromRunningScene];
    }
  }
}


+ (CGFloat)fontSize
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    return 24;
  return 18;
}


+ (CGSize)containerSizeForMessage:(NSString *)aString andMaxWidth:(float)aWidth
{
  UIFont *   font = [UIFont fontWithName:FONT_NAME size:[nt_alertview fontSize]];
  CGSize textSize = [aString sizeWithFont:font constrainedToSize:CGSizeMake(aWidth - TEXT_OFFSET, 320) lineBreakMode:UILineBreakModeWordWrap];
  
  //TODO:                                    this is an awful, temporary fix for non-retina devices
  return CGSizeMake(aWidth, textSize.height*(2.0f/CC_CONTENT_SCALE_FACTOR()) + [nt_alertview fontSize] + 10);
}


+ (CGSize)containerSizeForMessage:(NSString *)aString
{
  float width = [[CCDirector sharedDirector] winSize].width/2.0f;
  
  return [nt_alertview containerSizeForMessage:aString andMaxWidth:width];
}


- (void)show:(BOOL)shouldAnimate
{
  if (self.cancelsMenuTouches)
    [self setMenuStatus:NO node:[[CCDirector sharedDirector] runningScene]];
  
  [self addToRunningScene];
  
  if (shouldAnimate)
  {
    CCAction * act = [CCEaseBackOut actionWithAction:[CCMoveTo actionWithDuration:ALERT_SHOW_TIME position:m_displayPosition]];
    [m_container runAction:act];
    CCAction * fade = [CCFadeTo actionWithDuration:ALERT_SHOW_TIME opacity:100.0f];
    [m_black runAction:fade];
    
    [self callBlock:^{m_shown = YES;} afterDelay:ALERT_SHOW_TIME];
  }
  else
  {
    m_container.position = m_displayPosition;
    m_black.opacity = 100.0f;
    m_shown = YES;
  }
  
  //play alert_swoosh
  
  if ([self.delegate respondsToSelector:@selector(ntalertViewWillShow:)])
    [self.delegate ntalertViewWillShow:self];
  if ([self.delegate respondsToSelector:@selector(ntalertViewDidShow:)])
    [self.delegate performSelector:@selector(ntalertViewDidShow:) withObject:self afterDelay:ALERT_SHOW_TIME];
}


- (void)hide:(BOOL)shouldAnimate
{
  if (self.cancelsMenuTouches)
    [self setMenuStatus:YES node:[[CCDirector sharedDirector] runningScene]];
  
  if (shouldAnimate)
  {
    CCAction * act = [CCEaseBackIn actionWithAction:[CCMoveTo actionWithDuration:ALERT_SHOW_TIME position:self.hiddenPosition]];
    [m_container runAction:act];
    CCAction * fade = [CCFadeTo actionWithDuration:ALERT_SHOW_TIME opacity:0.0f];
    [m_black runAction:fade];
  }
  else
  {
    m_container.position = self.hiddenPosition;
    m_black.opacity = 0.0f;
  }
  if ([self.delegate respondsToSelector:@selector(ntalertViewDidHide:)])
    [self.delegate performSelector:@selector(ntalertViewDidHide:) withObject:self afterDelay:ALERT_SHOW_TIME];
}

@end
