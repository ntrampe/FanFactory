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

@interface nt_pagedLayer : nt_scrollLayer
{
	int m_currentScreen;
	NSMutableArray * m_layers;
}

@property(readwrite, assign) CGFloat minimumTouchLengthToSlide;
@property(readwrite, assign) CGFloat minimumTouchLengthToChangePage;
@property(readwrite, assign) BOOL showPagesIndicator;
@property(readwrite, assign) CGPoint pagesIndicatorPosition;
@property(readwrite) CGFloat pagesWidthOffset;


+ (id)nodeWithLayers:(NSArray *)aLayers widthOffset:(int)aWidthOffset;
- (id)initWithLayers:(NSArray *)aLayers widthOffset:(int)aWidthOffset;

- (int)numberOfLayers;

- (void)updatePages;
- (void)addPage:(CCLayer *)aPage withNumber:(int)aPageNumber;
- (void)addPage:(CCLayer *)aPage;
- (void)removePage:(CCLayer *)aPage;
- (void)removePageWithNumber:(int)aPageNumber;
- (int)pageNumberForPosition:(CGPoint)aPosition;
- (CGPoint)positionForPageWithNumber:(int)aPageNumber;
- (void)moveToPage:(int)aPage animated:(BOOL)isAnimated;


@end
