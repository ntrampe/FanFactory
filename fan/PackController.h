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

@class nt_pack;
@class nt_level;
@class nt_leveldata;

@interface PackController : NSObject
{
  NSUserDefaults *    settings;   //stores the users settings
  NSMutableArray * m_packs;
  uint m_currentPack, m_currentLevel;
  unsigned int m_coins;
  BOOL m_foundEasterEgg;
}
@property (nonatomic, assign) unsigned int coins;

- (NSMutableArray *)packs;
- (nt_pack *)packForNumber:(int)aNumber;
- (nt_pack *)packForName:(NSString *)aName;
- (int)numberOfPacks;
- (int)highestAvailablePack;

- (void)setCurrentPack:(uint)aPack;
- (void)setCurrentLevel:(uint)aLevel;
- (void)setCurrentPack:(uint)aPack level:(uint)aLevel;

- (void)setCurrentLevelStars:(uint)aStars;
- (void)makeCurrentLevelCollectCoins:(NSArray *)aCoins;
- (int)currentLevelStars;
- (NSMutableArray *)currentLevelCollectedCoins;

- (nt_pack *)currentPack;
- (nt_level *)currentLevel;
- (nt_leveldata *)currentLevelData;
- (int)currentPackNumber;
- (int)currentLevelNumber;

- (nt_pack *)nextPack;
- (nt_level *)nextLevel;
- (nt_leveldata *)nextLevelData;
- (BOOL)endOfLevels;

- (NSArray *)allLevelData;

- (void)findEasterEgg;

//singleton function
+ (PackController *)sharedPackController;

//***data saving functions (self explanatory)
- (void)saveData;
- (void)loadData;
- (void)resetData;

//***settings saving functions (self explanatory)
- (void)saveSettings;
- (void)loadSettings;
- (void)setSettings;
- (void)resetSettings;

@end
