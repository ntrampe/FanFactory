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

#import "OverallSettingsViewController.h"
#import "ObjectAttributesViewController.h"

@interface OverallSettingsViewController ()

@end

@implementation OverallSettingsViewController
@synthesize sSnaps, sGuides, cEditMode, editMode, defaultObject = m_defaultObject;

- (id)init
{
  self = [super initWithNibName:@"OverallSettingsViewController" bundle:[NSBundle mainBundle]];
  if (self)
  {
    
  }
  return self;
}


- (void)dealloc
{
  [sSnaps release];
  [sGuides release];
  [cEditMode release];
  [super dealloc];
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  
}


- (void)viewWillAppear:(BOOL)animated
{
  [self.sSnaps setOn:self.snaps animated:NO];
  [self.sGuides setOn:self.guides animated:NO];
  [self.cEditMode setSelectedSegmentIndex:self.editMode];
}


- (IBAction)donePressed:(id)sender
{
  if ([self.delegate respondsToSelector:@selector(overallSettingsViewControllerDidFinish:)])
    [self.delegate overallSettingsViewControllerDidFinish:self];
  [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)snapsToggled:(UISwitch *)sender
{
  self.snaps = sender.isOn;
}


- (IBAction)guidesToggled:(UISwitch *)sender
{
  self.guides = sender.isOn;
}


- (IBAction)editTypeToggled:(UISegmentedControl *)sender
{
  self.editMode = sender.selectedSegmentIndex;
}


- (IBAction)defaultObjectPressed:(id)sender
{
  ObjectAttributesViewController * v = [[ObjectAttributesViewController alloc] initWithObjects:[NSArray arrayWithObject:m_defaultObject]];
  v.modalPresentationStyle = UIModalPresentationCurrentContext;
  
  UINavigationController * n = [[UINavigationController alloc] initWithRootViewController:v];
  n.modalPresentationStyle = UIModalPresentationFormSheet;
  
  [self presentViewController:n animated:YES completion:nil];
  [v release];
  [n release];
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
