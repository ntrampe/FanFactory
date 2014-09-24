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
#import "GameLayerScene.h"
#import "nt_label.h"
#import "nt_button.h"
#import "nt_alertBanner.h"
#import "nt_tutorial.h"

@class SettingsController;

@interface GameTutorialScene : GameLayerScene <TutorialDelegate>
{
  SettingsController * sharedSC;
  
  nt_tutorial * m_tutorial;
  CCMenu * m_menu;
  nt_buttonitem * m_start;
  nt_buttonitem * m_retry;
  BOOL m_hasCollectedCoin;
  float m_playerDistance;
}

+ (CCScene *)scene;

- (void)skipPressed;

- (void)stillNeedsHelp;
- (BOOL)hasMovedFans;

@end
