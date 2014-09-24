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

#import "MultipleObjectsViewController.h"
#import "ObjectAttributesViewController.h"

@interface MultipleObjectsViewController ()

@end

@implementation MultipleObjectsViewController
@synthesize delegate = _delegate, duplicated = m_duplicated;

- (id)initWithObjects:(NSArray *)aObjects
{
  self = [super initWithNibName:@"MultipleObjectsViewController" bundle:[NSBundle mainBundle]];
  if (self)
  {
    m_objects = [[NSMutableArray alloc] initWithArray:aObjects];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
  }
  return self;
}


- (void)dealloc
{
  [m_objects release];
  
  [super dealloc];
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = @"Multiple Objects Options";
  
  UIBarButtonItem * anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(donePressed:)];
  self.navigationItem.rightBarButtonItem = anotherButton;
  [anotherButton release];
}


- (NSMutableArray *)objects
{
  return m_objects;
}


- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  
  if ([self.delegate respondsToSelector:@selector(multipleObjectsViewControllerDidFinish:)])
    [self.delegate multipleObjectsViewControllerDidFinish:self];
}


- (IBAction)donePressed:(id)sender
{
  [self dismissModalViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  
  cell.textLabel.textAlignment = UITextAlignmentCenter;
  
  switch (indexPath.row)
  {
    case 0:
      cell.textLabel.text = @"Duplicate";
      break;
    case 1:
      cell.textLabel.text = @"Animate";
      break;
      
    default:
      break;
  }
  
  return cell;
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  ObjectAttributesViewController * v;
  m_duplicated = NO;
  
  switch (indexPath.row)
  {
    case 0:
      if ([self.delegate respondsToSelector:@selector(multipleObjectsViewControllerDidDuplicate:)])
        [self.delegate multipleObjectsViewControllerDidDuplicate:self];
      m_duplicated = YES;
      [self donePressed:nil];
      break;
    case 1:
      v = [[ObjectAttributesViewController alloc] initWithObjects:m_objects];
      [self.navigationController pushViewController:v animated:YES];
      [v release];
      break;
      
    default:
      break;
  }
}

@end
