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

#import "nt_scrollSelectionLayer.h"
#import "nt_scrollSelectionCell.h"

@interface nt_scrollSelectionLayer (Private)

- (void)addCell:(nt_scrollSelectionCell *)aCell;
- (void)removeCell:(nt_scrollSelectionCell *)aCell;
- (void)removeCellAtIndex:(NSInteger)aIndex;

- (void)updateMenu;
- (float)menuWidth;
- (CGPoint)menuPosition;

@end

@implementation nt_scrollSelectionLayer
@synthesize selectionDelegate = _selectionDelegate;
@synthesize editing = _editing;

- (id)init
{
  self = [super init];
  if (self) 
  {
    m_data = [[CCArray alloc] init];
    
    m_menu = [nt_scrollMenu menuWithItems:nil];
    m_menu.position = self.screenCenter;
    [self addChild:m_menu];
    
    self.bounces = YES;
    self.scrollY = NO;
  }
  return self;
}


- (void)dealloc
{
  [m_data release];
  [super dealloc];
}


- (void)onEnter
{
  [super onEnter];
  
  [self reloadData];
}


- (void)update:(ccTime)dt
{
  [super update:dt];
  
//  for (nt_scrollSelectionCell * c in m_data)
//  {
//    CGPoint pos = [c convertToWorldSpace:c.position];
//    pos = [m_menu convertToWorldSpace:pos];
//    
//    c.visible = (pos.x + c.contentSize.width >= 0 && pos.x <= self.screenSize.width);
//  }
}


- (void)setEditing:(BOOL)editing
{
  _editing = editing;
  
  for (nt_scrollSelectionCell * c in m_data)
    [c setEditing:editing];
}


- (void)reloadData
{
//  for (nt_scrollSelectionCell * c in m_data)
//  {
//    [c runAction:[CCScaleTo actionWithDuration:0.2f scale:0.0f]];
//  }
  
  [m_menu removeAllChildrenWithCleanup:YES];
  [m_data removeAllObjects];
  
  for (int x = 0; x < [self.selectionDelegate numberOfCellsInSelectionLayer:self]; x++)
  {
    nt_scrollSelectionCell * cell = [self.selectionDelegate selectionLayer:self cellForIndex:x];
    
    if ([self.selectionDelegate respondsToSelector:@selector(cellEnabledForIndex:)])
    {
      [cell setEnabled:[self.selectionDelegate cellEnabledForIndex:x]];
    }
    
    [self addCell:cell];
  }
  
  [self updateMenu];
}


- (void)setEnabled:(BOOL)isEnabled
{
  for (nt_scrollSelectionCell * c in m_data)
  {
    [c setEnabled:isEnabled];
  }
}


- (void)insertCell:(nt_scrollSelectionCell *)aCell
{
  for (nt_scrollSelectionCell * c in m_data)
  {
    CCMoveBy * move = [CCEaseElasticOut actionWithAction:[CCMoveBy actionWithDuration:0.6f position:CGPointMake(-aCell.contentSize.width/2 - [self.selectionDelegate selectionLayerWidthOffset:self]/2.0f, 0)]];
    [c runAction:move];
  }
  
  [self addCell:aCell];
  
  [self updateMenu];
  
  aCell.position = CGPointMake(aCell.position.x + 100, aCell.position.y);
  aCell.opacity = 0.0f;
  [aCell runAction:[CCEaseElasticOut actionWithAction:[CCMoveTo actionWithDuration:0.6f position:CGPointMake(aCell.position.x - 100, aCell.position.y)]]];
  [aCell runAction:[CCFadeIn actionWithDuration:0.1f]];
  
  [self scheduleOnce:@selector(reloadData) delay:0.6f];
}


- (void)deleteCell:(nt_scrollSelectionCell *)aCell
{
  for (nt_scrollSelectionCell * c in m_data)
  {
    if (c != aCell)
    {
      CGPoint newPos = CGPointMake(0, 0);
      if (c.position.x > aCell.position.x)
      {
        newPos.x = -c.contentSize.width/2 - [self.selectionDelegate selectionLayerWidthOffset:self]/2.0f;
      }
      else
      {
        newPos.x = c.contentSize.width/2 + [self.selectionDelegate selectionLayerWidthOffset:self]/2.0f;
      }
      
      CCMoveBy * move = [CCEaseElasticOut actionWithAction:[CCMoveBy actionWithDuration:0.6f position:newPos]];
      [c runAction:move];
    }
    else
    {
      CCScaleTo * scale = [CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:0.1f scale:0.0f]];
      [c runAction:scale];
      [c runAction:[CCFadeOut actionWithDuration:0.1f]];
    }
  }
  
  [self removeCell:aCell];
  [self updateMenu];
  
  [self scheduleOnce:@selector(reloadData) delay:0.6f];
}


- (nt_scrollSelectionCell *)cellForTitle:(NSString *)aTitle
{
  for (nt_scrollSelectionCell * c in m_data)
    if ([c.title isEqualToString:aTitle])
      return c;
  
  return NULL;
}


- (void)addCell:(nt_scrollSelectionCell *)aCell
{
  [aCell setEditing:self.editing];
  aCell.delegate = self;
  [m_data addObject:aCell];
  [m_menu addChild:[m_data lastObject]];
}


- (void)removeCell:(nt_scrollSelectionCell *)aCell
{
  if (aCell)
    return;
  
  [m_menu removeChild:aCell cleanup:YES];
  [m_data removeObject:aCell];
  
  [self updateMenu];
}


- (void)removeCellAtIndex:(NSInteger)aIndex;
{
  if (aIndex < 0 || aIndex >= m_data.count)
    return;
  
  [self removeCell:[m_data objectAtIndex:aIndex]];
}


- (void)updateMenu
{
  [m_menu alignItemsHorizontallyWithPadding:[self.selectionDelegate selectionLayerWidthOffset:self]];
  
  [self setBounds:CGSizeMake(self.menuWidth/2, self.screenSize.height)];
//  m_menu.position = self.menuPosition;
  [m_menu runAction:[CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:0.2f position:self.menuPosition]]];
}


- (float)menuWidth
{
  float res = 0;
  
  for (nt_scrollSelectionCell * c in m_menu.children)
    res += c.contentSize.width + [self.selectionDelegate selectionLayerWidthOffset:self];
  
  if (res < self.screenSize.width)
    res = self.screenSize.width;
  
  return res*2;
}


- (CGPoint)menuPosition
{
  return CGPointMake(self.bounds.width/2, m_menu.position.y);
}


- (void)selectionCellDidSelect:(nt_scrollSelectionCell *)cell
{
  if ([self.selectionDelegate respondsToSelector:@selector(selectionLayer:didSelectCell:atIndex:)])
    [self.selectionDelegate selectionLayer:self didSelectCell:cell atIndex:[m_data indexOfObject:cell]];
}


- (void)selectionCellDidDelete:(nt_scrollSelectionCell *)cell
{
  if ([self.selectionDelegate respondsToSelector:@selector(selectionLayer:didDeleteCell:atIndex:)])
    [self.selectionDelegate selectionLayer:self didDeleteCell:cell atIndex:[m_data indexOfObject:cell]];
  [self removeCell:cell];
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
  return YES;
}


- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super ccTouchesMoved:touches withEvent:event];
  [m_menu unselect];
}


@end
