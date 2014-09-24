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

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "nt_layer.h"
#import "FanBanner.h"
#import "nt_tutorialState.h"

enum kArrowDirection
{
  kArrowDirectionUp =     0,
  kArrowDirectionDown =   1,
  kArrowDirectionLeft =   2,
  kArrowDirectionRight =  3,
  kArrowDirectionNone =   4
  };

@class nt_tutorial;

@protocol TutorialDelegate <NSObject>

@optional
- (void)tutorial:(nt_tutorial *)sender didUpdateTutorialState:(unsigned int)aState;
- (void)tutorialDidReachEndOfTutorial:(nt_tutorial *)sender;

@end

@interface nt_tutorial : nt_layer <nt_alertviewdelegate>
{
  CCSprite * m_arrow;
  CGSize m_arrowBounds;
  NSMutableArray * m_states;
  unsigned int m_state, m_attempts;
}
@property (readwrite, assign) NSObject <TutorialDelegate> * delegate;
@property(readonly) unsigned int state;
@property(readwrite, assign) unsigned int attempts;
@property(readwrite, assign) BOOL autoNext, autoRemoveArrow;

- (void)pointArrowToLocation:(CGPoint)aPoint forceDirection:(kArrowDirection)aDirection;
- (void)pointArrowToLocation:(CGPoint)aPoint;
- (void)removeArrow;

- (void)addStateString:(NSString *)aStateString andArrowLocation:(CGPoint)aLocation forState:(unsigned int)aState;
- (void)addStateString:(NSString *)aStateString forState:(unsigned int)aState;
- (void)addState:(unsigned int)aState;
- (nt_tutorialState *)tutorialStateForState:(unsigned int)aState;
- (unsigned int)lastState;
- (unsigned int)numberOfStates;

- (void)setState:(unsigned int)aState update:(BOOL)shouldUpdate;
- (void)setState:(unsigned int)aState;

- (void)setArrowScale:(float)aScale;

- (void)start;
- (void)next;
- (void)end;

- (BOOL)transitioning;

- (void)addAlertWithText:(NSString *)aText time:(float)aTime;
- (void)addAlertWithText:(NSString *)aText;

- (void)setArrowBounds:(CGSize)aBounds;

@end
