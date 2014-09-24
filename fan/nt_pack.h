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

@class nt_level;
@class nt_leveldata;

@interface nt_pack : NSObject <NSCoding, NSCopying>
{
  NSMutableArray * m_levels;
  NSString * m_name;
}

- (id)initWithName:(NSString *)aName levels:(NSArray *)aLevels;
- (id)initWithFolderDirectoryName:(NSString *)aName;

- (nt_leveldata *)levelDataForNumber:(int)aNumber;
- (nt_level *)levelForNumber:(int)aNumber;
- (NSArray *)levels;
- (int)numberOfLevels;
- (int)highestAvailableLevel;
- (BOOL)packCompleted;
- (int)totalStars;
- (int)totalStarsInLevels;
- (int)totalCoinsCollected;
- (int)totalCoinsInLevels;

- (void)syncWithLevelData:(NSArray *)aLevelData;

- (NSString *)name;

@end
