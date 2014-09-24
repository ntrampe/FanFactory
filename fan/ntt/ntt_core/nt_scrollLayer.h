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
#import "nt_layer.h"

typedef enum
{
  kScrollLayerStateIdle = 0,
  kScrollLayerStateScrolling = 1
}kScrollLayerState;

typedef enum
{
  kScrollOutOfBoundsStateLeft = 0,
  kScrollOutOfBoundsStateRight = 1,
  kScrollOutOfBoundsStateUp = 2,
  kScrollOutOfBoundsStateDown = 3,
  kScrollOutOfBoundsStateLeftUp = 4,
  kScrollOutOfBoundsStateLeftDown = 5,
  kScrollOutOfBoundsStateRightUp = 6,
  kScrollOutOfBoundsStateRightDown = 7,
  kScrollOutOfBoundsStateNone = 8
}kScrollOutOfBoundsState;

@class nt_scrollLayer;

@protocol nt_scrollLayerDelegate <NSObject>

@optional
- (void)scrollLayerDidScroll:(nt_scrollLayer *)scrollLayer;
- (void)scrollLayerDidZoom:(nt_scrollLayer *)scrollLayer;
- (void)scrollLayerWillBeginDragging:(nt_scrollLayer *)scrollLayer;
- (void)scrollLayerWillEndDragging:(nt_scrollLayer *)scrollLayer withVelocity:(CGPoint)velocity;
- (void)scrollLayerWillBeginDecelerating:(nt_scrollLayer *)scrollLayer;
- (void)scrollLayerDidEndDecelerating:(nt_scrollLayer *)scrollLayer;

@end

@interface nt_scrollLayer : nt_layer <UIScrollViewDelegate>
{
  CGPoint m_velocity, m_maxVelocity, m_stretch, m_maxStretch;
  NSMutableArray * m_touches;
  kScrollLayerState m_state;
  BOOL m_dragged, m_isTouching;
  CGSize m_bounds;
  CGFloat m_lastScale, m_newScale;
  BOOL m_scaling, m_animating;
  CGFloat m_animationTime;
}
@property (readwrite, assign) NSObject <nt_scrollLayerDelegate> * delegate;
@property (nonatomic, assign) BOOL scrollX, scrollY, isBounded, sticksToBottom, zooms, bounces, doubleTapToZoom, drawBounds;
@property (nonatomic, assign) CGFloat touchDistance;
@property (nonatomic, assign) CGPoint touchDistancePoint;
@property (nonatomic, assign) CGFloat minimumScale, maximumScale;
@property (nonatomic, readonly) BOOL isScaling;

- (void)update:(ccTime)dt;

- (CGPoint)velocity;
- (CGPoint)velocityPercentage;
- (void)setBounds:(CGSize)aBounds;
- (CGSize)bounds;

- (void)setAnimationTime:(CGFloat)aAnimationTime;
- (void)setMaxVelocity:(CGPoint)aVelocity;

- (void)scrollToPosition:(CGPoint)aPoint inTime:(float)aTime;
- (void)scrollToStartInTime:(float)aTime;
- (void)scrollToEndInTime:(float)aTime;
- (void)zoomToScale:(float)aScale atPoint:(CGPoint)aPoint inTime:(float)aTime;
- (void)zoomToScale:(float)aScale inTime:(float)aTime;
- (void)zoomToScaleAndKeepPosition:(float)aScale inTime:(float)aTime;
- (void)zoomToNormalInTime:(float)aTime;

- (BOOL)isZooming;

@end
