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

#import "MoreCoinsViewController.h"
#import "PackController.h"
#import "IAPController.h"
#import "config.h"

@interface MoreCoinsViewController ()

@end

@implementation MoreCoinsViewController
@synthesize black, lLoading;

- (id)init
{
  self = [super initWithNibName:@"MoreCoinsViewController" bundle:[NSBundle mainBundle]];
  if (self)
  {
    sharedPC = [PackController sharedPackController];
    sharedIAP = [IAPController sharedIAPController];
  }
  return self;
}


- (void)dealloc
{
  [black release];
  black = nil;
  [lLoading release];
  lLoading = nil;
  [super dealloc];
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.black.alpha = 0.8f;
  self.lLoading.text = @"Gathering loot...";
  
  [sharedIAP requestProducts];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBlack) name:IAP_STARTED_CONTENT object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideBlack) name:IAP_FINISHED_CONTENT object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideBlack) name:IAP_FINISHED_PRODUCT_REQUEST object:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidDisappear:(BOOL)animated
{
  if ([self.delegate respondsToSelector:@selector(moreCoinsViewControllerDidFinish:)])
  {
    [self.delegate moreCoinsViewControllerDidFinish:self];
  }
}


- (IBAction)donePressed:(id)sender
{
  [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)get100Pressed:(id)sender
{
  [self addCoins:100];
}


- (IBAction)get300Pressed:(id)sender
{
  [self addCoins:300];
}


- (IBAction)get500Pressed:(id)sender
{
  [self addCoins:500];
}


- (IBAction)restorePressed:(id)sender
{
  [sharedIAP restoreCompletedTransactions];
}


- (void)addCoins:(unsigned int)aCoins
{
  self.lLoading.text = [NSString stringWithFormat:@"Preparing your %i coins...", aCoins];
  [sharedIAP makePaymentForCoins:aCoins];
}


- (void)showBlack
{
  [UIView animateWithDuration:0.4f animations:^{
    self.black.alpha = 0.8f;
  }];
}


- (void)hideBlack
{
  [UIView animateWithDuration:0.4f animations:^{
    self.black.alpha = 0.0f;
  }];
}


- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


@end
