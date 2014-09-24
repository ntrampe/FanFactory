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
#import "ParallaxBackground.h"
#import "PackSelectionScene.h"
#import "MenuSubLayer.h"

@class SettingsController;
@class PackController;

@interface MenuScene : nt_layer <PackSelectionDelegate>
{
  SettingsController * sharedSC;
  PackController * sharedPC;
  ParallaxBackground * m_parallax;
  CCLayer * m_menu;
  CCSprite * m_logo;
  MenuSubLayer * m_subLayer;
  float m_velocity;
  BOOL m_moving;
}

+ (CCScene *)scene;

- (void)goToSubLayer:(MenuSubLayer *)aSubLayer;
- (void)moveToSubLayer;
- (void)removeSubLayer;
- (void)goToMenu;
- (void)showWelcome;

- (void)test;

@end
