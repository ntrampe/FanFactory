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

#import "nt_pack.h"
#import "nt_level.h"
#import "nt_leveldata.h"

@implementation nt_pack


- (id)initWithName:(NSString *)aName levels:(NSArray *)aLevels
{
  self = [super init];
  if (self)
  {
    m_name = [aName copy];
    
    //sort
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"fileNumber"
                                                  ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [aLevels sortedArrayUsingDescriptors:sortDescriptors];
    
    m_levels = [[NSMutableArray alloc] initWithArray:sortedArray copyItems:YES];
  }
  return self;
}


- (id)initWithFolderDirectoryName:(NSString *)aName
{
  NSMutableArray * levels = [[NSMutableArray alloc] init];
  NSFileManager * fm = [NSFileManager defaultManager];
  NSString * levelsDir = [[NSBundle mainBundle] pathForResource:@"levels" ofType:nil];
  NSString * folderDirectory = [levelsDir stringByAppendingFormat:@"/%@/", aName];
  NSArray * dirContents = [fm contentsOfDirectoryAtPath:folderDirectory error:nil];
  NSPredicate * filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.dat'"];
  NSArray * files = [dirContents filteredArrayUsingPredicate:filter];
  
  for (NSString * f in files)
  {
    nt_leveldata * l = [[nt_leveldata alloc] initWithFile:f pack:aName stars:0 collectedCoins:nil];
    [levels addObject:l];
    [l release];
  }
  
  self = [self initWithName:aName levels:levels];
  if (self)
  {
    
  }
  
  [levels release];
  
  return self;
}


- (id)copyWithZone:(NSZone *)zone
{
  nt_pack * another = [[nt_pack alloc] initWithName:m_name levels:m_levels];
  return another;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
  NSString * name = [aDecoder decodeObjectForKey:@"name"];
  NSArray * levels = [aDecoder decodeObjectForKey:@"levels"];
  
  return [self initWithName:name levels:levels];
}


- (void)dealloc
{
  [m_name release];
  [m_levels release];
  [super dealloc];
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:m_name forKey:@"name"];
  [aCoder encodeObject:m_levels forKey:@"levels"];
}


- (nt_leveldata *)levelDataForNumber:(int)aNumber
{
  if (aNumber < 0)
    aNumber = 0;
  if (aNumber >= self.numberOfLevels)
    aNumber = self.numberOfLevels - 1;
  
  return [m_levels objectAtIndex:aNumber];
}


- (nt_level *)levelForNumber:(int)aNumber
{
  return [[self levelDataForNumber:aNumber] level];
}


- (NSArray *)levels
{
  return m_levels;
}


- (int)numberOfLevels
{
  return m_levels.count;
}


- (int)highestAvailableLevel
{
  int res = -1;
  
  for (int y = self.levels.count-1; y >= 0 && res == -1; y--)
  {
    nt_leveldata * d = [self levelDataForNumber:y];
    if (d.stars > 0 && y > res)
    {
      res = y;
    }
  }
  
  res++;
  
  return res;
}


- (BOOL)packCompleted
{
  return (self.highestAvailableLevel-1 >= self.numberOfLevels-1);
}


- (int)totalStars
{
  int res = 0;
  
  for (nt_leveldata * l in m_levels)
  {
    res += l.stars;
  }
  
  return res;
}


- (int)totalStarsInLevels
{
  return m_levels.count*3;
}


- (int)totalCoinsCollected
{
  int res = 0;
  
  for (nt_leveldata * l in m_levels)
  {
    res += l.collectedCoins.count;
  }
  
  return res;
}


- (int)totalCoinsInLevels
{
  int res = 0;
  
  for (nt_leveldata * l in m_levels)
  {
    res += l.totalCoins;
  }
  
  return res;
}


- (void)syncWithLevelData:(NSArray *)aLevelData
{ 
  for (nt_leveldata * new in aLevelData)
  {
    for (nt_leveldata * old in m_levels)
    {
      if ([new isEqualToLevelData:old])
      {
        old.pack = new.pack;
        old.stars = new.stars;
        [old removeCoins];
        [old collectCoinValues:new.collectedCoins];
      }
    }
  }
}


- (NSString *)name
{
  return m_name;
}


@end
