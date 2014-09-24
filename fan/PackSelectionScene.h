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
#import "MenuSubLayer.h"
#import "nt_scrollSelectionLayer.h"
#import "LevelSelectionScene.h"

@class PackController;
@class PackSelectionScene;

@protocol PackSelectionDelegate <NSObject>

@optional
- (void)packSelection:(PackSelectionScene *)packSelectionScene didSelectPack:(int)aPack;
- (void)packSelectionDidReturnToPacks:(PackSelectionScene *)packSelectionScene;

@end

@interface PackSelectionScene : MenuSubLayer <ScrollSelectionLayerDelegate>
{
  PackController * sharedPC;
  nt_scrollSelectionLayer * m_scrollLayer;
  LevelSelectionScene * m_levels;
  int m_packNumber;
}
@property (readwrite, assign) NSObject <PackSelectionDelegate> * delegate;

+ (CCScene *)scene;

- (void)goToPack:(int)aPack;
- (void)returnToPacks;

@end
