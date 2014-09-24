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

#import "PackController.h"
#import "nt_pack.h"
#import "nt_level.h"
#import "nt_leveldata.h"
#import "config.h"

@interface PackController (Private) 

- (void)initController;

@end

@implementation PackController
@synthesize coins = m_coins;

#pragma mark -
#pragma mark Init


- (id)init
{
  self = [super init];
  if (self)
  {
    [self initController];
  }
  
  return self;
}

- (void)dealloc
{
  [m_packs release];
  [super dealloc];
}


- (void)initController
{
  //load the data when the app starts
  [self loadData];
  
  //create the standard settings
  settings = [NSUserDefaults  standardUserDefaults];
  //load settings
  [self loadSettings];
}


- (NSMutableArray *)packs
{
  return m_packs;
}


- (nt_pack *)packForNumber:(int)aNumber
{
  if (aNumber >= 0 && aNumber < m_packs.count)
    return [m_packs objectAtIndex:aNumber];
  return nil;
}


- (nt_pack *)packForName:(NSString *)aName
{
  for (nt_pack * p in m_packs)
    if ([p.name isEqualToString:aName])
      return p;
  return nil;
}


- (int)numberOfPacks
{
  return m_packs.count;
}


- (int)highestAvailablePack
{
  int res = 0;
  
  for (nt_pack * p in m_packs)
    if (p.packCompleted)
      res++;
  
  return res;
}


- (void)setCurrentPack:(uint)aPack
{
  [self setCurrentPack:aPack level:0];
}


- (void)setCurrentLevel:(uint)aLevel
{
  int actualPack = 0;
  int tempLevel = aLevel;
  
  while (tempLevel > LEVELS_PER_PACK)
  {
    tempLevel -= LEVELS_PER_PACK;
    actualPack++;
  }
  
  [self setCurrentPack:(actualPack == 0 ? m_currentPack : actualPack) level:tempLevel];
}


- (void)setCurrentPack:(uint)aPack level:(uint)aLevel
{
  if (aPack > m_packs.count - 1)
    aPack = m_packs.count - 1;
  
  if (aLevel >= [[m_packs objectAtIndex:aPack] numberOfLevels] && aPack != m_packs.count - 1)
  {
    aPack++;
    aLevel = 0;
  }
  
  //NSLog(@"(%i, %i)", aPack, aLevel);
  
  m_currentPack = aPack;
  m_currentLevel = aLevel;
}


- (void)setCurrentLevelStars:(uint)aStars
{
  [[[self currentPack] levelDataForNumber:m_currentLevel] setStars:aStars];
}


- (void)makeCurrentLevelCollectCoins:(NSArray *)aCoins
{
  [[[self currentPack] levelDataForNumber:m_currentLevel] collectCoins:aCoins];
}


- (int)currentLevelStars
{
  return [[[self currentPack] levelDataForNumber:m_currentLevel] stars];
}


- (NSMutableArray *)currentLevelCollectedCoins
{
  return [[[self currentPack] levelDataForNumber:m_currentLevel] collectedCoins];
}


- (nt_pack *)currentPack
{
  return [m_packs objectAtIndex:m_currentPack];
}


- (nt_level *)currentLevel
{
  return [[self currentPack] levelForNumber:m_currentLevel];
}


- (nt_leveldata *)currentLevelData
{
  return [[self currentPack] levelDataForNumber:m_currentLevel];
}


- (int)currentPackNumber
{
  return m_currentPack;
}


- (int)currentLevelNumber
{
  return m_currentLevel;
}


- (nt_pack *)nextPack
{
  [self setCurrentPack:m_currentPack+1];
  return [self currentPack];
}


- (nt_level *)nextLevel
{
  [self setCurrentLevel:m_currentLevel+1];
  return [self currentLevel];
}


- (nt_leveldata *)nextLevelData
{
  [self setCurrentLevel:m_currentLevel+1];
  return [self currentLevelData];
}


- (BOOL)endOfLevels
{
  return (m_currentLevel+1)*(m_currentPack+1) == (m_packs.count)*(LEVELS_PER_PACK);
}


- (NSArray *)allLevelData
{
  NSMutableArray * res = [NSMutableArray array];
  
  for (nt_pack * p in m_packs)
    [res addObjectsFromArray:p.levels];
  
  return res;
}


- (void)findEasterEgg
{
  NSString * message, * dis;
  
  if (!m_foundEasterEgg)
  {
    self.coins += 50;
    m_foundEasterEgg = YES;
    message = @"You found the easter egg!\nAs a reward, you get 50 coins!";
    dis = @"Yay!";
    
    [self saveData];
  }
  else
  {
    message = @"You've already found the easter egg!";
    dis = @"Aww...";
  }
  
  UIAlertView * alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:dis otherButtonTitles:nil];
  [alert show];
  [alert release];
}


#pragma mark -
#pragma mark Data Functions


- (void)saveData
{
  //create the appropriate file path
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *gameDataPath = [documentsDirectory stringByAppendingPathComponent:@"userdata"];
	
  //create game data and a keyed archiver
	NSMutableData *gameData;
	NSKeyedArchiver *encoder;
	gameData = [NSMutableData data];
	encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:gameData];
	
  //encode it
  [encoder encodeObject:self.allLevelData forKey:@"levels"];
  [encoder encodeInt:m_coins forKey:@"coins"];
  [encoder encodeBool:m_foundEasterEgg forKey:@"foundEasterEgg"];
  [encoder encodeInt:m_currentLevel forKey:@"currentLevel"];
  [encoder encodeInt:m_currentPack forKey:@"currentPack"];
	
	[encoder finishEncoding];
  
  //create it
	[gameData writeToFile:gameDataPath atomically:YES];
	[encoder release];
}


- (void)loadData
{
  //create the appropriate file path
  NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentPath = [documentsDirectory stringByAppendingPathComponent:@"userdata"];
  
  m_packs = [[NSMutableArray alloc] init];
  
  NSString * levelsDir = [[NSBundle mainBundle] pathForResource:@"levels" ofType:nil];
  
  NSArray * packFolders = [fileManager contentsOfDirectoryAtPath:levelsDir error:nil];
  
  for (NSString * pack in packFolders)
  {
    if (![pack isEqualToString:@"tutorial.dat"])
    {
      nt_pack * p = [[nt_pack alloc] initWithFolderDirectoryName:pack];
      [m_packs addObject:p];
      [p release];
    }
  }
  
  //if there is a file then decode it. If not, then set empty values and create one
  if ([fileManager fileExistsAtPath:documentPath])
  {
    NSMutableData *gameData;
    NSKeyedUnarchiver *decoder;
    
    gameData = [NSData dataWithContentsOfFile:documentPath];
    
    decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:gameData];
    
    NSMutableArray * leveldatas = [decoder decodeObjectForKey:@"levels"];
    
    for (nt_pack * pack in m_packs)
      [pack syncWithLevelData:leveldatas];
    
    m_coins = [decoder decodeIntForKey:@"coins"];
    m_foundEasterEgg = [decoder decodeBoolForKey:@"foundEasterEgg"];
    m_currentLevel = [decoder decodeIntForKey:@"currentLevel"];
    m_currentPack = [decoder decodeIntForKey:@"currentPack"];
    
    [decoder release];
  }
  else
  {
    m_coins = 0;
    m_currentLevel = 0;
    m_currentPack = 0;
  }
  
  [self saveData];
}


- (void)resetData
{
  //create the appropriate file path
  NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentPath = [documentsDirectory stringByAppendingPathComponent:@"userdata"];
  
  //if there is a file then remove it and create another one by loading data. If not, display error
  if ([fileManager fileExistsAtPath:documentPath])
  {
    [fileManager removeItemAtPath:documentPath error:NULL];
    [self loadData];
  }
  else
  {
    //no file
  }
}


#pragma mark -
#pragma mark Settings Functions


- (void)saveSettings
{
  //set settings values
  
  [settings synchronize];
}


- (void)loadSettings
{
  //if there isn't a true value for userDefaultsSet then it's the first time creating settings
  if (![settings boolForKey:@"userDefaultsSet"])
  {
		[settings setBool:YES       forKey:@"userDefaultsSet"];
    [self setSettings];
	}
  else
  {
    [self setSettings];
	}
}


- (void)setSettings
{
  //assign values
}


- (void)resetSettings
{ 
  //reset the settings by setting userDefaultsSet to NO and load settings twice to actually set the values
  [settings setBool:NO forKey:@"userDefaultsSet"];
  [self loadSettings];
}


#pragma mark -
#pragma mark Singleton


static PackController *sharedPackController = nil;


+ (PackController *)sharedPackController
{ 
	@synchronized(self) 
	{ 
		if (sharedPackController == nil) 
		{ 
			sharedPackController = [[self alloc] init]; 
		} 
	} 
  
	return sharedPackController; 
} 


+ (id)allocWithZone:(NSZone *)zone 
{ 
	@synchronized(self) 
	{ 
		if (sharedPackController == nil) 
		{ 
			sharedPackController = [super allocWithZone:zone]; 
			return sharedPackController; 
		} 
	} 
  
	return nil; 
} 


- (id)copyWithZone:(NSZone *)zone 
{ 
	return self; 
} 


- (id)retain 
{ 
	return self; 
} 


- (NSUInteger)retainCount 
{ 
	return NSUIntegerMax; 
} 


- (id)autorelease 
{ 
	return self; 
}


@end
