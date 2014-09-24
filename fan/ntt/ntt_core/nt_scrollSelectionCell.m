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

#import "nt_scrollSelectionCell.h"

@interface nt_scrollSelectionCell (Private)

- (void)notifyDelegateOfSelection;
- (void)notifyDelegateOfDeletion;

@end

@implementation nt_scrollSelectionCell
@synthesize delegate = _delegate;

+ (id)cellWithText:(NSString *)text image:(NSString *)image
{
  return [[[self alloc] initWithText:text image:image] autorelease];
}


+ (id)cellWithText:(NSString *)text sprite:(CCSprite *)aSprite
{
  return [[[self alloc] initWithText:text sprite:aSprite] autorelease];
}


- (id)initWithText:(NSString *)text image:(NSString *)image
{
  return [self initWithText:text sprite:[CCSprite spriteWithFile:image]];
}


- (id)initWithText:(NSString *)text sprite:(CCSprite *)aSprite
{
  self = [super initWithText:text sprite:aSprite target:self selector:@selector(notifyDelegateOfSelection)];
  if (self) 
  {
    m_prompt = YES;
    
    m_close = [nt_buttonitem buttonWithText:nil image:@"closebox.png" block:^(id sender)
                             {
                               if (m_prompt)
                               {
                                 UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete this cell?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                                 [alert show];
                                 [alert release];
                               }
                               else
                               {
                                 [self notifyDelegateOfDeletion];
                               }
                             }];
    
    m_subMenu = [nt_scrollMenu menuWithItems:m_close, nil];
    m_subMenu.position = CGPointMake(0, 0);
    m_close.position = CGPointMake(self.contentSize.width - 5, self.contentSize.height - 5);
    [self addChild:m_subMenu];
    
    [self setEditing:NO];
  }
  return self;
}


- (void)dealloc
{
  
  [super dealloc];
}


- (void)setEditing:(BOOL)isEditing
{
  m_editing = isEditing;
  
  //m_close.isTouchEnabled = isEditing;
  m_close.visible = isEditing;
}


- (void)setEnabled:(BOOL)isEnabled
{
  [self setOpacity:(isEnabled ? 255.0f : 150.0f)];
  [self setIsEnabled:isEnabled];
}


- (void)setDeletePrompt:(BOOL)isPrompting
{
  m_prompt = isPrompting;
}


- (void)addSubMenuItem:(nt_buttonitem *)aItem
{
  [m_subMenu addChild:aItem];
}


- (void)setOpacity:(GLubyte)opacity
{
  [super setOpacity:opacity];
  
  m_subMenu.opacity = opacity;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  switch (buttonIndex)
  {
    case 0:
      
      break;
    case 1:
      [self notifyDelegateOfDeletion];
      break;
      
    default:
      break;
  }
}


- (void)notifyDelegateOfSelection
{
  if ([self.delegate respondsToSelector:@selector(selectionCellDidSelect:)] && !m_subMenu.isSelected)
    [self.delegate selectionCellDidSelect:self];
}


- (void)notifyDelegateOfDeletion
{
  if ([self.delegate respondsToSelector:@selector(selectionCellDidDelete:)])
    [self.delegate selectionCellDidDelete:self];
}


@end
