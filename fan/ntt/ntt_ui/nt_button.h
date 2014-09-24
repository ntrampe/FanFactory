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
#import "nt_label.h"
#import "CCMenuItemImageScaled.h"

@interface nt_button : CCMenu
{
  
}

+ (id)buttonWithImage:(NSString*)file title:(NSString *)title atPosition:(CGPoint)position target:(id)target selector:(SEL)selector;

@end



@interface nt_buttonitem : CCMenuItemImageScaled
{
  nt_label * m_labelTitle;
  NSString * m_sound, * m_title;
}
@property (nonatomic, retain) NSString * sound, * title;

+ (id)buttonWithText:(NSString*)text image:(NSString *)image target:(id)target selector:(SEL)selector;
+ (id)buttonWithText:(NSString*)text imageFrame:(NSString *)imageFrame target:(id)target selector:(SEL)selector;
+ (id)buttonWithText:(NSString*)text sprite:(CCSprite *)aSprite target:(id)target selector:(SEL)selector;
+ (id)buttonWithText:(NSString*)text image:(NSString *)image block:(void(^)(id sender))block;
+ (id)buttonWithText:(NSString*)text imageFrame:(NSString *)imageFrame block:(void(^)(id sender))block;
+ (id)buttonWithText:(NSString*)text sprite:(CCSprite *)aSprite block:(void(^)(id sender))block;

- (id)initWithText:(NSString*)text image:(NSString *)image target:(id)target selector:(SEL)selector;
- (id)initWithText:(NSString*)text imageFrame:(NSString *)imageFrame target:(id)target selector:(SEL)selector;
- (id)initWithText:(NSString*)text sprite:(CCSprite *)aSprite target:(id)target selector:(SEL)selector;
- (id)initWithText:(NSString*)text image:(NSString *)image block:(void(^)(id sender))block;
- (id)initWithText:(NSString*)text imageFrame:(NSString *)imageFrame block:(void(^)(id sender))block;
- (id)initWithText:(NSString*)text sprite:(CCSprite *)aSprite block:(void(^)(id sender))block;

- (void)setText:(NSString *)text;
- (void)setLabel:(nt_label *)label;
- (void)setLabelOffset:(CGPoint)offset;

- (void)pulse;

@end