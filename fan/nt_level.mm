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

#import "nt_level.h"
#import "nt_fan.h"
#import "nt_block.h"
#import "config.h"

@interface nt_level (Private)

- (NSString *)checkExtentionForPath:(NSString *)aPath;

@end

@implementation nt_level


+ (id)level
{
  return [[[self alloc] init] autorelease];
}


+ (id)levelWithLength:(float)aLength fans:(NSArray *)aFans blocks:(NSArray *)aBlocks coins:(NSArray *)aCoins
{
  return [[[self alloc] initWithLength:aLength fans:aFans blocks:aBlocks coins:aCoins] autorelease];
}


+ (id)levelWithDocumentsFile:(NSString *)aFile
{
  return [[[self alloc] initWithDocumentsFile:aFile] autorelease];
}


+ (id)levelWithBundleFile:(NSString *)aFile inPack:(NSString *)aPack
{
  return [[[self alloc] initWithBundleFile:aFile inPack:aPack] autorelease];
}


+ (id)levelWithFilePath:(NSString *)aFilePath
{
  return [[[self alloc] initWithFilePath:aFilePath] autorelease];
}


- (id)init
{
  return [self initWithLength:STANDARD_SCREEN_WIDTH fans:nil blocks:nil coins:nil];
}


- (id)initWithLength:(float)aLength fans:(NSArray *)aFans blocks:(NSArray *)aBlocks coins:(NSArray *)aCoins
{
  self = [super init];
  if (self)
  {
    m_length = aLength;
    m_fans = [[NSMutableArray alloc] initWithArray:aFans copyItems:YES];
    m_blocks = [[NSMutableArray alloc] initWithArray:aBlocks copyItems:YES];
    m_coins = [[NSMutableArray alloc] initWithArray:aCoins copyItems:YES];
  }
  return self;
}


- (id)initWithDocumentsFile:(NSString *)aFile
{
  return [self initWithFilePath:[nt_level documentsPathForName:aFile]];
}


- (id)initWithBundleFile:(NSString *)aFile inPack:(NSString *)aPack
{
  return [self initWithFilePath:[nt_level bundlePathForName:aFile inPack:aPack]];
}


- (id)initWithFilePath:(NSString *)aFilePath
{
  aFilePath = [self checkExtentionForPath:aFilePath];
  
  NSFileManager * fileManager = [NSFileManager defaultManager];
  
  if ([fileManager fileExistsAtPath:aFilePath])
  {
    NSMutableData * data = [NSData dataWithContentsOfFile:aFilePath];
    self = [self initWithData:data];
  }
  else
  {
    //create new data
    self = [self initWithLength:STANDARD_SCREEN_WIDTH fans:nil blocks:nil coins:nil];
    NSLog(@"Warning! No level file found at path: %@", aFilePath);
  }
  return self;
}


- (id)initWithData:(NSData *)aData
{
  NSKeyedUnarchiver * decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:aData];
  
  self = [[decoder decodeObjectForKey:@"level"] retain];
  
  [decoder release];
  
  return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
  float length = [aDecoder decodeFloatForKey:@"length"];
  NSMutableArray * fans = [aDecoder decodeObjectForKey:@"fans"];
  NSMutableArray * blocks = [aDecoder decodeObjectForKey:@"blocks"];
  NSMutableArray * coins = [aDecoder decodeObjectForKey:@"coins"];
  
  return [self initWithLength:length fans:fans blocks:blocks coins:coins];
}


- (id)copyWithZone:(NSZone *)zone
{
  nt_level * another = [[nt_level alloc] initWithLength:m_length fans:m_fans blocks:m_blocks coins:m_coins];
  return another;
}


- (void)dealloc
{
  [m_fans release];
  [m_blocks release];
  [m_coins release];
  [super dealloc];
}


+ (NSString *)bundlePathForName:(NSString *)aName inPack:(NSString *)aPack
{
  NSString * levelsDir = [[NSBundle mainBundle] pathForResource:@"levels" ofType:nil];
  NSString * folderDirectory = [levelsDir stringByAppendingFormat:@"/%@/", aPack];
  
  return [folderDirectory stringByAppendingString:aName];
}


+ (NSString *)documentsPathForName:(NSString *)aName
{
  NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString * documentsDirectory = [paths objectAtIndex:0];
  
  return [documentsDirectory stringByAppendingFormat:@"/%@", aName];
}


- (void)saveToFile:(NSString *)aFile
{
  aFile = [self checkExtentionForPath:aFile];
  
	NSString * dataPath = [nt_level documentsPathForName:aFile];
  NSData * data = self.data;
  
	[data writeToFile:dataPath atomically:YES];
}


- (NSData *)data
{
	NSMutableData * res;
	NSKeyedArchiver * encoder;
  
	res = [NSMutableData data];
	encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:res];
  [encoder encodeObject:self forKey:@"level"];
	[encoder finishEncoding];
	[encoder release];
  
  return res;
}


- (float)length
{
  return m_length;
}


- (NSMutableArray *)fans
{
  return m_fans;
}


- (NSMutableArray *)blocks
{
  return m_blocks;
}


- (NSMutableArray *)coins
{
  return m_coins;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeFloat:m_length forKey:@"length"];
  [aCoder encodeObject:m_fans forKey:@"fans"];
  [aCoder encodeObject:m_blocks forKey:@"blocks"];
  [aCoder encodeObject:m_coins forKey:@"coins"];
}


- (NSString *)checkExtentionForPath:(NSString *)aPath
{
  if (![aPath hasSuffix:@".dat"])
    aPath = [NSString stringWithFormat:@"%@.dat", aPath];
  return aPath;
}


@end
