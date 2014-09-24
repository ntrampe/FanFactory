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

#import "nt_uialerttext.h"

@implementation nt_uialerttext
@synthesize delegate = _delegate;

- (id)initWithTitle:(NSString *)aTitle
{
  self = [super init];
  if (self)
  {
    m_alertView = [[UIAlertView alloc] initWithTitle:aTitle message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter", nil];
    m_alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [[m_alertView textFieldAtIndex:0] setDelegate:self];
    [m_alertView textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
    [m_alertView textFieldAtIndex:0].returnKeyType = UIReturnKeyDone;
    [m_alertView textFieldAtIndex:0].autocorrectionType = UITextAutocorrectionTypeNo;
    [m_alertView textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeNone;
  }
  return self;
}


- (void)dealloc
{
  [m_alertView release];
  [super dealloc];
}


- (void)show
{
  [m_alertView show];
  [[m_alertView textFieldAtIndex:0] becomeFirstResponder];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  switch (buttonIndex)
  {
    case 0:
      
      break;
      
    case 1:
      if ([self.delegate respondsToSelector:@selector(uialertText:didEnterText:)])
        [self.delegate uialertText:self didEnterText:[m_alertView textFieldAtIndex:0].text];
      break;
      
    default:
      break;
  }
  
  [[m_alertView textFieldAtIndex:0] setText:@""];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [m_alertView dismissWithClickedButtonIndex:1 animated:YES];
  return YES;
}


@end
