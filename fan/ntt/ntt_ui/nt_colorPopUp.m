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

#import "nt_colorPopUp.h"

@implementation nt_colorPopUp

- (id)initWithColor:(ccColor4B)aColor
               size:(CGSize)aSize
            message:(NSString *)aMessage
           delegate:(id)aDelegate
  cancelButtonTitle:(NSString *)aCancelButtonTitle
  otherButtonTitles:(NSArray *)someOtherTitles
{
  self = [super initWithContainer:[CCLayerColor layerWithColor:aColor width:aSize.width height:aSize.height] message:aMessage delegate:aDelegate cancelButtonTitle:aCancelButtonTitle otherButtonTitles:someOtherTitles];
  if (self) 
  {
    
  }
  return self;
}


- (void)dealloc
{
  
  [super dealloc];
}


@end
