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
@class nt_coin;

@interface nt_leveldata : NSObject <NSCoding, NSCopying>
{
  NSString * m_file;
  NSString * m_pack;
  int m_stars;
  int m_totalCoins;
  NSMutableArray * m_collectedCoins;
}
@property (readonly) NSString * file, * pack;

- (id)initWithFile:(NSString *)aFile pack:(NSString *)aPack stars:(int)aStars collectedCoins:(NSMutableArray *)aCollectedCoins;

- (nt_level *)level;
- (int)fileNumber;

- (int)stars;
- (NSMutableArray *)collectedCoins;
- (int)totalCoins;

- (void)setPack:(NSString *)aPack;
- (void)setStars:(int)aStars;

- (void)collectCoin:(nt_coin *)aCoin;
- (void)collectCoinValue:(NSValue *)aCoinValue;
- (void)collectCoins:(NSArray *)aCoins;
- (void)collectCoinValues:(NSArray *)aCoinValues;
- (void)removeCoins;

- (BOOL)isEqualToLevelData:(nt_leveldata *)aLevelData;


@end
