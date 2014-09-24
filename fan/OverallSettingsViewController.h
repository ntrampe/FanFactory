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

#import <UIKit/UIKit.h>
#import "nt_object.h"

@class OverallSettingsViewController;

@protocol OverallSettingsViewControllerDelegate <NSObject>
@optional
- (void)overallSettingsViewControllerDidFinish:(OverallSettingsViewController *)sender;

@end

@interface OverallSettingsViewController : UIViewController
{
  nt_object * m_defaultObject;
}
@property (readwrite, assign) NSObject <OverallSettingsViewControllerDelegate> * delegate;
@property (nonatomic, retain) IBOutlet UISwitch * sSnaps, * sGuides;
@property (nonatomic, retain) IBOutlet UISegmentedControl * cEditMode;
@property (readwrite, assign) BOOL snaps, guides;
@property (readwrite, assign) int editMode;
@property (nonatomic, retain) nt_object * defaultObject;

- (IBAction)donePressed:(id)sender;
- (IBAction)snapsToggled:(id)sender;
- (IBAction)guidesToggled:(id)sender;
- (IBAction)editTypeToggled:(UISegmentedControl *)sender;
- (IBAction)defaultObjectPressed:(id)sender;

@end
