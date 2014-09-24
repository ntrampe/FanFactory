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
#import "ntt_types.h"

#define BG_TAG 999
#define BG_COLOR_TAG 998
#define DONT_MOVE_SPRITE_TAG 997

@class nt_buttonitem;
@class nt_label;

@interface nt_layer : CCLayer
{
  nt_buttonitem * m_back;
  CCArray * m_gestures;
  CCArray * m_spritepositions;
}
@property (nonatomic, assign) BOOL clipsToBounds;

- (void)addBackButton;
- (void)addBackButtonWithBlock:(void(^)(id sender))aBlock;
- (void)addBackButtonAtPosition:(CGPoint)aPos withBlock:(void(^)(id sender))aBlock;
- (void)removeBackButton;

- (nt_buttonitem *)backButton;

- (UIViewController *)rootViewController;
- (void)presentViewController:(UIViewController *)aViewController animated:(BOOL)isAnimated;

- (void)addButton:(nt_buttonitem *)aButton atLocation:(CGPoint)aLoc;

- (void)goToScene:(CCScene *)aScene;
- (void)goToScene:(CCScene *)aScene animate:(BOOL)shouldAnimate;

- (void)changeScene:(CCScene *)aScene;
- (void)changeScene:(CCScene *)aScene animate:(BOOL)shouldAnimate;

- (void)goBack;
- (void)changeToMenu;

- (void)setMenuStatus:(BOOL)enabled node:(id)node;
- (void)removeAllMenusStartingFromNode:(id)node;
- (void)killAllTouchesStartingFromNode:(id)node;

- (void)setBackGround:(NSString *)aBg;
- (void)setBackGround:(NSString *)aBg scaleMode:(BGScaleMode)aMode;
- (void)setBackGround:(NSString *)aBg scaleMode:(BGScaleMode)aMode replaceOld:(BOOL)shouldReplace;
- (void)setBackGroundColor:(ccColor4B)aColor;

- (nt_label *)showLabel:(NSString *)aLabel color:(ccColor3B)aColor size:(float)aSize atPos:(CGPoint)aPos tag:(NSInteger)aTag time:(float)aTime;
- (void)hideLabel:(nt_label *)aLabel;
- (void)hideLabelByTag:(NSInteger)aTag;
- (void)removeLabel:(nt_label *)aLabel;
- (void)removeLabelByTag:(NSInteger)aTag;
- (void)removeAllLabels;

- (void)addGesture:(UIGestureRecognizer *)aGesture;
- (void)removeGesture:(UIGestureRecognizer *)aGesture;

- (CGSize)screenSize;
- (CGPoint)screenCenter;

- (void)show:(BOOL)shouldAnimate;
- (void)hide:(BOOL)shouldAnimate;

- (void)show;
- (void)hide;

- (void)hideSpritesStartingFromNode:(CCNode *)aNode animated:(BOOL)isAnimated;
- (void)showSprites;

- (void)callBlock:(void(^)())block afterDelay:(float)aDelay;

@end
