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

#import "CreditsAlert.h"
#import "CCSprite+StretchableImage.h"
#import "nt_label.h"
#import "PackController.h"

@implementation CreditsAlert

- (id)init
{
  self = [super initWithContainer:[CCSprite spriteWithStretchableImageNamed:@"stretch_container.png" withLeftCapWidth:18 topCapHeight:20 size:CGSizeMake(400, 300)] message:@"Credits\n\nProgramming and Artwork:\nNicholas Trampe\n\nSpecial Thanks:\nBox2D, Cocos2D" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
  if (self) 
  {
    [m_lMessage setTextColor:ccWHITE];
    [self addButtonSprite:[CCSprite spriteWithFile:@"back_button.png"] atPosition:CGPointMake(0, 0)];
    
    m_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEasterEgg)];
    m_tap.numberOfTapsRequired = 4;
    [self addGesture:m_tap];
  }
  return self;
}


- (void)dealloc
{
  [self removeGesture:m_tap];
  [m_tap release];
  
  [super dealloc];
}


- (void)showEasterEgg
{
  [[PackController sharedPackController] findEasterEgg];
}


@end
