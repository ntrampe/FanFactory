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

#import "nt_leveldata.h"
#import "nt_filemanager.h"
#import "nt_level.h"
#import "nt_coin.h"
#import "nt_coindata.h"

@implementation nt_leveldata
@synthesize file = m_file, pack = m_pack;

- (id)initWithFile:(NSString *)aFile pack:(NSString *)aPack stars:(int)aStars collectedCoins:(NSMutableArray *)aCollectedCoins
{
  self = [super init];
  if (self)
  {
    m_file = [aFile copy];
    m_pack = [aPack copy];
    m_stars = aStars;
    
    if (aCollectedCoins != nil)
    {
      m_collectedCoins = [aCollectedCoins retain];
    }
    else
    {
      m_collectedCoins = [[NSMutableArray alloc] init];
    }
    
    //TODO: Try to get around this extra computation time
    m_totalCoins = self.level.coins.count;
  }
  return self;
}


- (id)copyWithZone:(NSZone *)zone
{
  nt_leveldata * another = [[nt_leveldata alloc] initWithFile:m_file pack:m_pack stars:m_stars collectedCoins:m_collectedCoins];
  return another;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
  NSString * file =             [aDecoder decodeObjectForKey:@"file"];
  NSString * pack =             [aDecoder decodeObjectForKey:@"pack"];
  int stars =                   [aDecoder decodeIntForKey:@"stars"];
  NSMutableArray * coins =      [aDecoder decodeObjectForKey:@"coins"];
  NSMutableArray * coinValues = [NSMutableArray array];
  
  for (nt_coindata * d in coins)
  {
    [coinValues addObject:[NSValue valueWithCGPoint:d.point]];
  }
  
  return [self initWithFile:file pack:pack stars:stars collectedCoins:coinValues];
}


- (void)dealloc
{
  [m_pack release];
  [m_file release];
  [m_collectedCoins release];
  [super dealloc];
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:m_file             forKey:@"file"];
  [aCoder encodeObject:m_pack             forKey:@"pack"];
  [aCoder encodeInt:m_stars               forKey:@"stars"];
  
  NSMutableArray * valueData = [[NSMutableArray alloc] init];
  
  for (NSValue * v in m_collectedCoins)
  {
    nt_coindata * d = [[nt_coindata alloc] initWithPoint:[v CGPointValue]];
    [valueData addObject:d];
    [d release];
  }
  
  [aCoder encodeObject:valueData   forKey:@"coins"];
}


- (nt_level *)level
{
//  if ([nt_filemanager pathExists:[nt_filemanager documentsPathForFile:m_file ofType:nil]])
//    return [nt_level levelWithDocumentsFile:m_file];
  
  return [nt_level levelWithBundleFile:m_file inPack:m_pack];
}


- (int)fileNumber
{
  //assuming file name is just a number
  return [[m_file stringByDeletingPathExtension] intValue];
}


- (int)stars
{
  return m_stars;
}


- (NSMutableArray *)collectedCoins
{
  return m_collectedCoins;
}


- (int)totalCoins
{
  return m_totalCoins;
}


- (void)setPack:(NSString *)aPack
{
  if (m_pack != nil)
  {
    [m_pack release];
    m_pack = nil;
  }
  
  m_pack = [aPack copy];
}


- (void)setStars:(int)aStars
{
  if (aStars < 0)
    aStars = 0;
  else if (aStars > 3)
    aStars = 3;
  
  if (aStars > m_stars)
    m_stars = aStars;
}


- (void)collectCoin:(nt_coin *)aCoin
{
  if (aCoin != nil)
  {
    CGPoint p = aCoin.originalPosition;
    NSValue * v = [NSValue valueWithCGPoint:p];
    [self collectCoinValue:v];
  }
}


- (void)collectCoinValue:(NSValue *)aCoinValue
{
  CGPoint p = aCoinValue.CGPointValue;
  BOOL found = NO;
  for (NSValue * myV in m_collectedCoins)
  {
    CGPoint myP = [myV CGPointValue];
    if (CGPointEqualToPoint(p, myP))
    {
      found = YES;
    }
  }
  if (!found)
  {
    [m_collectedCoins addObject:aCoinValue];
  }
}


- (void)collectCoins:(NSArray *)aCoins
{
  for (nt_coin * c in aCoins)
    [self collectCoin:c];
}


- (void)collectCoinValues:(NSArray *)aCoinValues
{
  for (NSValue * v in aCoinValues)
    [self collectCoinValue:v];
}


- (void)removeCoins
{
  [m_collectedCoins removeAllObjects];
}


- (BOOL)isEqualToLevelData:(nt_leveldata *)aLevelData
{
  if (!([m_file isEqualToString:aLevelData.file] && [m_pack isEqualToString:aLevelData.pack]))
    return NO;
  return YES;
}


@end
