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

#import "nt_button.h"
#import "ntt_config.h"

@interface nt_buttonitem (Private)

- (void)setUpWithText:(NSString *)text;

@end

@implementation nt_button

+ (id)buttonWithImage:(NSString*)file title:(NSString *)title atPosition:(CGPoint)position target:(id)target selector:(SEL)selector
{
	CCMenu *menu = [CCMenu menuWithItems:[nt_buttonitem buttonWithText:title image:file target:target selector:selector], nil];
	menu.position = position;
	return menu;
}

@end

@implementation nt_buttonitem
@synthesize sound = m_sound;
@synthesize title = m_title;

+ (id)buttonWithText:(NSString*)text image:(NSString *)image target:(id)target selector:(SEL)selector
{
	return [[[self alloc] initWithText:text image:image target:target selector:selector] autorelease];
}


+ (id)buttonWithText:(NSString*)text imageFrame:(NSString *)imageFrame target:(id)target selector:(SEL)selector
{
  return [[[self alloc] initWithText:text imageFrame:imageFrame target:target selector:selector] autorelease];
}


+ (id)buttonWithText:(NSString*)text sprite:(CCSprite *)aSprite target:(id)target selector:(SEL)selector
{
  return [[[self alloc] initWithText:text sprite:aSprite target:target selector:selector] autorelease];
}


+ (id)buttonWithText:(NSString*)text image:(NSString *)image block:(void(^)(id sender))block
{
  return [[[self alloc] initWithText:text image:image block:block] autorelease];
}


+ (id)buttonWithText:(NSString*)text imageFrame:(NSString *)imageFrame block:(void(^)(id sender))block
{
  return [[[self alloc] initWithText:text imageFrame:imageFrame block:block] autorelease];
}


+ (id)buttonWithText:(NSString*)text sprite:(CCSprite *)aSprite block:(void(^)(id sender))block
{
  return [[[self alloc] initWithText:text sprite:aSprite block:block] autorelease];
}


- (id)initWithText:(NSString*)text image:(NSString *)image target:(id)target selector:(SEL)selector
{
  return [self initWithText:text sprite:[CCSprite spriteWithFile:image] target:target selector:selector];
}


- (id)initWithText:(NSString*)text imageFrame:(NSString *)imageFrame target:(id)target selector:(SEL)selector
{
  return [self initWithText:text sprite:[CCSprite spriteWithSpriteFrameName:imageFrame] target:target selector:selector];
}


- (id)initWithText:(NSString*)text sprite:(CCSprite *)aSprite target:(id)target selector:(SEL)selector
{
  self = [super initWithNormalSprite:aSprite target:target selector:selector];
	if (self)
  {
		[self setUpWithText:text];
	}
	return self;
}


- (id)initWithText:(NSString*)text image:(NSString *)image block:(void(^)(id sender))block
{
  return [self initWithText:text sprite:[CCSprite spriteWithFile:image] block:block];
}


- (id)initWithText:(NSString*)text imageFrame:(NSString *)imageFrame block:(void(^)(id sender))block
{
  return [self initWithText:text sprite:[CCSprite spriteWithSpriteFrameName:imageFrame] block:block];
}


- (id)initWithText:(NSString*)text sprite:(CCSprite *)aSprite block:(void(^)(id sender))block
{
  self = [super initWithNormalSprite:aSprite block:block];
	if (self)
  {
		[self setUpWithText:text];
	}
	return self;
}


- (void)setText:(NSString *)text
{
  self.title = text;
  m_labelTitle.string = self.title;
}


- (void)setLabel:(nt_label *)label
{
  if (m_labelTitle.parent != nil)
    [m_labelTitle removeFromParentAndCleanup:YES];
  m_labelTitle = label;
  [m_labelTitle setTextColor:ccWHITE];
  m_labelTitle.position = CGPointMake(self.contentSize.width/2, self.contentSize.height/2);
  [self addChild:m_labelTitle];
}


- (void)setLabelOffset:(CGPoint)offset
{
  m_labelTitle.position = CGPointMake(self.contentSize.width/2 + offset.x, self.contentSize.height/2 + offset.y);
}


- (void)setOpacity:(GLubyte)opacity
{
  [super setOpacity:opacity];
  
  for (id child in children_)
  {
    if ([child conformsToProtocol:@protocol(CCRGBAProtocol)])
    {
      CCNode<CCRGBAProtocol> * opNode = (CCNode<CCRGBAProtocol> *)child;
      [opNode setOpacity:opacity];
    }
  }
}


- (void)pulse
{
  CCSequence * seq = [CCSequence actions:[CCScaleTo actionWithDuration:0.6 scale:1.1], [CCScaleTo actionWithDuration:0.5 scale:1], [CCScaleTo actionWithDuration:0.1 scale:1], nil];
  CCRepeatForever * act = [CCRepeatForever actionWithAction:seq];
  [self runAction:act];
}


- (void)setUpWithText:(NSString *)text
{
  if (text != nil)
  {
    if (m_title != nil)
    {
      [m_title release];
      m_title = nil;
    }
    
    m_title = [text copy];
    
    float fontSize = MAXIMUM_FONT_SIZE;
    
    while (fontSize/2 * [self.title length] >= self.contentSize.width - TEXT_OFFSET)
      fontSize--;
    
    [self setLabel:[nt_label labelWithString:self.title fontSize:fontSize]];
  }
  self.sound = @"button";
}


- (void)unselected
{
  [super unselected];
//  if (self.sound != nil)
//    NSLog(@"Should Play Sound - %@", self.sound);
}


// this prevents double taps
- (void)activate
{
	[super activate];
	[self setIsEnabled:NO];
	[self schedule:@selector(resetButton:) interval:0.5];
}

- (void)resetButton:(ccTime)dt
{
	[self unschedule:@selector(resetButton:)];
	[self setIsEnabled:YES];
}

- (void)dealloc
{
  
	[super dealloc];
}

@end
