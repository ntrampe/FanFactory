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
  kAlertViewPresentationStyleCoverUp = 0,
  kAlertViewPresentationStyleCoverDown = 1,
  kAlertViewPresentationStyleCoverLeft = 2,
  kAlertViewPresentationStyleCoverRight = 3
}kAlertViewPresentationStyle;

@class nt_buttonitem;
@class nt_label;
@class nt_alertview;

@protocol nt_alertviewdelegate

@optional
- (void)ntalertViewDidShow:(nt_alertview *)sender;
- (void)ntalertViewDidHide:(nt_alertview *)sender;
- (void)ntalertViewWillShow:(nt_alertview *)sender;
- (void)ntalertViewWillHide:(nt_alertview *)sender;
- (void)ntalertView:(nt_alertview *)sender didFinishWithButtonIndex:(int)buttonIndex;

@end

@interface nt_alertview : nt_layer
{
  CCNode * m_container;
  CCMenu * m_menu;
  nt_label * m_lMessage;
  CCLayerColor * m_black;
  int m_nButtons;
  CGPoint m_displayPosition;
  BOOL m_shown, m_dismissing;
}
@property (nonatomic, assign) NSObject <nt_alertviewdelegate> * delegate;
@property (nonatomic, retain) CCMenu * menu;
@property (nonatomic, assign) BOOL canBeDismissed, outsideTouchDismisses, cancelsMenuTouches;
@property (nonatomic, assign) kAlertViewPresentationStyle presentationStyle;


- (id)initWithImageName:(NSString *)aName
                message:(NSString *)aMessage
               delegate:(id)aDelegate
      cancelButtonTitle:(NSString *)aCancelButtonTitle
      otherButtonTitles:(NSArray *)someOtherTitles;

- (id)initWithImageFrameName:(NSString *)aName
                     message:(NSString *)aMessage
                    delegate:(id)aDelegate
           cancelButtonTitle:(NSString *)aCancelButtonTitle
           otherButtonTitles:(NSArray *)someOtherTitles;

- (id)initWithContainer:(CCNode *)aContainer
             message:(NSString *)aMessage
            delegate:(id)aDelegate
   cancelButtonTitle:(NSString *)aCancelButtonTitle
   otherButtonTitles:(NSArray *)someOtherTitles;

- (void)addMenu:(CCMenu *)aMenu atPosition:(CGPoint)aPosition;
- (void)setMenuOffset:(float)anOffset;
- (void)setMenuOffsetFromBottom:(float)anOffset;
- (void)alignMenuItems;
- (void)setDisplayPosition:(CGPoint)aPoint;
- (void)setTextColor:(ccColor3B)aColor;

- (CCNode *)container;

- (void)addButtonSprite:(CCSprite *)aSprite atPosition:(CGPoint)aPosition;
- (void)addButtonImageName:(NSString *)aButtonImageName atPosition:(CGPoint)aPosition;
- (void)addButtonImageFrameName:(NSString *)aButtonImageFrameName atPosition:(CGPoint)aPosition;

- (NSString *)titleForButtonIndex:(int)anIndex;

- (void)dismiss;

+ (void)removeAllAlertViews;
+ (CGFloat)fontSize;
+ (CGSize)containerSizeForMessage:(NSString *)aString andMaxWidth:(float)aWidth;
+ (CGSize)containerSizeForMessage:(NSString *)aString;

@end
