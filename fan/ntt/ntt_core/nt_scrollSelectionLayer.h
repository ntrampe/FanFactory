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

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "nt_scrollLayer.h"
#import "nt_scrollSelectionCell.h"
#import "nt_scrollMenu.h"

@class nt_scrollSelectionLayer;

@protocol ScrollSelectionLayerDelegate <NSObject>

@optional

- (void)selectionLayer:(nt_scrollSelectionLayer *)selectionLayer didSelectCell:(nt_scrollSelectionCell *)cell atIndex:(NSInteger)index;
- (void)selectionLayer:(nt_scrollSelectionLayer *)selectionLayer didDeleteCell:(nt_scrollSelectionCell *)cell atIndex:(NSInteger)index;
- (BOOL)cellEnabledForIndex:(NSInteger)index;

@required
- (CGFloat)selectionLayerWidthOffset:(nt_scrollSelectionLayer *)selectionLayer;
- (NSInteger)numberOfCellsInSelectionLayer:(nt_scrollSelectionLayer *)selectionLayer;
- (nt_scrollSelectionCell *)selectionLayer:(nt_scrollSelectionLayer *)selectionLayer cellForIndex:(NSInteger)index;

@end

@interface nt_scrollSelectionLayer : nt_scrollLayer <SelectionCellDelegate>
{
  CCArray * m_data;
  nt_scrollMenu * m_menu;
}
@property (readwrite, assign) NSObject <ScrollSelectionLayerDelegate> * selectionDelegate;
@property (nonatomic, assign) BOOL editing;

- (void)reloadData;
- (void)setEnabled:(BOOL)isEnabled;

- (void)insertCell:(nt_scrollSelectionCell *)aCell;
- (void)deleteCell:(nt_scrollSelectionCell *)aCell;
- (nt_scrollSelectionCell *)cellForTitle:(NSString *)aTitle;

@end
