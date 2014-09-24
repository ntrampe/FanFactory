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

#import "ConfirmPopUp.h"
#import "CCSprite+StretchableImage.h"
#import "nt_label.h"

@implementation ConfirmPopUp

- (id)initWithMessage:(NSString *)aMessage delegate:(id)aDelegate
{
  self = [super initWithMessage:aMessage stretchableImageNamed:@"stretch_container.png" bottomOffset:50 delegate:aDelegate];
  if (self) 
  {
    [m_lMessage setTextColor:ccWHITE];
    
    [self addButtonSprite:[CCSprite spriteWithFile:@"no_button.png"] atPosition:CGPointMake(-50, 0)];
    [self addButtonSprite:[CCSprite spriteWithFile:@"yes_button.png"] atPosition:CGPointMake(50, 0)];
    
    [self setMenuOffsetFromBottom:30];
  }
  return self;
}


- (void)dealloc
{
  
  [super dealloc];
}


@end
