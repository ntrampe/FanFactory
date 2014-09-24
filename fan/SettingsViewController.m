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

#import "SettingsViewController.h"
#import "SettingsController.h"
#import "PackController.h"
#import "GameController.h"
#import "nt_filemanager.h"
#import "GameKitHelper.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize sDebug, sTutorial, sEditingTutorial, sHighestLevel, lHighestLevel;

- (id)init
{
  self = [super initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
  if (self)
  {
    sharedSC = [SettingsController sharedSettingsController];
    sharedPC = [PackController sharedPackController];
    sharedGC = [GameController sharedGameController];
  }
  return self;
}


- (void)dealloc
{
  [sDebug release];
  sDebug = nil;
  [sTutorial release];
  sTutorial = nil;
  [sEditingTutorial release];
  sEditingTutorial = nil;
  [sHighestLevel release];
  sHighestLevel = nil;
  [lHighestLevel release];
  lHighestLevel = nil;
  
  [super dealloc];
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [sDebug           setOn:sharedSC.debugging        animated:NO];
  [sTutorial        setOn:sharedSC.tutorial         animated:NO];
  [sEditingTutorial setOn:sharedSC.editingTutorial  animated:NO];
  [sHighestLevel    setValue:0                      animated:NO];
  [lHighestLevel setText:[NSString stringWithFormat:@"%i", (int)sHighestLevel.value]];
}


- (IBAction)donePressed:(id)sender
{
  [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)valueChanged:(id)sender
{
  sharedSC.debugging = sDebug.isOn;
  sharedSC.tutorial = sTutorial.isOn;
  sharedSC.editingTutorial = sEditingTutorial.isOn;
  [sharedSC saveSettings];
  [sharedSC saveData];
}


- (IBAction)highestLevelEnd:(id)sender
{
  [sharedPC resetData];
  
  for (int x = 0; x < (int)self.sHighestLevel.value; x++)
  {
    [sharedPC setCurrentLevel:x];
    [sharedPC setCurrentLevelStars:3];
  }
  
  [lHighestLevel setText:[NSString stringWithFormat:@"%i", (int)self.sHighestLevel.value]];
}


- (IBAction)highestLevelChanged:(id)sender
{
  [lHighestLevel setText:[NSString stringWithFormat:@"%i", (int)sHighestLevel.value]];
}


- (IBAction)resetPressed:(id)sender
{
  [sharedPC resetData];
  [sharedSC resetData];
  [sharedGC resetData];
  [self donePressed:nil];
}


- (IBAction)gameCenterPressed:(id)sender
{
  //[[GameKitHelper sharedGameKitHelper] reportAchievementWithID:@"com.offkilterstudios.fan.finishalllevels" percentComplete:100];
  
  [[GameKitHelper sharedGameKitHelper] showAchievements];
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
