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

#import "AddObjectAttributeViewController.h"

@interface AddObjectAttributeViewController ()

@end

@implementation AddObjectAttributeViewController
@synthesize sInvert, sRotateBody, cMovement;
@synthesize sTime, lTime, sDistance, lDistance, sRotX, sRotY, lRot, lInvert, vRot, vDist;

- (id)initWithAttribute:(nt_attribute *)aAttribute
{
  self = [super initWithNibName:@"AddObjectAttributeViewController" bundle:[NSBundle mainBundle]];
  if (self)
  {
    m_attribute = aAttribute;
  }
  return self;
}


- (void)dealloc
{
  [sInvert release];
  sInvert = nil;
  [sRotateBody release];
  sRotateBody = nil;
  [cMovement release];
  cMovement = nil;
  [sTime release];
  sTime = nil;
  [lTime release];
  lTime = nil;
  [sDistance release];
  sDistance = nil;
  [lDistance release];
  lDistance = nil;
  [sRotX release];
  sRotX = nil;
  [sRotY release];
  sRotY = nil;
  [lRot release];
  lRot = nil;
  [lInvert release];
  lInvert = nil;
  [vRot release];
  vRot = nil;
  [vDist release];
  vDist = nil;
  [super dealloc];
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  UIBarButtonItem * anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(savePressed:)];
  self.navigationItem.rightBarButtonItem = anotherButton;
  [anotherButton release];
  
  self.view.backgroundColor = self.vRot.backgroundColor = self.vDist.backgroundColor = [UIColor colorWithRed:150.0/255 green:150.0/255 blue:150.0/255 alpha:1.0];
  
  self.title = @"Movement";
  
  [self setValues];
}


- (IBAction)savePressed:(id)sender
{
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)valuesChanged:(id)sender
{
  m_attribute.inverted = self.sInvert.isOn;
  m_attribute.dontRotateBody = !self.sRotateBody.isOn;
  m_attribute.movement = (kObjectMovementType)(self.cMovement.selectedSegmentIndex+1);
  m_attribute.time = (int)self.sTime.value;
  m_attribute.distance = (int)self.sDistance.value;
  
  m_attribute.rotationPoint = CGPointMake(roundf(self.sRotX.value*10.0f)/10.0f, roundf(self.sRotY.value*10.0f)/10.0f);
  
  [self setValues];
}


- (void)setValues
{
  [self.sInvert setOn:m_attribute.inverted animated:NO];
  [self.sRotateBody setOn:!m_attribute.dontRotateBody animated:NO];
  [self.cMovement setSelectedSegmentIndex:m_attribute.movement-1];
  
  [self.sTime setValue:m_attribute.time animated:NO];
  lTime.text = [NSString stringWithFormat:@"%i second%@", (int)m_attribute.time, ((int)m_attribute.time == 1 ? @"" : @"s")];
  
  [self.sDistance setValue:m_attribute.distance animated:NO];
  lDistance.text = [NSString stringWithFormat:@"Distance: %i pixels", (int)m_attribute.distance];
  
  [self.sRotX setValue:m_attribute.rotationPoint.x animated:NO];
  [self.sRotY setValue:m_attribute.rotationPoint.y animated:NO];
  
  lRot.text = [NSString stringWithFormat:@"Anchor Point: (%.1f, %.1f)", m_attribute.rotationPoint.x, m_attribute.rotationPoint.y];
  
  if (m_attribute.movement == kObjectMovementTypeRotate)
  {
    if (self.vRot.hidden == NO)
      return;
    
    self.vRot.center = CGPointMake(self.vRot.center.x + self.view.bounds.size.width, self.vRot.center.y);
    self.vRot.hidden = NO;
    
    self.lInvert.alpha = 0.0f;
    self.lInvert.text = @"Clockwise:";
    
    [UIView animateWithDuration:0.4f animations:^
    {
      self.vRot.center = CGPointMake(self.vRot.center.x - self.view.bounds.size.width, self.vRot.center.y);
      self.vDist.center = CGPointMake(self.vDist.center.x - self.view.bounds.size.width, self.vDist.center.y);
      self.lInvert.alpha = 1.0f;
    }
                     completion:^(BOOL finished)
    {
      self.vDist.hidden = YES;
      self.vDist.center = CGPointMake(self.vDist.center.x + self.view.bounds.size.width, self.vDist.center.y);
    }];
  }
  else
  {
    if (self.vDist.hidden == NO)
      return;
    
    self.vDist.center = CGPointMake(self.vDist.center.x - self.view.bounds.size.width, self.vDist.center.y);
    self.vDist.hidden = NO;
    
    self.lInvert.alpha = 0.0f;
    self.lInvert.text = @"Invert:";
    
    [UIView animateWithDuration:0.4f animations:^
    {
      self.vDist.center = CGPointMake(self.vDist.center.x + self.view.bounds.size.width, self.vDist.center.y);
      self.vRot.center = CGPointMake(self.vRot.center.x + self.view.bounds.size.width, self.vRot.center.y);
      self.lInvert.alpha = 1.0f;
    }
                     completion:^(BOOL finished)
    {
      self.vRot.hidden = YES;
      self.vRot.center = CGPointMake(self.vRot.center.x - self.view.bounds.size.width, self.vRot.center.y);
    }];
  }
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
