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

#import "GameController.h"
#import "nt_level.h"
#import "nt_fanPowerUpgrade.h"
#import "nt_ballShieldUpgrade.h"
#import "nt_ballSizeUpgrade.h"
#import "AppDelegate.h"

@interface GameController (Private) 

- (void)initController;

@end

@implementation GameController

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
  [m_upgrades release];
  [super dealloc];
}


- (void)initController
{
  //load the data when the app starts
  [self loadData];
  
  self.testing = NO;
}


- (kGameState)state
{
  return m_state;
}


- (void)start
{
  m_prevState = m_state;
  m_state = kGameStateRunning;
  
}


- (void)reset
{
  m_prevState = m_state;
  m_state = kGameStateEditing;
  
}


- (void)end
{
  m_prevState = m_state;
  m_state = kGameStateOver;
  
}


- (void)pause
{
  m_prevState = m_state;
  m_state = kGameStatePaused;
  
}


- (void)resume
{
  m_state = m_prevState;
  
}


- (void)edit
{
  m_prevState = m_state;
  m_state = kGameStateEditing;
  
}


- (NSMutableArray *)upgrades
{
  return m_upgrades;
}


- (void)setAllUpgrades
{
  for (nt_upgrade * u in m_upgrades)
    [u setLocalValues];
}


- (float)percentOfUpgradesUnlocked
{
  int unlocked = 0;
  int total = 0;
  
  for (nt_upgrade * u in m_upgrades)
  {
    total += u.maxLevel;
    unlocked += u.level;
  }
  
  if (total == 0 || unlocked == 0)
    return 0;
  
  return ((float)unlocked / total) * 100;
}


- (BOOL)allUpgradesUnlocked
{
  return (self.percentOfUpgradesUnlocked == 100);
}


- (UIViewController *)rootViewController
{
  AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
  return (UIViewController *)appDelegate.director;
}


#pragma mark -
#pragma mark Data Functions


- (void)saveData
{
  //create the appropriate file path
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *gameDataPath = [documentsDirectory stringByAppendingPathComponent:@"game"];
	
  //create game data and a keyed archiver
	NSMutableData *gameData;
	NSKeyedArchiver *encoder;
	gameData = [NSMutableData data];
	encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:gameData];
	
  //encode it
  [encoder encodeObject:m_upgrades forKey:@"upgrades"];
	
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
	NSString *documentPath = [documentsDirectory stringByAppendingPathComponent:@"game"];
  
  m_upgrades = [[NSMutableArray alloc] init];
  
  nt_upgrade * up = [[nt_fanPowerUpgrade alloc] initWithTitle:@"Fan Power"
                                                         info:@"Push the ball greater distances."
                                                      preview:@"fan_power_upgrade_preview.png"
                                                        level:0];
  [m_upgrades addObject:up];
  [up release];
  
  up = [[nt_ballShieldUpgrade alloc] initWithTitle:@"Ball Shield"
                                              info:@"Hit more blocks without losing a star."
                                           preview:@"ball_shield_upgrade_preview.png"
                                             level:0];
  [m_upgrades addObject:up];
  [up release];
  
  up = [[nt_ballSizeUpgrade alloc] initWithTitle:@"Ball Size"
                                            info:@"Shrink the size of your player so you can fit through smaller areas."
                                         preview:@"ball_size_upgrade_preview.png"
                                           level:0];
  [m_upgrades addObject:up];
  [up release];
  
  //if there is a file then decode it. If not, then set empty values and create one
  if ([fileManager fileExistsAtPath:documentPath])
  {
    NSMutableData *gameData;
    NSKeyedUnarchiver *decoder;
    
    gameData = [NSData dataWithContentsOfFile:documentPath];
    
    decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:gameData];
    
    NSMutableArray * oldUpgrades = [[decoder decodeObjectForKey:@"upgrades"] mutableCopy];
    
    [decoder release];
    
    for (nt_upgrade * oldUp in oldUpgrades)
    {
      for (nt_upgrade * newUp in m_upgrades)
      {
        if ([oldUp.title isEqualToString:newUp.title])
        {
          [newUp setLevel:oldUp.level];
        }
      }
    }
    
    [oldUpgrades release];
  }
  
  self.ballShield = 0;
  self.ballSize = 0;
  
  [self setAllUpgrades];
  [self saveData];
}


- (void)resetData
{
  //create the appropriate file path
  NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentPath = [documentsDirectory stringByAppendingPathComponent:@"game"];
  
  //if there is a file then remove it and create another one by loading data. If not, display error
  if ([fileManager fileExistsAtPath:documentPath])
  {
    [fileManager removeItemAtPath:documentPath error:NULL];
  }
  else
  {
    //no file
  }
  
  [self loadData];
}


#pragma mark -
#pragma mark Singleton


static GameController *sharedGameController = nil;


+ (GameController *)sharedGameController
{ 
	@synchronized(self) 
	{ 
		if (sharedGameController == nil) 
		{ 
			sharedGameController = [[self alloc] init]; 
		} 
	} 
  
	return sharedGameController; 
} 


+ (id)allocWithZone:(NSZone *)zone 
{ 
	@synchronized(self) 
	{ 
		if (sharedGameController == nil) 
		{ 
			sharedGameController = [super allocWithZone:zone]; 
			return sharedGameController; 
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
