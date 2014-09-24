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

#import "ObjectAttributesViewController.h"
#import "AttributeCell.h"
#import "AddObjectAttributeViewController.h"
#import "nt_attribute.h"

static NSString * CellIdentifier = @"AttributeCell";

@interface ObjectAttributesViewController ()

@end

@implementation ObjectAttributesViewController
@synthesize delegate = _delegate;
@synthesize table;

- (id)initWithObjects:(NSArray *)aObjects
{
  self = [super initWithNibName:@"ObjectAttributesViewController" bundle:nil];
  if (self)
  {
    m_objects = [[NSMutableArray alloc] initWithArray:aObjects];
    cellLoader = [[UINib nibWithNibName:CellIdentifier bundle:[NSBundle mainBundle]] retain];
    
    if (m_objects.count > 1)
    {
      for (nt_object * o in m_objects)
      {
        [o.attributes removeAllObjects];
      }
    }
    
    m_attributes = [(nt_object *)[m_objects objectAtIndex:0] attributes];
  }
  return self;
}


- (void)dealloc
{
  [table release];
  [cellLoader release];
  [m_objects release];
  [super dealloc];
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = @"Object Animations";
  
  UIBarButtonItem * anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(donePressed:)];
  self.navigationItem.rightBarButtonItem = anotherButton;
  [anotherButton release];
  
  self.table.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
  self.table.backgroundColor = [UIColor colorWithRed:150.0/255 green:150.0/255 blue:150.0/255 alpha:1.0];
}


- (void)viewWillAppear:(BOOL)animated
{
  [self.table reloadData];
  
//  UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - 30, -60, 60, 60)];
//  [img setImage:[UIImage imageNamed:@"animation_horizontal.png"]];
//  img.userInteractionEnabled = YES;
//  [self.table addSubview:img];
//  [img release];
}


- (IBAction)donePressed:(id)sender
{
  if ([self.delegate respondsToSelector:@selector(objectAttributesViewController:didFinishWithAttributes:)])
    [self.delegate objectAttributesViewController:self didFinishWithAttributes:m_attributes];
  
  [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table View


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return m_attributes.count + 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 70;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  AttributeCell *cell = (AttributeCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (!cell)
  {
    NSArray *topLevelItems = [cellLoader instantiateWithOwner:self options:nil];
    cell = [topLevelItems objectAtIndex:0];
  }
  
  if (indexPath.row == m_attributes.count)
  {
    cell.textLabel.text = @"Tap to add movement";
    cell.textLabel.textAlignment = UITextAlignmentCenter;
  }
  else
  {
    // Configure the cell...
    nt_attribute * a = [m_attributes objectAtIndex:indexPath.row];
    NSString * objectName = [NSStringFromClass([[m_objects objectAtIndex:0] class]) stringByReplacingOccurrencesOfString:@"nt_" withString:@""];
    
    cell.textLabel.numberOfLines = 4;
    
    switch (a.movement)
    {
      case kObjectMovementTypeNone:
        cell.textLabel.text = @"None";
        cell.imageView.image = nil;
        break;
        
      case kObjectMovementTypeOscillateHorizontal:
        cell.textLabel.text = [NSString stringWithFormat:@"The %@ will move %i pixels from %@ in %i second%@.",
                               objectName,
                               (int)a.distance,
                               (a.inverted ? @"left to right" : @"right to left"),
                               (int)a.time,
                               ((int)a.time == 1 ? @"" : @"s")];
        
        cell.imageView.image = [UIImage imageNamed:@"animation_horizontal.png"];
        break;
        
      case kObjectMovementTypeOscillateVertical:
        cell.textLabel.text = [NSString stringWithFormat:@"The %@ will move %i pixels %@ in %i second%@.",
                               objectName,
                               (int)a.distance,
                               (a.inverted ? @"down and up" : @"up and down"),
                               (int)a.time,
                               ((int)a.time == 1 ? @"" : @"s")];
        
        cell.imageView.image = [UIImage imageNamed:@"animation_vertical.png"];
        break;
        
      case kObjectMovementTypeRotate:
        cell.textLabel.text = [NSString stringWithFormat:@"The %@ will rotate %@ around %@ in %i second%@.",
                               objectName,
                               (a.inverted ? @"clockwise" : @"counterclockwise"),
                               (CGPointEqualToPoint(a.rotationPoint, CGPointZero) ? @"the center" : [NSString stringWithFormat:@"the point (%.1f, %.1f)", a.rotationPoint.x, a.rotationPoint.y]),
                               (int)a.time,
                               ((int)a.time == 1 ? @"" : @"s")];
        
        cell.imageView.image = [UIImage imageNamed:@"animation_rotate.png"];
        break;
        
      default:
        break;
    }
  }

  [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
  cell.backgroundColor = [UIColor colorWithRed:150.0/255 green:150.0/255 blue:150.0/255 alpha:1.0];
  cell.contentView.backgroundColor = [UIColor colorWithRed:150.0/255 green:150.0/255 blue:150.0/255 alpha:1.0];
  
  return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  nt_attribute * a;
  
  if (indexPath.row == m_attributes.count)
  {
    a = [nt_attribute attributeWithMovement:kObjectMovementTypeOscillateVertical time:5.0f distance:50.0f rotationPoint:CGPointMake(0.0f, 0.0f) rotateBody:YES invert:NO];
    
    for (nt_object * o in m_objects)
      [o.attributes addObject:a];
  }
  else
  {
    a = [m_attributes objectAtIndex:indexPath.row];
  }
  
  AddObjectAttributeViewController * v = [[AddObjectAttributeViewController alloc] initWithAttribute:a];
  [self.navigationController pushViewController:v animated:YES];
  [v release];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return (indexPath.row != m_attributes.count);
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete)
  {
    [m_attributes removeObjectAtIndex:indexPath.row];
    [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
  }
  else if (editingStyle == UITableViewCellEditingStyleInsert)
  {
    
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
